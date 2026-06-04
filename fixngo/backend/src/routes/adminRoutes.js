const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { adminOnly } = require('../middleware/adminMiddleware');
const {
  getAllOrders,
  updateOrderStatus,
  getStats,
  getAllUsers,
  assignTechnician,
} = require('../controllers/adminController');

const router = express.Router();

router.use(protect, adminOnly);

router.get('/stats', getStats);
router.get('/orders', getAllOrders);
router.patch('/orders/:id', updateOrderStatus);
router.post('/orders/assign', assignTechnician);
router.get('/users', getAllUsers);

module.exports = router;
