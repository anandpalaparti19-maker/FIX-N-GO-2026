const Order = require('../models/orderModel');
const User = require('../models/userModel');
const { defaultChecklist, technicianCut, pushStatusHistory, assignServiceCoords, formatOrderForTech, haversineKm } = require('../utils/orderHelpers');
const { emitNotification } = require('../utils/mqttService');

const dispatchToNearestTechnician = async (order) => {
  try {
    // Find online technicians near the service location using 2dsphere index
    const nearestTechs = await User.find({
      role: 'technician',
      isOnline: true,
      location: {
        $nearSphere: {
          $geometry: {
            type: 'Point',
            coordinates: [order.serviceLng, order.serviceLat],
          },
        },
      },
    }).limit(1);

    if (nearestTechs.length === 0) return null;
    const nearest = nearestTechs[0];

    // Offer to nearest
    order.technician = nearest.name;
    order.technicianUser = nearest._id;
    order.dispatchStatus = 'offered';
    order.status = 'assigned';
    order.technicianEarning = technicianCut(order.total);
    order.checklist = defaultChecklist(order.issues);
    pushStatusHistory(order, 'assigned', `System auto-dispatched to ${nearest.name}`);
    await order.save();

    // Notify via socket
    emitNotification(nearest._id.toString(), {
      type: 'new_order_offer',
      title: 'New Job Available!',
      message: `A new repair job for ${order.brand} ${order.model} is available near you.`,
      orderId: order._id,
    });

    return nearest;
  } catch (error) {
    console.error('Auto-dispatch error:', error);
    return null;
  }
};

const assignTechnicianToOrder = async (order, technicianName) => {
  if (!technicianName) return;

  const techUser = await User.findOne({
    role: 'technician',
    name: new RegExp(`^${technicianName.trim()}$`, 'i'),
  });

  if (!techUser) return;

  order.technician = techUser.name;
  order.technicianUser = techUser._id;
  order.dispatchStatus = 'offered';
  order.status = 'assigned';
  order.technicianEarning = technicianCut(order.total);
  order.checklist = defaultChecklist(order.issues);
  pushStatusHistory(order, 'assigned', `Offered to ${techUser.name}`);
};

const formatOrderForCustomer = (order) => {
  const tech = order.technicianUser;
  return {
    ...order.toObject(),
    technicianName: order.technician || tech?.name || '',
    technicianRating: tech?.technicianMeta?.rating,
    technicianPhone: tech?.phone || '',
    technicianLat: tech?.lastLat || null,
    technicianLng: tech?.lastLng || null,
    statusHistory: order.statusHistory || [],
  };
};

// Get all orders for a customer
const getOrders = async (req, res, next) => {
  try {
    const { status, sortBy = 'createdAt' } = req.query;
    let query = { user: req.user._id };

    if (status) {
      query.status = status;
    }

    const orders = await Order.find(query)
      .populate('technicianUser', 'name phone technicianMeta lastLat lastLng')
      .sort({ [sortBy]: -1 });

    res.json({
      success: true,
      count: orders.length,
      data: orders.map(formatOrderForCustomer),
    });
  } catch (error) {
    next(error);
  }
};

// Create a new order
const createOrder = async (req, res, next) => {
  try {
    const {
      brand,
      model,
      issues,
      total,
      technician,
      customerPhone,
      serviceAddress,
      city,
      pincode,
      serviceLat,
      serviceLng,
      description,
      estimatedDateTime,
    } = req.body;

    // Validate required fields
    if (!brand || !model || !issues || issues.length === 0 || !total) {
      return res
        .status(400)
        .json({ success: false, message: 'Order data is incomplete' });
    }

    // Check for conflicting orders
    const conflictingOrder = await Order.findOne({
      user: req.user._id,
      status: { $in: ['pending', 'assigned', 'in_progress'] },
    });

    if (conflictingOrder) {
      return res.status(400).json({
        success: false,
        message:
          'You have an active order. Please complete or cancel it before creating a new one.',
      });
    }

    // Create order
    const order = await Order.create({
      user: req.user._id,
      brand,
      model,
      issues,
      total,
      description: description || '',
      estimatedDateTime: estimatedDateTime || null,
      status: 'pending',
      technician: technician || '',
      customerPhone: customerPhone || req.user.phone || '',
      serviceAddress: serviceAddress || req.user.address || '',
      city: city || req.user.city || '',
      pincode: pincode || req.user.pincode || '',
      statusHistory: [{ status: 'pending', note: 'Order placed', at: new Date() }],
    });

    // Set service coordinates
    if (serviceLat != null && serviceLng != null) {
      order.serviceLat = Number(serviceLat);
      order.serviceLng = Number(serviceLng);
    } else {
      assignServiceCoords(order, `${req.user._id}-${Date.now()}`);
    }

    order.location = {
      type: 'Point',
      coordinates: [order.serviceLng, order.serviceLat],
    };

    await order.save();

    // Assign technician if provided, otherwise auto-dispatch
    if (technician) {
      await assignTechnicianToOrder(order, technician);
      await order.save();
    } else {
      await dispatchToNearestTechnician(order);
    }

    // Populate and return
    const populated = await Order.findById(order._id).populate(
      'technicianUser',
      'name phone technicianMeta lastLat lastLng'
    );

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: formatOrderForCustomer(populated),
    });
  } catch (error) {
    next(error);
  }
};

