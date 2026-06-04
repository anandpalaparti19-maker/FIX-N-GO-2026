const express = require('express');
const {
  createRating,
  getTechnicianRatings,
  getMyRatings,
  getTechnicianAverageRating,
} = require('../controllers/ratingController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Create rating
router.post('/create', protect, createRating);

// Get ratings for a technician
router.get('/technician/:technicianId', getTechnicianRatings);

// Get average rating for a technician
router.get('/technician/:technicianId/average', getTechnicianAverageRating);

// Get my ratings (customer reviews given)
router.get('/my-ratings', protect, getMyRatings);

module.exports = router;
