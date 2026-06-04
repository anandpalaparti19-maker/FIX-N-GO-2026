const mongoose = require('mongoose');
const User = require('../src/models/userModel');
const Order = require('../src/models/orderModel');
const Rating = require('../src/models/ratingModel');

// Connect to MongoDB
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/fixngo', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ MongoDB Connected for seeding');
    return conn;
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

const seedDatabase = async () => {
  try {
    await connectDB();

    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await User.deleteMany({});
    await Order.deleteMany({});
    await Rating.deleteMany({});
    console.log('✅ Database cleared');

    // Create test customer
    console.log('👤 Creating test customer...');
    const customer = await User.create({
      name: 'Test Customer',
      email: 'customer@test.com',
      password: 'Test123!',
      phone: '9876543210',
      role: 'customer',
      address: '123 Main Street, Hyderabad',
      lastLat: 17.3850,
      lastLng: 78.4867,
    });
    console.log('✅ Customer created:', customer.email);

    // Create test customer 2
    const customer2 = await User.create({
      name: 'Another Customer',
      email: 'customer2@test.com',
      password: 'Test123!',
      phone: '8765432109',
      role: 'customer',
      address: '456 Second Street, Hyderabad',
      lastLat: 17.3900,
      lastLng: 78.4900,
    });
    console.log('✅ Customer 2 created:', customer2.email);

    // Create test technician
    console.log('🔧 Creating test technician...');
    const technician = await User.create({
      name: 'Test Technician',
      email: 'tech@test.com',
      password: 'Test123!',
      phone: '8765432109',
      role: 'technician',
      address: '789 Tech Street, Hyderabad',
      lastLat: 17.4648,
      lastLng: 78.3678,
      isOnline: true,
      technicianMeta: {
        rating: 4.5,
        experience: '5 years',
        jobsDone: 10,
        walletBalance: 5000,
        totalEarnings: 5000,
        specialization: ['Mobile Repair', 'Screen Replacement'],
        emoji: '🔧'
      }
    });
    console.log('✅ Technician created:', technician.email);

    // Create test technician 2
    const technician2 = await User.create({
      name: 'Another Technician',
      email: 'tech2@test.com',
      password: 'Test123!',
      phone: '9876543211',
      role: 'technician',
      address: '321 Another Tech St, Hyderabad',
      lastLat: 17.4700,
      lastLng: 78.3700,
      isOnline: true,
      technicianMeta: {
        rating: 4.8,
        experience: '8 years',
        jobsDone: 25,
        walletBalance: 0,
        totalEarnings: 12000,
        specialization: ['Water Damage', 'Software'],
        emoji: '🛠️'
      }
    });
    console.log('✅ Technician 2 created:', technician2.email);

    // Create test orders
    console.log('📋 Creating test orders...');
    
    const order1 = await Order.create({
      user: customer._id,
      brand: 'Samsung',
      model: 'Galaxy S21',
      issues: ['Screen cracked', 'Battery not working'],
      total: 2500,
      serviceAddress: '123 Main Street, Hyderabad',
      city: 'Hyderabad',
      pincode: '500001',
      serviceLat: 17.3850,
      serviceLng: 78.4867,
      status: 'pending',
      createdAt: new Date(),
    });
    console.log('✅ Order 1 created (pending):', order1._id);

    const order2 = await Order.create({
      user: customer._id,
      brand: 'iPhone',
      model: 'iPhone 13',
      issues: ['Screen replacement needed'],
      total: 3500,
      serviceAddress: '456 Second Street, Hyderabad',
      city: 'Hyderabad',
      pincode: '500002',
      serviceLat: 17.3900,
      serviceLng: 78.4900,
      status: 'assigned',
      dispatchStatus: 'accepted',
      technicianUser: technician._id,
      technician: technician.name,
      createdAt: new Date(),
    });
    console.log('✅ Order 2 created (assigned):', order2._id);

    const order3 = await Order.create({
      user: customer2._id,
      brand: 'OnePlus',
      model: '9 Pro',
      issues: ['Charging port issue'],
      total: 1500,
      serviceAddress: '789 Third Street, Hyderabad',
      city: 'Hyderabad',
      pincode: '500003',
      serviceLat: 17.3700,
      serviceLng: 78.4800,
      status: 'completed',
      technicianUser: technician2._id,
      createdAt: new Date(),
    });
    console.log('✅ Order 3 created (completed):', order3._id);

    // Create test ratings
    console.log('⭐ Creating test ratings...');
    const rating1 = await Rating.create({
      orderId: order3._id,
      customerId: customer2._id,
      technicianId: technician2._id,
      rating: 5,
      review: 'Excellent service! Fixed my phone perfectly.',
      createdAt: new Date(),
    });
    console.log('✅ Rating created:', rating1._id);

    // Print summary
    console.log('\n');
    console.log('═══════════════════════════════════════════');
    console.log('✅ DATABASE SEEDING COMPLETED SUCCESSFULLY');
    console.log('═══════════════════════════════════════════');
    console.log('\n📊 CREATED DATA:');
    console.log('  Customers: 2');
    console.log('    - customer@test.com');
    console.log('    - customer2@test.com');
    console.log('\n  Technicians: 2');
    console.log('    - tech@test.com (rating: 4.5, completed: 10)');
    console.log('    - tech2@test.com (rating: 4.8, completed: 25)');
    console.log('\n  Orders: 3');
    console.log('    - Pending (Samsung Galaxy)');
    console.log('    - Assigned (iPhone 13)');
    console.log('    - Completed (OnePlus 9)');
    console.log('\n  Ratings: 1');
    console.log('    - 5 stars for technician 2');
    console.log('\n🔐 LOGIN CREDENTIALS:');
    console.log('  Password for all users: Test123!');
    console.log('\n📱 API TEST ENDPOINTS:');
    console.log('  GET  http://localhost:5000/api/health');
    console.log('  POST http://localhost:5000/api/auth/login');
    console.log('  GET  http://localhost:5000/api/orders');
    console.log('\n═══════════════════════════════════════════\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedDatabase();
