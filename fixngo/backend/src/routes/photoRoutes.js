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

const crypto = require('crypto');
const ALLOWED_EXTS = ['.jpg', '.jpeg', '.png', '.webp'];

// Configure multer for photo uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../temp'));
  },
  filename: (req, file, cb) => {
    // AUDIT FIX §3.2: Never use file.originalname in path — prevents path traversal
    const ext = path.extname(path.basename(file.originalname)).toLowerCase();
    if (!ALLOWED_EXTS.includes(ext)) {
      return cb(new Error('Invalid file extension'));
    }
    cb(null, `${crypto.randomUUID()}${ext}`);
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
