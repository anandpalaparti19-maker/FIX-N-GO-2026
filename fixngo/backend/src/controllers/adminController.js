const Order = require('../models/orderModel');
const User = require('../models/userModel');
const Service = require('../models/serviceModel');
const Withdrawal = require('../models/withdrawalModel');
const SupportTicket = require('../models/supportTicketModel');
const Customer = require('../models/customerModel');
const Technician = require('../models/technicianModel');
const Admin = require('../models/adminModel');
const Notification = require('../models/notificationModel');
const { logger } = require('../utils/logger');

// ── Stats ─────────────────────────────────────────────────────────────────────
const getStats = async (req, res, next) => {
  try {
    const [orders, users, services, technicians, admins, pending, completed] = await Promise.all([
      Order.countDocuments(),
      User.countDocuments({ role: 'customer' }),
      Service.countDocuments(),
      User.countDocuments({ role: 'technician' }),
      User.countDocuments({ role: 'admin' }),
      Order.countDocuments({ status: 'pending' }),
      Order.countDocuments({ status: 'completed' }),
    ]);
    res.json({ orders, users, services, technicians, admins, pending, completed });
  } catch (error) {
    next(error);
  }
};

// ── Orders ────────────────────────────────────────────────────────────────────
const getAllOrders = async (req, res, next) => {
  try {
    const { status, search, limit = 100 } = req.query;
    const filter = {};
    if (status) filter.status = status;
    if (search) {
      filter.$or = [
        { brand: { $regex: search, $options: 'i' } },
        { model: { $regex: search, $options: 'i' } },
      ];
    }
    const orders = await Order.find(filter)
      .populate('user', 'name email phone')
      .populate('technicianUser', 'name email phone')
      .sort({ createdAt: -1 })
      .limit(Number(limit));
    res.json({ success: true, data: orders });
  } catch (error) {
    next(error);
  }
};

const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const allowed = ['pending', 'assigned', 'in_progress', 'completed', 'cancelled'];
    if (!status || !allowed.includes(status)) {
      return res.status(400).json({ success: false, message: `Status must be one of: ${allowed.join(', ')}` });
    }
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    // QA FIX: If forcing completed, execute financial hooks
    if (status === 'completed' && order.status !== 'completed' && order.technicianUser) {
      const { technicianCut, pushStatusHistory } = require('../utils/orderHelpers');
      const Technician = require('../models/technicianModel');
      
      const earning = order.technicianEarning || technicianCut(order.total);
      order.technicianEarning = earning;
      order.paymentStatus = 'collected';
      pushStatusHistory(order, 'completed', 'Admin forced completion');
      
      await Technician.findByIdAndUpdate(order.technicianUser, {
        $inc: {
          'technicianMeta.walletBalance': earning,
          'technicianMeta.jobsDone': 1
        }
      });
    }

    order.status = status;
    await order.save();
    logger.info('Admin forced order status', { orderId: order._id, status, adminId: req.user._id });
    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

const assignTechnician = async (req, res, next) => {
  try {
    const { orderId, technicianId } = req.body;
    const tech = await User.findOne({ _id: technicianId, role: 'technician' });
    if (!tech) return res.status(404).json({ success: false, message: 'Technician not found' });

    const { technicianCut, defaultChecklist, pushStatusHistory } = require('../utils/orderHelpers');
    const { emitNotification } = require('../utils/mqttService');

    // QA FIX: Use atomic lock to prevent assigning a completed/cancelled order or overwriting assignment
    const order = await Order.findOneAndUpdate(
      { _id: orderId, status: { $in: ['pending', 'assigned'] } },
      {
        $set: {
          technicianUser: tech._id,
          technician: tech.name,
          status: 'assigned',
          dispatchStatus: 'offered',
        }
      },
      { new: true }
    );

    if (!order) {
      return res.status(400).json({ success: false, message: 'Order not found or cannot be assigned (might be completed/cancelled)' });
    }

    order.technicianEarning = technicianCut(order.total);
    if (!order.checklist || order.checklist.length === 0) {
      order.checklist = defaultChecklist(order.issues);
    }
    pushStatusHistory(order, 'assigned', `Admin assigned to ${tech.name}`);
    await order.save();

    emitNotification(tech._id.toString(), {
      type: 'order_assigned',
      title: 'New Job Assigned',
      message: `Admin has assigned you a new job: ${order.brand} ${order.model}`,
      orderId: order._id,
    });

    logger.info('Admin manually assigned technician', { orderId, technicianId, adminId: req.user._id });
    res.json({ success: true, order });
  } catch (error) {
    next(error);
  }
};

