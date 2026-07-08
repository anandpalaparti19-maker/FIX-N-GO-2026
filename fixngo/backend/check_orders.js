const mongoose = require('mongoose');
const Order = require('./src/models/orderModel');

mongoose.connect('mongodb://localhost:27017/fixngo')
  .then(async () => {
    const orders = await Order.find({ status: 'in_progress' });
    console.log(JSON.stringify(orders, null, 2));
    mongoose.disconnect();
  });
