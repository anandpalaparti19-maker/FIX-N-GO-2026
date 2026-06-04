const fs = require('fs');
const path = require('path');
const Order = require('../models/orderModel');

// Upload directory
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Upload photo for service completion
const uploadServicePhoto = async (req, res, next) => {
  try {
    const { orderId } = req.body;
    const technicianId = req.user._id;

    if (!orderId) {
      return res.status(400).json({
        success: false,
        message: 'Order ID is required',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Photo file is required',
      });
    }

    // Verify order exists
    const order = await Order.findById(orderId);
    if (!order) {
      fs.unlinkSync(req.file.path);
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Verify technician owns this order
    if (order.technicianUser?.toString() !== technicianId.toString()) {
      fs.unlinkSync(req.file.path);
      return res.status(403).json({
        success: false,
        message: 'Not authorized to upload photos for this order',
      });
    }

    // Generate unique filename
    const timestamp = Date.now();
    const fileName = `${orderId}_${timestamp}_${req.file.originalname}`;
    const filePath = path.join(uploadDir, fileName);

    // Move file to uploads directory
    fs.renameSync(req.file.path, filePath);

    // Add photo to order's photos array
    const type = req.body.type || 'after'; // default to 'after' repair
    if (!order.photos) {
      order.photos = { before: [], after: [] };
    }

    if (type === 'before') {
      order.photos.before.push(`/uploads/${fileName}`);
    } else {
      order.photos.after.push(`/uploads/${fileName}`);
    }

    await order.save();

    res.status(201).json({
      success: true,
      message: 'Photo uploaded successfully',
      data: {
        photoUrl: `/uploads/${fileName}`,
        fileName: fileName,
        photos: order.photos,
      },
    });
  } catch (error) {
    // Clean up uploaded file if error
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }
    console.error('Error uploading photo:', error);
    next(error);
  }
};

// Get service photos
const getServicePhotos = async (req, res, next) => {
  try {
    const { orderId } = req.params;

    if (!orderId) {
      return res.status(400).json({
        success: false,
        message: 'Order ID is required',
      });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        photos: order.photos || { before: [], after: [] },
      },
    });
  } catch (error) {
    console.error('Error getting photos:', error);
    next(error);
  }
};

// Add service notes
const addServiceNotes = async (req, res, next) => {
  try {
    const { orderId, notes } = req.body;
    const technicianId = req.user._id;

    if (!orderId || !notes) {
      return res.status(400).json({
        success: false,
        message: 'Order ID and notes are required',
      });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (order.technicianUser?.toString() !== technicianId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to add notes for this order',
      });
    }

    order.notes = notes;

    await order.save();

    res.status(200).json({
      success: true,
      message: 'Notes added successfully',
      data: {
        notes: order.notes,
      },
    });
  } catch (error) {
    console.error('Error adding notes:', error);
    next(error);
  }
};

module.exports = {
  uploadServicePhoto,
  getServicePhotos,
  addServiceNotes,
};