// ── Users ─────────────────────────────────────────────────────────────────────
const getAllUsers = async (req, res, next) => {
  try {
    const { role, search } = req.query;
    const filter = {};
    if (role) filter.role = role;
    if (search) filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
    ];
    let users = await User.find(filter);
    users = users.sort((a, b) => b.createdAt - a.createdAt);
    res.json({ success: true, data: users });
  } catch (error) {
    next(error);
  }
};

// ── Technicians ───────────────────────────────────────────────────────────────
const getAllTechnicians = async (req, res, next) => {
  try {
    const technicians = await Technician.find({ role: 'technician' })
      .select('-password')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: technicians });
  } catch (error) {
    next(error);
  }
};

const approveTechnician = async (req, res, next) => {
  try {
    const tech = await User.findOne({ _id: req.params.id, role: 'technician' });
    if (!tech) return res.status(404).json({ success: false, message: 'Technician not found' });
    tech.isApproved = true;
    tech.accountStatus = 'active';
    if (tech.technicianMeta?.verification) {
      tech.technicianMeta.verification.status = 'verified';
      tech.technicianMeta.verification.aadhaarVerified = true;
    }
    tech.isOnline = true;
    await tech.save();
    const { emitNotification } = require('../utils/mqttService');
    emitNotification(tech._id.toString(), {
      type: 'kyc_approved',
      title: 'KYC Approved!',
      message: 'Your documents have been verified. You can now accept jobs.',
    });
    logger.info('Admin approved technician', { techId: tech._id, adminId: req.user._id });
    res.json({ success: true, message: 'Technician approved', data: tech });
  } catch (error) {
    next(error);
  }
};

const suspendTechnician = async (req, res, next) => {
  try {
    const tech = await User.findOne({ _id: req.params.id, role: 'technician' });
    if (!tech) return res.status(404).json({ success: false, message: 'Technician not found' });
    tech.isApproved = false;
    tech.accountStatus = 'suspended';
    if (tech.technicianMeta?.verification) {
      tech.technicianMeta.verification.status = 'rejected';
      tech.technicianMeta.verification.aadhaarVerified = false;
    }
    tech.isOnline = false;
    await tech.save();
    logger.info('Admin suspended technician', { techId: tech._id, adminId: req.user._id });
    res.json({ success: true, message: 'Technician suspended', data: tech });
  } catch (error) {
    next(error);
  }
};

