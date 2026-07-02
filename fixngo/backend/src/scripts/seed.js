const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Service = require('../models/serviceModel');
const User = require('../models/userModel');
const Order = require('../models/orderModel');
const bcrypt = require('bcryptjs');
const { technicianCut, pushStatusHistory, assignServiceCoords, HUB_LAT, HUB_LNG } = require('../utils/orderHelpers');

const services = [
  { title: 'Screen Replacement', description: 'Broken screen, touchscreen or glass repair', price: 999 },
  { title: 'Battery Repair', description: 'Battery replacement and power issues', price: 799 },
  { title: 'Camera Repair', description: 'Camera lens and functionality repair', price: 899 },
  { title: 'Software Fix', description: 'Software troubleshooting and hang fixes', price: 499 },
];

const technicians = [
  { name: 'Ravi Kumar', emoji: '🛠️', rating: 4.9, experience: '8 years', eta: '12 min', distance: '2.4 km', jobs: 128 },
  { name: 'Priya Sharma', emoji: '🔧', rating: 4.8, experience: '6 years', eta: '18 min', distance: '3.1 km', jobs: 95 },
];

const run = async () => {
  await connectDB();

  // Use env-configurable seed password — warn about weak defaults
  const seedPassword = process.env.SEED_PASSWORD || 'FixNGo_Dev_2026!';
  if (seedPassword === 'password123' || seedPassword.length < 8) {
    console.warn('⚠️  WARNING: Using a weak seed password. Set SEED_PASSWORD env var for production-grade seeds.');
  }

  await Service.deleteMany();
  await Order.deleteMany();
  await User.deleteMany();

  await Service.insertMany(services);

  const passwordHash = await bcrypt.hash(seedPassword, 10);

  const admin = await User.create({
    name: 'Admin User',
    email: 'admin@fixngo.com',
    password: passwordHash,
    role: 'admin',
  });

  const customer = await User.create({
    name: 'Demo Customer',
    email: 'customer@fixngo.com',
    password: passwordHash,
    role: 'customer',
    phone: '+91 98765 43210',
    address: 'Flat 204, Prestige Towers',
    city: 'Kondapur, Hyderabad',
    pincode: '500084',
  });

  const techRavi = await User.create({
    name: 'Ravi Kumar',
    email: 'tech@fixngo.com',
    password: passwordHash,
    role: 'technician',
    phone: '+91 91234 56780',
    address: 'Kondapur Hub',
    city: 'Hyderabad',
    isOnline: true,
    lastLat: HUB_LAT,
    lastLng: HUB_LNG,
    technicianMeta: {
      emoji: '🛠️',
      rating: 4.9,
      experience: '8 years',
      jobsDone: 127,
      walletBalance: 1240,
      pendingEarnings: 320,
    },
  });

  await User.create({
    name: 'Priya Sharma',
    email: 'priya.tech@fixngo.com',
    password: passwordHash,
    role: 'technician',
    phone: '+91 99887 76655',
    isOnline: true,
    technicianMeta: { emoji: '🔧', rating: 4.8, experience: '6 years', jobsDone: 95 },
  });

  const offeredOrder = await Order.create({
    user: customer._id,
    brand: 'Samsung',
    model: 'Galaxy S24',
    issues: ['Screen Guard'],
    total: 199,
    status: 'assigned',
    technician: techRavi.name,
    technicianUser: techRavi._id,
    dispatchStatus: 'offered',
    technicianEarning: technicianCut(199),
    customerPhone: customer.phone,
    serviceAddress: customer.address,
    city: customer.city,
    pincode: customer.pincode,
    statusHistory: [{ status: 'pending', note: 'Order placed' }],
  });
  pushStatusHistory(offeredOrder, 'assigned', 'Offered to technician');
  assignServiceCoords(offeredOrder, 'offer-4821');
  await offeredOrder.save();

  const completedOrder = await Order.create({
    user: customer._id,
    brand: 'Apple',
    model: 'iPhone 14 Pro',
    issues: ['Screen Repair'],
    total: 999,
    status: 'completed',
    technician: techRavi.name,
    technicianUser: techRavi._id,
    dispatchStatus: 'accepted',
    technicianEarning: technicianCut(999),
    paymentStatus: 'collected',
    customerPhone: customer.phone,
    serviceAddress: customer.address,
    city: customer.city,
    statusHistory: [
      { status: 'pending', note: 'Order placed' },
      { status: 'completed', note: 'Job done' },
    ],
  });
  assignServiceCoords(completedOrder, 'completed-4820');
  await completedOrder.save();

  console.log('Seed data created');
  console.log(`Admin: admin@fixngo.com / ${seedPassword}`);
  console.log(`Customer: customer@fixngo.com / ${seedPassword}`);
  console.log(`Technician: tech@fixngo.com / ${seedPassword}`);
  process.exit(0);
};

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
