const User = require('../models/userModel');

const getTechnicians = async (req, res, next) => {
  try {
    const technicians = await User.find({ role: 'technician' })
      .select('name technicianMeta isOnline lastLat lastLng')
      .sort({ 'technicianMeta.rating': -1 });

    res.json({
      success: true,
      data: technicians.map(tech => ({
        _id: tech._id,
        name: tech.name,
        rating: tech.technicianMeta?.rating || 4.8,
        experience: tech.technicianMeta?.experience || '3+ years',
        isOnline: tech.isOnline,
        emoji: tech.technicianMeta?.emoji || '🛠️'
      }))
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTechnicians,
};
