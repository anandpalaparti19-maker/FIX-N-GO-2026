require('dotenv').config();
const mongoose = require('mongoose');
const Technician = require('../models/technicianModel');
const { encrypt } = require('../utils/encryption');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/fixngo';

async function migrate() {
  try {
    if (!process.env.ENCRYPTION_KEY) {
      console.error('❌ ENCRYPTION_KEY is not set in environment variables.');
      process.exit(1);
    }

    console.log(`Connecting to MongoDB...`);
    await mongoose.connect(MONGO_URI);
    console.log('Connected.');

    const technicians = await Technician.find({});
    let updatedCount = 0;

    for (const tech of technicians) {
      let needsUpdate = false;

      // Check and encrypt Aadhaar
      if (tech.technicianMeta && tech.technicianMeta.aadhaarNumber) {
        const aadhaar = tech.technicianMeta.aadhaarNumber;
        if (!aadhaar.includes(':')) {
          tech.technicianMeta.aadhaarNumber = encrypt(aadhaar);
          needsUpdate = true;
        }
      }

      // Check and encrypt Bank Account Number
      if (tech.technicianMeta && tech.technicianMeta.bankAccount && tech.technicianMeta.bankAccount.accountNumber) {
        const accNumber = tech.technicianMeta.bankAccount.accountNumber;
        if (!accNumber.includes(':')) {
          tech.technicianMeta.bankAccount.accountNumber = encrypt(accNumber);
          needsUpdate = true;
        }
      }

      // Check and encrypt IFSC Code
      if (tech.technicianMeta && tech.technicianMeta.bankAccount && tech.technicianMeta.bankAccount.ifscCode) {
        const ifsc = tech.technicianMeta.bankAccount.ifscCode;
        if (!ifsc.includes(':')) {
          tech.technicianMeta.bankAccount.ifscCode = encrypt(ifsc);
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        // We use save() here so any pre/post save hooks run if applicable,
        // but we mainly just want to update the document.
        // We should skip validation if it's strict, but encrypting might change format.
        // The model allows Strings, which encrypted values are.
        await Technician.updateOne(
          { _id: tech._id },
          { 
            $set: {
              'technicianMeta.aadhaarNumber': tech.technicianMeta.aadhaarNumber,
              'technicianMeta.bankAccount.accountNumber': tech.technicianMeta.bankAccount.accountNumber,
              'technicianMeta.bankAccount.ifscCode': tech.technicianMeta.bankAccount.ifscCode
            }
          }
        );
        updatedCount++;
        console.log(`Updated technician: ${tech.email}`);
      }
    }

    console.log(`Migration complete. Updated ${updatedCount} technicians.`);
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
