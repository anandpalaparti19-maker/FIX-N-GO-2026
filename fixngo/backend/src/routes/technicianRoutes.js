const express = require('express');
const { getTechnicians } = require('../controllers/technicianController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', protect, getTechnicians);

module.exports = router;
