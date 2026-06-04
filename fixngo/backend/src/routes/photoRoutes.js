const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const { protect: authMiddleware } = require('../middleware/authMiddleware');
const {
  uploadServicePhoto,
  getServicePhotos,
  addServiceNotes,
} = require('../controllers/photoController');

// Configure multer for photo uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../temp'));
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname}`);
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPEG, PNG, and WebP images are allowed'));
    }
  },
});

// Photo routes
router.post(
  '/upload/:orderId',
  authMiddleware,
  upload.single('photo'),
  uploadServicePhoto
);
router.get('/order/:orderId', authMiddleware, getServicePhotos);
router.post('/notes', authMiddleware, addServiceNotes);

module.exports = router;