// ── Live Map ──────────────────────────────────────────────────────────────────
const getLiveMap = async (req, res, next) => {
  try {
    const technicians = await Technician.find({
      role: 'technician',
      isOnline: true,
      'location.coordinates': { $exists: true, $ne: [] },
    }).select('name phone profilePhoto location lastLat lastLng isOnline updatedAt technicianMeta.specialization');

    const data = technicians.map((t) => ({
      _id: t._id,
      name: t.name,
      phone: t.phone,
      profilePhoto: t.profilePhoto || null,
      specialization: t.technicianMeta?.specialization || [],
      isOnline: t.isOnline,
      lastSeen: t.updatedAt,
      // Prefer GeoJSON, fall back to lastLat/lastLng
      lat: t.location?.coordinates?.[1] ?? t.lastLat,
      lng: t.location?.coordinates?.[0] ?? t.lastLng,
    }));

    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

// ── Analytics ─────────────────────────────────────────────────────────────────
const getAnalytics = async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    // Daily orders + revenue for the last N days
    const dailyStats = await Order.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          orders: { $sum: 1 },
          revenue: { $sum: '$customerTotal' },
          completed: { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] } },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Orders by status
    const byStatus = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);

    // Top 10 technicians by completed jobs (last 30 days)
    const topTechnicians = await Order.aggregate([
      { $match: { status: 'completed', createdAt: { $gte: since }, technicianUser: { $ne: null } } },
      { $group: { _id: '$technicianUser', jobs: { $sum: 1 }, earned: { $sum: '$technicianEarning' } } },
      { $sort: { jobs: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'tech',
        },
      },
      { $unwind: '$tech' },
      {
        $project: {
          name: '$tech.name',
          phone: '$tech.phone',
          jobs: 1,
          earned: 1,
        },
      },
    ]);

    // Total revenue
    const revenueAgg = await Order.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$customerTotal' } } },
    ]);

    res.json({
      success: true,
      data: {
        dailyStats,
        byStatus,
        topTechnicians,
        totalRevenue: revenueAgg[0]?.total || 0,
        days,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ── Disputes ──────────────────────────────────────────────────────────────────
const getAllDisputes = async (req, res, next) => {
  try {
    const { status } = req.query;
    const filter = {};
    if (status) filter.status = status;
    const tickets = await SupportTicket.find(filter)
      .populate('createdBy', 'name email role')
      .populate('orderId', 'brand model status')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: tickets });
  } catch (error) {
    next(error);
  }
};

const resolveDispute = async (req, res, next) => {
  try {
    const { resolutionNotes, status } = req.body;
    const ticket = await SupportTicket.findById(req.params.id);
    if (!ticket) return res.status(404).json({ success: false, message: 'Ticket not found' });

    ticket.status = status || 'resolved';
    ticket.resolutionNotes = resolutionNotes || '';
    ticket.assignedTo = req.user._id;
    await ticket.save();

    logger.info('Admin resolved dispute', { ticketId: ticket._id, adminId: req.user._id });
    res.json({ success: true, data: ticket });
  } catch (error) {
    next(error);
  }
};

// ── Notifications broadcast ───────────────────────────────────────────────────
const broadcastNotification = async (req, res, next) => {
  try {
    const { title, message, audience = 'all' } = req.body;
    if (!title || !message) {
      return res.status(400).json({ success: false, message: 'title and message are required' });
    }

    const roleFilter =
      audience === 'customers' ? { role: 'customer' }
      : audience === 'technicians' ? { role: 'technician' }
      : { role: { $in: ['customer', 'technician'] } };

    const users = await User.find(roleFilter);
    const { emitNotification } = require('../utils/mqttService');
    const { sendPushToMany } = require('../utils/fcmService');

    const notifications = users.map((u) => ({
      userId: u._id,
      type: 'broadcast',
      title,
      message,
      isRead: false,
    }));

    await Notification.insertMany(notifications, { ordered: false });

    // Push live MQTT notifications to online users
    for (const u of users) {
      emitNotification(u._id.toString(), { type: 'broadcast', title, message, skipPush: true });
    }

    // Send FCM push notifications
    const userIds = users.map((u) => u._id.toString());
    await sendPushToMany(userIds, { title, body: message }, { type: 'broadcast' });

    logger.info('Admin broadcast notification', {
      audience,
      recipientCount: users.length,
      adminId: req.user._id,
    });

    res.json({ success: true, recipientCount: users.length, message: 'Notification broadcast sent' });
  } catch (error) {
    next(error);
  }
};


// ── Customers ─────────────────────────────────────────────────────────────────
const getCustomers = async (req, res, next) => {
  try {
    const { search, status, page = 1, limit = 50 } = req.query;
    const filter = { role: 'customer' };
    if (status) filter.accountStatus = status;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [customers, total] = await Promise.all([
      Customer.find(filter)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Customer.countDocuments(filter),
    ]);

    // Attach order counts
    const customerIds = customers.map((c) => c._id);
    const orderCounts = await Order.aggregate([
      { $match: { user: { $in: customerIds } } },
      { $group: { _id: '$user', total: { $sum: 1 }, completed: { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] } } } },
    ]);
    const countMap = {};
    orderCounts.forEach((o) => { countMap[o._id.toString()] = { total: o.total, completed: o.completed }; });

    const data = customers.map((c) => ({
      ...c.toObject(),
      orderCount: countMap[c._id.toString()]?.total || 0,
      completedOrders: countMap[c._id.toString()]?.completed || 0,
    }));

    res.json({ success: true, data, total, page: Number(page), pages: Math.ceil(total / Number(limit)) });
  } catch (error) {
    next(error);
  }
};

const getCustomerById = async (req, res, next) => {
  try {
    const customer = await User.findOne({ _id: req.params.id, role: 'customer' });
    if (!customer) return res.status(404).json({ success: false, message: 'Customer not found' });

    const orders = await Order.find({ user: customer._id })
      .sort({ createdAt: -1 })
      .limit(20)
      .select('brand model status total createdAt');

    res.json({ success: true, data: { customer, recentOrders: orders } });
  } catch (error) {
    next(error);
  }
};

