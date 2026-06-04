const User = require('../models/userModel');
const Order = require('../models/orderModel');
const Rating = require('../models/ratingModel');

// Get technician public profile
const getTechnicianProfile = async (req, res, next) => {
  try {
    const { technicianId } = req.params;

    const technician = await User.findById(technicianId);

    if (!technician || technician.role !== 'technician') {
      return res.status(404).json({
        success: false,
        message: 'Technician not found',
      });
    }

    // Get ratings
    const ratings = await Rating.find({ technicianId });
    const averageRating =
      ratings.length > 0
        ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1)
        : 0;

    // Get completed jobs count
    const completedJobs = await Order.countDocuments({
      technicianUser: technicianId,
      status: 'completed',
    });

    res.json({
      success: true,
      data: {
        _id: technician._id,
        name: technician.name,
        phone: technician.phone,
        city: technician.city,
        address: technician.address,
        isOnline: technician.isOnline,
        technicianMeta: {
          emoji: technician.technicianMeta?.emoji || '🛠️',
          rating: averageRating,
          experience: technician.technicianMeta?.experience || '',
          jobsDone: completedJobs,
          specialization: technician.technicianMeta?.specialization || [],
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// Update technician profile
const updateTechnicianProfile = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can update their profile',
      });
    }

    const { experience, specialization, emoji, documents } = req.body;

    const technician = await User.findById(req.user._id);
    if (!technician) {
      return res.status(404).json({
        success: false,
        message: 'Technician not found',
      });
    }

    // Update fields
    if (experience) technician.technicianMeta.experience = experience;
    if (emoji) technician.technicianMeta.emoji = emoji;

    if (specialization && Array.isArray(specialization)) {
      technician.technicianMeta.specialization = specialization;
    }

    if (documents) {
      technician.technicianMeta.documents = {
        ...technician.technicianMeta.documents,
        ...documents,
      };
    }

    await technician.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        _id: technician._id,
        name: technician.name,
        email: technician.email,
        phone: technician.phone,
        city: technician.city,
        address: technician.address,
        technicianMeta: technician.technicianMeta,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Update technician location
const updateTechnicianLocation = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can update location',
      });
    }

    const { lat, lng, isOnline } = req.body;

    if (lat === undefined || lng === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }

    const technician = await User.findByIdAndUpdate(
      req.user._id,
      {
        lastLat: parseFloat(lat),
        lastLng: parseFloat(lng),
        ...(isOnline !== undefined && { isOnline }),
      },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Location updated',
      data: {
        lastLat: technician.lastLat,
        lastLng: technician.lastLng,
        isOnline: technician.isOnline,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get technician availability status
const getTechnicianStatus = async (req, res, next) => {
  try {
    const technician = await User.findById(req.params.technicianId);

    if (!technician || technician.role !== 'technician') {
      return res.status(404).json({
        success: false,
        message: 'Technician not found',
      });
    }

    res.json({
      success: true,
      data: {
        _id: technician._id,
        name: technician.name,
        isOnline: technician.isOnline,
        lastLat: technician.lastLat,
        lastLng: technician.lastLng,
        lastUpdated: technician.updatedAt,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get technician stats
const getTechnicianStats = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can access their stats',
      });
    }

    const technician = await User.findById(req.user._id);

    // Get various stats
    const completedOrders = await Order.countDocuments({
      technicianUser: req.user._id,
      status: 'completed',
    });

    const pendingOrders = await Order.countDocuments({
      technicianUser: req.user._id,
      status: { $in: ['pending', 'assigned', 'in_progress'] },
    });

    const ratings = await Rating.find({ technicianId: req.user._id });

    const averageRating =
      ratings.length > 0
        ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1)
        : 0;

    const totalEarnings = await Order.aggregate([
      {
        $match: {
          technicianUser: req.user._id,
          status: 'completed',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$technicianEarning' },
        },
      },
    ]);

    res.json({
      success: true,
      data: {
        completedOrders,
        pendingOrders,
        averageRating: parseFloat(averageRating),
        totalRatings: ratings.length,
        totalEarnings: totalEarnings[0]?.total || 0,
        pendingEarnings: technician.technicianMeta?.pendingEarnings || 0,
        walletBalance: technician.technicianMeta?.walletBalance || 0,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTechnicianProfile,
  updateTechnicianProfile,
  updateTechnicianLocation,
  getTechnicianStatus,
  getTechnicianStats,
};
