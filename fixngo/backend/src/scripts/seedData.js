require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/userModel');
const Order = require('../models/orderModel');
const Service = require('../models/serviceModel');
const Rating = require('../models/ratingModel');

const connectDB = async () => {
  const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/fixngo';
  try {
    await mongoose.connect(uri);
    console.log('MongoDB Connected');
  } catch (error) {
    console.error('DB Connection Error:', error.message);
    process.exit(1);
  }
};

const seedDatabase = async () => {
  try {
    console.log('Starting database seed...');

    // Clear existing data
    await User.deleteMany({});
    await Order.deleteMany({});
    await Service.deleteMany({});
    await Rating.deleteMany({});
    console.log('Cleared existing data');

    // Create customers
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);

    const customers = await User.insertMany([
      {
        name: 'Rajesh Kumar',
        email: 'rajesh@example.com',
        password: hashedPassword,
        role: 'customer',
        phone: '9876543210',
        address: '123 MG Road',
        city: 'Hyderabad',
        pincode: '500034',
      },
      {
        name: 'Priya Singh',
        email: 'priya@example.com',
        password: hashedPassword,
        role: 'customer',
        phone: '9876543211',
        address: '456 Jubilee Hills',
        city: 'Hyderabad',
        pincode: '500033',
      },
      {
        name: 'Amit Patel',
        email: 'amit@example.com',
        password: hashedPassword,
        role: 'customer',
        phone: '9876543212',
        address: '789 Banjara Hills',
        city: 'Hyderabad',
        pincode: '500034',
      },
    ]);
    console.log(`Created ${customers.length} customers`);

    // Create technicians
    const technicians = await User.insertMany([
      {
        name: 'Suresh Reddy',
        email: 'suresh.tech@example.com',
        password: hashedPassword,
        role: 'technician',
        phone: '9988776655',
        address: '999 JNTU Road',
        city: 'Hyderabad',
        pincode: '500072',
        isOnline: true,
        lastLat: 17.4648,
        lastLng: 78.3678,
        technicianMeta: {
          emoji: '🛠️',
          rating: 4.8,
          experience: '8 years',
          jobsDone: 45,
          specialization: ['Mobile Repair', 'Laptop Repair', 'Water Damage'],
          documents: {
            aadhar: 'AADHAR-123456',
            panCard: 'PAN-123456',
            license: 'LICENSE-123456',
          },
          walletBalance: 5000,
          pendingEarnings: 2500,
          totalEarnings: 45000,
        },
      },
      {
        name: 'Vikram Singh',
        email: 'vikram.tech@example.com',
        password: hashedPassword,
        role: 'technician',
        phone: '9988776656',
        address: '222 Ameerpet',
        city: 'Hyderabad',
        pincode: '500073',
        isOnline: true,
        lastLat: 17.35,
        lastLng: 78.47,
        technicianMeta: {
          emoji: '⚡',
          rating: 4.5,
          experience: '5 years',
          jobsDone: 32,
          specialization: ['Phone Screen Repair', 'Battery Replacement'],
          documents: {
            aadhar: 'AADHAR-789012',
            panCard: 'PAN-789012',
            license: 'LICENSE-789012',
          },
          walletBalance: 3000,
          pendingEarnings: 1500,
          totalEarnings: 28000,
        },
      },
      {
        name: 'Mahesh Kumar',
        email: 'mahesh.tech@example.com',
        password: hashedPassword,
        role: 'technician',
        phone: '9988776657',
        address: '333 Kondapur',
        city: 'Hyderabad',
        pincode: '500084',
        isOnline: false,
        lastLat: 17.44,
        lastLng: 78.63,
        technicianMeta: {
          emoji: '🔧',
          rating: 4.6,
          experience: '6 years',
          jobsDone: 38,
          specialization: ['Tablet Repair', 'Desktop Repair'],
          documents: {
            aadhar: 'AADHAR-345678',
            panCard: 'PAN-345678',
            license: 'LICENSE-345678',
          },
          walletBalance: 4000,
          pendingEarnings: 2000,
          totalEarnings: 38000,
        },
      },
    ]);
    console.log(`Created ${technicians.length} technicians`);

    // Create services
    const services = await Service.insertMany([
      {
        title: 'Screen Replacement',
        description: 'Mobile phone screen replacement service',
        price: 2999,
      },
      {
        title: 'Battery Replacement',
        description: 'Battery replacement for all phones',
        price: 1999,
      },
      {
        title: 'Charging Port Repair',
        description: 'Repair or replacement of charging port',
        price: 1599,
      },
      {
        title: 'Water Damage Repair',
        description: 'Water damage repair and drying service',
        price: 3999,
      },
      {
        title: 'Software Issue Fix',
        description: 'Fix software issues and optimization',
        price: 999,
      },
      {
        title: 'Camera Repair',
        description: 'Camera module repair or replacement',
        price: 2499,
      },
      {
        title: 'Speaker/Microphone Repair',
        description: 'Audio jack and speaker repair',
        price: 1499,
      },
      {
        title: 'Button Repair',
        description: 'Power/volume button repair',
        price: 1299,
      },
    ]);
    console.log(`Created ${services.length} services`);

    // Create orders
    const orders = await Order.insertMany([
      {
        user: customers[0]._id,
        brand: 'iPhone',
        model: '12 Pro',
        issues: ['Broken Screen'],
        total: 2999,
        status: 'completed',
        technicianUser: technicians[0]._id,
        technician: technicians[0].name,
        customerPhone: customers[0].phone,
        serviceAddress: customers[0].address,
        city: customers[0].city,
        pincode: customers[0].pincode,
        serviceLat: 17.4648,
        serviceLng: 78.3678,
        paymentStatus: 'collected',
        paymentMethod: 'card',
        technicianEarning: 2099,
        completedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        statusHistory: [
          { status: 'pending', note: 'Order placed', at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
          { status: 'assigned', note: 'Assigned to technician', at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000) },
          { status: 'in_progress', note: 'Work in progress', at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) },
          { status: 'completed', note: 'Work completed', at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
        ],
      },
      {
        user: customers[1]._id,
        brand: 'Samsung',
        model: 'Galaxy S21',
        issues: ['Battery Issue', 'Slow Performance'],
        total: 1999,
        status: 'in_progress',
        technicianUser: technicians[1]._id,
        technician: technicians[1].name,
        customerPhone: customers[1].phone,
        serviceAddress: customers[1].address,
        city: customers[1].city,
        pincode: customers[1].pincode,
        serviceLat: 17.35,
        serviceLng: 78.47,
        paymentStatus: 'pending',
        technicianEarning: 1399,
        statusHistory: [
          { status: 'pending', note: 'Order placed', at: new Date(Date.now() - 2 * 60 * 60 * 1000) },
          { status: 'assigned', note: 'Assigned to technician', at: new Date(Date.now() - 60 * 60 * 1000) },
          { status: 'in_progress', note: 'Work in progress', at: new Date(Date.now() - 30 * 60 * 1000) },
        ],
      },
      {
        user: customers[2]._id,
        brand: 'OnePlus',
        model: '9 Pro',
        issues: ['Charging Port Not Working'],
        total: 1599,
        status: 'pending',
        customerPhone: customers[2].phone,
        serviceAddress: customers[2].address,
        city: customers[2].city,
        pincode: customers[2].pincode,
        serviceLat: 17.48,
        serviceLng: 78.35,
        paymentStatus: 'pending',
        statusHistory: [{ status: 'pending', note: 'Order placed', at: new Date() }],
      },
    ]);
    console.log(`Created ${orders.length} orders`);

    // Create ratings
    const ratings = await Rating.insertMany([
      {
        orderId: orders[0]._id,
        customerId: customers[0]._id,
        technicianId: technicians[0]._id,
        rating: 5,
        review: 'Excellent service! The technician was very professional and quick.',
        categories: {
          professionalism: 5,
          quality: 5,
          punctuality: 5,
          communication: 5,
        },
      },
    ]);
    console.log(`Created ${ratings.length} ratings`);

    // Update technician ratings
    await User.findByIdAndUpdate(technicians[0]._id, {
      'technicianMeta.averageRating': 5.0,
      'technicianMeta.totalRatings': 1,
    });

    console.log('\n✅ Database seeding completed successfully!');
    console.log('\nTest Credentials:');
    console.log('Customer: rajesh@example.com / password123');
    console.log('Technician: suresh.tech@example.com / password123');
    console.log('Admin: (to be created)');

    process.exit(0);
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
};

connectDB().then(() => seedDatabase());