// Get order by ID
const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id).populate(
      'technicianUser',
      'name phone technicianMeta lastLat lastLng'
    );

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Authorization check
    if (order.user.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      if (order.technicianUser?.toString() !== req.user._id.toString()) {
        return res.status(403).json({ success: false, message: 'Not authorized' });
      }
    }

    res.json({
      success: true,
      data: formatOrderForCustomer(order),
    });
  } catch (error) {
    next(error);
  }
};

// Technician accepts order
const acceptOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({ success: false, message: 'Only technicians can accept orders' });
    }

    const order = await Order.findById(req.params.id).populate(
      'technicianUser',
      'name phone technicianMeta lastLat lastLng'
    );

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Verify order is in offered or pending state
    if (!['pending', 'assigned'].includes(order.status)) {
      return res
        .status(400)
        .json({ success: false, message: `Cannot accept order with status: ${order.status}` });
    }

    // Update order
    order.technicianUser = req.user._id;
    order.technician = req.user.name;
    order.status = 'assigned';
    order.dispatchStatus = 'accepted';
    if (!order.checklist || order.checklist.length === 0) {
      order.checklist = defaultChecklist(order.issues);
    }
    pushStatusHistory(order, 'assigned', `Accepted by ${req.user.name}`);

    // Calculate earnings
    order.technicianEarning = technicianCut(order.total);

    await order.save();

    // Update technician's job count
    await User.findByIdAndUpdate(
      req.user._id,
      { $inc: { 'technicianMeta.jobsDone': 1 } },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Order accepted successfully',
      data: formatOrderForTech(order, req.user),
    });
  } catch (error) {
    next(error);
  }
};

// Technician rejects order
const rejectOrder = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({ success: false, message: 'Only technicians can reject orders' });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Verify order is in offered state
    if (order.status !== 'assigned' || order.dispatchStatus !== 'offered') {
      return res.status(400).json({
        success: false,
        message: 'Order is not available for rejection',
      });
    }

    // Reset to pending
    order.status = 'pending';
    order.dispatchStatus = 'declined';
    order.technicianUser = null;
    order.technician = '';
    order.checklist = [];

    pushStatusHistory(order, 'pending', `Declined by technician`);

    await order.save();

    res.json({
      success: true,
      message: 'Order rejected successfully',
      data: formatOrderForCustomer(order),
    });
  } catch (error) {
    next(error);
  }
};

// Update order status
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status, note } = req.body;
    const validStatuses = ['pending', 'assigned', 'in_progress', 'completed', 'cancelled'];

    if (!validStatuses.includes(status)) {
      return res
        .status(400)
        .json({ success: false, message: `Invalid status: ${status}` });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Authorization check
    if (req.user.role === 'customer' && order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    if (req.user.role === 'technician' && order.technicianUser?.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    // Validate status transition
    const currentStatus = order.status;
    const statusFlow = {
      pending: ['assigned', 'cancelled'],
      assigned: ['in_progress', 'pending', 'cancelled'],
      in_progress: ['completed', 'cancelled'],
      completed: [],
      cancelled: [],
    };

    if (!statusFlow[currentStatus]?.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot transition from ${currentStatus} to ${status}`,
      });
    }

    // Update status
    order.status = status;
    if (status === 'completed') {
      order.completedAt = new Date();
      order.paymentStatus = 'collected';
    }

    pushStatusHistory(order, status, note || '');

    await order.save();

    res.json({
      success: true,
      message: 'Order status updated',
      data: formatOrderForCustomer(order),
    });
  } catch (error) {
    next(error);
  }
};

// Get available orders for technician (near them)
const getAvailableOrders = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can access this endpoint',
      });
    }

    const { radius = 50 } = req.query; // radius in km
    const page = parseInt(req.query.page) || 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    // Get technician's location
    const techLat = req.user.lastLat;
    const techLng = req.user.lastLng;

    let orders;
    if (techLat != null && techLng != null) {
      // Find nearby orders
      orders = await Order.find({ status: 'pending' })
        .populate('user', 'name phone')
        .sort({ createdAt: -1 });

      // Filter by distance and sort
      orders = orders
        .map((order) => {
          const distance = haversineKm(techLat, techLng, order.serviceLat, order.serviceLng);
          return { order, distance };
        })
        .filter(({ distance }) => distance <= radius)
        .sort((a, b) => a.distance - b.distance)
        .slice(skip, skip + limit)
        .map(({ order }) => formatOrderForTech(order, req.user));
    } else {
      // No location, return recent pending orders
      orders = await Order.find({ status: 'pending' })
        .populate('user', 'name phone')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);

      orders = orders.map((order) => formatOrderForTech(order, req.user));
    }

    res.json({
      success: true,
      count: orders.length,
      page,
      data: orders,
    });
  } catch (error) {
    next(error);
  }
};

// Get technician's active orders
const getTechnicianOrders = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can access this endpoint',
      });
    }

    const { status } = req.query;
    let query = { technicianUser: req.user._id };

    if (status) {
      query.status = status;
    }

    const orders = await Order.find(query)
      .populate('user', 'name phone address')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      data: orders.map((order) => formatOrderForTech(order, req.user)),
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getOrders,
  createOrder,
  getOrderById,
  updateOrderStatus,
};

