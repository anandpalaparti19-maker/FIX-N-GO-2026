const mongoose = require('mongoose');
const Order = require('./src/models/orderModel');

const formatOrderForCustomer = (order) => {
  const tech = order.technicianUser;
  return {
    ...order.toObject(),
    technicianName: order.technician || tech?.name || '',
    technicianRating: tech?.technicianMeta?.rating,
    technicianPhone: tech?.phone || '',
    technicianLat: tech?.lastLat || null,
    technicianLng: tech?.lastLng || null,
    statusHistory: order.statusHistory || [],
  };
};

mongoose.connect('mongodb://localhost:27017/fixngo')
  .then(async () => {
    const order = await Order.findOne({ status: 'in_progress' });
    if(order) {
       const formatted = formatOrderForCustomer(order);
       console.log('Formatted Order OTP:', formatted.completionOtp);
       console.log('Full formatted keys:', Object.keys(formatted));
    } else {
       console.log('No in_progress order found');
    }
    mongoose.disconnect();
  });
