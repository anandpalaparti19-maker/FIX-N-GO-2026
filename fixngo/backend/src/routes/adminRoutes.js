const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { adminOnly } = require('../middleware/adminMiddleware');
const {
  getAllOrders,
  updateOrderStatus,
  getStats,
  getAllUsers,
  assignTechnician,
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
} = require('../controllers/adminController');

const router = express.Router();

// All admin routes require auth + admin role
router.use(protect, adminOnly);

// ── Dashboard ────────────────────────────────────────────────────────────────
router.get('/stats', getStats);

// ── Orders ───────────────────────────────────────────────────────────────────
router.get('/orders', getAllOrders);
router.patch('/orders/:id', updateOrderStatus);
router.post('/orders/assign', assignTechnician);

// ── Users ────────────────────────────────────────────────────────────────────
router.get('/users', getAllUsers);

// ── Customers ────────────────────────────────────────────────────────────────
router.get('/customers', getCustomers);
router.get('/customers/:id', getCustomerById);
router.patch('/customers/:id/status', updateCustomerStatus);

// ── Technicians ───────────────────────────────────────────────────────────────
router.get('/technicians', getAllTechnicians);
router.patch('/technicians/:id/approve', approveTechnician);
router.patch('/technicians/:id/suspend', suspendTechnician);

// ── Live Map ──────────────────────────────────────────────────────────────────
router.get('/live-map', getLiveMap);

// ── Analytics ─────────────────────────────────────────────────────────────────
router.get('/analytics', getAnalytics);

// ── Services CRUD ─────────────────────────────────────────────────────────────
router.get('/services', getAllServices);
router.post('/services', createService);
router.put('/services/:id', updateService);
router.delete('/services/:id', deleteService);

// ── Disputes ──────────────────────────────────────────────────────────────────
router.get('/disputes', getAllDisputes);
router.patch('/disputes/:id', resolveDispute);

// ── Notifications ─────────────────────────────────────────────────────────────
router.post('/notifications/broadcast', broadcastNotification);

// ── Settings ──────────────────────────────────────────────────────────────────
router.get('/settings', getSettings);

module.exports = router;

