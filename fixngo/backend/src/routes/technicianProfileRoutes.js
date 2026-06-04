const express = require('express');
const {
  getTechnicianProfile,
  updateTechnicianProfile,
  updateTechnicianLocation,
  getTechnicianStatus,
  getTechnicianStats,
} = require('../controllers/technicianProfileController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

const router = express.Router();

// Get technician public profile
router.get('/:technicianId', getTechnicianProfile);

// Get technician status
router.get('/:technicianId/status', getTechnicianStatus);

// Update technician profile (technician only)
router.put('/profile/update', protect, authorize('technician'), updateTechnicianProfile);

// Update technician location (technician only)
router.put('/location/update', protect, authorize('technician'), updateTechnicianLocation);

// Get technician stats (technician only)
router.get('/stats/my', protect, authorize('technician'), getTechnicianStats);

module.exports = router;
