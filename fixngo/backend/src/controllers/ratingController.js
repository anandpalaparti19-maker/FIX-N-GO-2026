const Rating = require('../models/ratingModel');
const Order = require('../models/orderModel');
const Technician = require('../models/technicianModel');

// Create a rating/review
const createRating = async (req, res, next) => {
  try {
    const { orderId, technicianId, rating, review, categories } = req.body;

    if (!orderId || !technicianId || !rating) {
      return res.status(400).json({
        success: false,
        message: 'Order ID, technician ID, and rating are required',
      });
    }

    if (rating < 1 || rating > 5 || !Number.isInteger(rating)) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be an integer between 1 and 5',
      });
    }

    // Verify order exists and belongs to customer
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to rate this order',
      });
    }

    // Check if order is completed
    if (order.status !== 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Can only rate completed orders',
      });
    }

    // QA FIX: Use findOneAndUpdate with upsert to prevent double-rating race conditions
    const newRating = await Rating.findOneAndUpdate(
      { orderId },
      {
        $setOnInsert: {
          orderId,
          customerId: req.user._id,
          technicianId,
          rating,
          review: review || '',
          categories: categories || {},
        }
      },
      { upsert: true, new: true, rawResult: true }
    );

    if (!newRating.lastErrorObject.updatedExisting && newRating.value) {
      // If it's a brand new rating, update technician stats via aggregation to avoid TOCTOU
      const stats = await Rating.aggregate([
        { $match: { technicianId: technicianId } },
        { $group: { _id: null, avgRating: { $avg: '$rating' }, total: { $sum: 1 } } }
      ]);
      
      const averageRating = stats.length > 0 ? stats[0].avgRating.toFixed(1) : rating.toFixed(1);
      const totalRatings = stats.length > 0 ? stats[0].total : 1;

      await Technician.findByIdAndUpdate(
        technicianId,
        {
          'technicianMeta.averageRating': averageRating,
          'technicianMeta.totalRatings': totalRatings,
        }
      );
    } else if (newRating.lastErrorObject.updatedExisting) {
      return res.status(400).json({
        success: false,
        message: 'This order has already been rated',
      });
    }

    res.status(201).json({
      success: true,
      message: 'Rating created successfully',
      data: newRating.value,
    });
  } catch (error) {
    next(error);
  }
};

// Get all ratings for a technician
const getTechnicianRatings = async (req, res, next) => {
  try {
    const { technicianId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    // Get technician details
    const technician = await Technician.findById(technicianId);
    if (!technician || technician.role !== 'technician') {
      return res.status(404).json({
        success: false,
        message: 'Technician not found',
      });
    }

    // Get ratings
    const ratings = await Rating.find({ technicianId })
      .populate('customerId', 'name phone')
      .populate('orderId', 'brand model issues total')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Rating.countDocuments({ technicianId });

    res.json({
      success: true,
      technician: {
        _id: technician._id,
        name: technician.name,
        phone: technician.phone,
        averageRating: technician.technicianMeta?.averageRating || 0,
        totalRatings: technician.technicianMeta?.totalRatings || 0,
      },
      count: ratings.length,
      total,
      pages: Math.ceil(total / limit),
      page,
      data: ratings.map((r) => ({
        _id: r._id,
        rating: r.rating,
        review: r.review,
        categories: r.categories,
        customer: r.customerId,
        order: r.orderId,
        createdAt: r.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// Get customer's ratings (reviews given)
const getMyRatings = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    const ratings = await Rating.find({ customerId: req.user._id })
      .populate('technicianId', 'name phone technicianMeta')
      .populate('orderId', 'brand model issues total')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Rating.countDocuments({ customerId: req.user._id });

    res.json({
      success: true,
      count: ratings.length,
      total,
      pages: Math.ceil(total / limit),
      page,
      data: ratings.map((r) => ({
        _id: r._id,
        technician: r.technicianId,
        order: r.orderId,
        rating: r.rating,
        review: r.review,
        categories: r.categories,
        createdAt: r.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// Get average rating for a technician
const getTechnicianAverageRating = async (req, res, next) => {
  try {
    const { technicianId } = req.params;

    const technician = await Technician.findById(technicianId);
    if (!technician || technician.role !== 'technician') {
      return res.status(404).json({
        success: false,
        message: 'Technician not found',
      });
    }

    const ratings = await Rating.find({ technicianId });

    const averageRating =
      ratings.length > 0 ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1) : 0;

    res.json({
      success: true,
      data: {
        technicianId,
        technicianName: technician.name,
        averageRating: parseFloat(averageRating),
        totalRatings: ratings.length,
        distributionCounts: {
          5: ratings.filter((r) => r.rating === 5).length,
          4: ratings.filter((r) => r.rating === 4).length,
          3: ratings.filter((r) => r.rating === 3).length,
          2: ratings.filter((r) => r.rating === 2).length,
          1: ratings.filter((r) => r.rating === 1).length,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createRating,
  getTechnicianRatings,
  getMyRatings,
  getTechnicianAverageRating,
};
