const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { technicianOnly } = require('../middleware/technicianMiddleware');
const {
  getTechnicianProfile,
  updateTechnicianProfile,
  setOnlineStatus,
  updateLocation,
  getJobs,
  getIncomingOffers,
  getJobById,
  acceptJob,
  declineJob,
  startJob,
  updateChecklist,
  completeJob,
  collectPayment,
  getWallet,
  getDashboard,
} = require('../controllers/technicianAppController');

const router = express.Router();

router.use(protect, technicianOnly);

router.get('/dashboard', getDashboard);
router.get('/profile', getTechnicianProfile);
router.patch('/profile', updateTechnicianProfile);
router.patch('/availability', setOnlineStatus);
router.patch('/location', updateLocation);
router.get('/wallet', getWallet);
router.get('/jobs', getJobs);
router.get('/jobs/offers', getIncomingOffers);
router.get('/jobs/:id', getJobById);
router.post('/jobs/:id/accept', acceptJob);
router.post('/jobs/:id/decline', declineJob);
router.post('/jobs/:id/start', startJob);
router.patch('/jobs/:id/checklist', updateChecklist);
router.post('/jobs/:id/complete', completeJob);
router.post('/jobs/:id/payment', collectPayment);

module.exports = router;
