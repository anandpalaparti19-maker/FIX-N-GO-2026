const express = require('express');
const router = express.Router();
const { protect: authMiddleware } = require('../middleware/authMiddleware');
const {
  getNearbyOrders,
  getLocationSuggestions,
  getPlaceDetails,
  getRoute,
  updateTechnicianLocation,
} = require('../controllers/locationController');

// Location routes
router.post('/nearby-orders', authMiddleware, getNearbyOrders);
router.post('/suggestions', getLocationSuggestions);
router.post('/place-details', getPlaceDetails);
router.post('/route', getRoute);
router.post('/update-location', authMiddleware, updateTechnicianLocation);

module.exports = router;
