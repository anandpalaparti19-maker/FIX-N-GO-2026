const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/userModel');
const Customer = require('../models/customerModel');
const Technician = require('../models/technicianModel');
const Admin = require('../models/adminModel');

dotenv.config({ path: '../.env' }); // or whichever path correctly loads env

const migrate = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/fixngo', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to MongoDB');

    const users = await User.find({});
    console.log(`Found ${users.length} users to migrate.`);

    for (const user of users) {
      const userData = user.toObject();
      const { _id, ...rest } = userData;
      
      // Preserve the same ObjectId so relationships (Orders) don't break
      if (user.role === 'customer') {
        const customerExists = await Customer.findById(_id);
        if (!customerExists) {
          await Customer.create({ _id, ...rest });
          console.log(`Migrated customer: ${user.email}`);
        }
      } else if (user.role === 'technician') {
        const techExists = await Technician.findById(_id);
        if (!techExists) {
          await Technician.create({ _id, ...rest });
          console.log(`Migrated technician: ${user.email}`);
        }
      } else if (user.role === 'admin') {
        const adminExists = await Admin.findById(_id);
        if (!adminExists) {
          await Admin.create({ _id, ...rest });
          console.log(`Migrated admin: ${user.email}`);
        }
      }
    }

    console.log('Migration complete!');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
};

migrate();