const updateCustomerStatus = async (req, res, next) => {
  try {
    const { accountStatus } = req.body;
    const allowed = ['active', 'suspended'];
    if (!accountStatus || !allowed.includes(accountStatus)) {
      return res.status(400).json({ success: false, message: `Status must be one of: ${allowed.join(', ')}` });
    }
    const customer = await User.findOne({ _id: req.params.id, role: 'customer' });
    if (!customer) return res.status(404).json({ success: false, message: 'Customer not found' });

    customer.accountStatus = accountStatus;
    await customer.save();
    logger.info('Admin updated customer status', { customerId: customer._id, accountStatus, adminId: req.user._id });
    res.json({ success: true, data: customer });
  } catch (error) {
    next(error);
  }
};

// ── Services CRUD ─────────────────────────────────────────────────────────────
const getAllServices = async (req, res, next) => {
  try {
    const services = await Service.find().sort({ createdAt: -1 });
    res.json({ success: true, data: services });
  } catch (error) {
    next(error);
  }
};

const createService = async (req, res, next) => {
  try {
    const { title, description, price } = req.body;
    if (!title || !description || price == null) {
      return res.status(400).json({ success: false, message: 'title, description, and price are required' });
    }
    const service = await Service.create({ title, description, price: Number(price) });
    logger.info('Admin created service', { serviceId: service._id, title, adminId: req.user._id });
    res.status(201).json({ success: true, data: service });
  } catch (error) {
    next(error);
  }
};

const updateService = async (req, res, next) => {
  try {
    const { title, description, price } = req.body;
    const service = await Service.findById(req.params.id);
    if (!service) return res.status(404).json({ success: false, message: 'Service not found' });

    if (title) service.title = title;
    if (description) service.description = description;
    if (price != null) service.price = Number(price);
    await service.save();

    logger.info('Admin updated service', { serviceId: service._id, adminId: req.user._id });
    res.json({ success: true, data: service });
  } catch (error) {
    next(error);
  }
};

const deleteService = async (req, res, next) => {
  try {
    const service = await Service.findById(req.params.id);
    if (!service) return res.status(404).json({ success: false, message: 'Service not found' });
    await service.deleteOne();
    logger.info('Admin deleted service', { serviceId: req.params.id, adminId: req.user._id });
    res.json({ success: true, message: 'Service deleted' });
  } catch (error) {
    next(error);
  }
};

// ── Platform Settings ─────────────────────────────────────────────────────────
const getSettings = async (req, res, next) => {
  try {
    const os = require('os');
    const mongoose = require('mongoose');

    const [userCount, techCount, orderCount, serviceCount] = await Promise.all([
      User.countDocuments({ role: 'customer' }),
      User.countDocuments({ role: 'technician' }),
      Order.countDocuments(),
      Service.countDocuments(),
    ]);

    res.json({
      success: true,
      data: {
        platform: {
          name: 'Fix-N-Go',
          version: '1.0.0',
          environment: process.env.NODE_ENV || 'development',
        },
        integrations: {
          smtp: { configured: !!(process.env.SMTP_USER && process.env.SMTP_PASS && !process.env.SMTP_USER.includes('your-email')), host: process.env.SMTP_HOST || '' },
          twilio: { configured: !!(process.env.TWILIO_ACCOUNT_SID && !process.env.TWILIO_ACCOUNT_SID.includes('xxxx')) },
          stripe: { configured: !!(process.env.STRIPE_SECRET_KEY && !process.env.STRIPE_SECRET_KEY.includes('xxxx')) },
          mqtt: { configured: !!process.env.MQTT_BROKER_URL, url: process.env.MQTT_BROKER_URL || '' },
          redis: { configured: !!process.env.REDIS_URL, url: process.env.REDIS_URL ? 'Connected' : '' },
        },
        system: {
          nodeVersion: process.version,
          platform: os.platform(),
          uptime: Math.floor(process.uptime()),
          mongoStatus: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
          memoryUsage: Math.round(process.memoryUsage().rss / 1024 / 1024),
        },
        counts: { customers: userCount, technicians: techCount, orders: orderCount, services: serviceCount },
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getStats,
  getAllOrders,
  updateOrderStatus,
  assignTechnician,
  getAllUsers,
  getAllTechnicians,
  approveTechnician,
  suspendTechnician,
  getLiveMap,
  getAnalytics,
  getAllDisputes,
  resolveDispute,
  broadcastNotification,
  getCustomers,
  getCustomerById,
  updateCustomerStatus,
  getAllServices,
  createService,
  updateService,
  deleteService,
  getSettings,
};
