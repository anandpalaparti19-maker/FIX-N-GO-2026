/**
 * One-time migration: Populate GeoJSON `location` field from existing
 * `lastLat`/`lastLng` (Users) and `serviceLat`/`serviceLng` (Orders).
 *
 * This ensures the 2dsphere indexes on User.location and Order.location
 * actually have data to query against.
 *
 * Run: node src/scripts/migrateGeoFields.js
 */
require('dotenv').config();
const mongoose = require('mongoose');
const connectDB = require('../config/db');
const User = require('../models/userModel');
const Order = require('../models/orderModel');

const run = async () => {
  await connectDB();
  console.log('Starting geolocation field migration...\n');

  // ── Migrate Users ──────────────────────────────────────────────────
  const users = await User.find({
    lastLat: { $ne: null },
    lastLng: { $ne: null },
  });

  let usersMigrated = 0;
  for (const user of users) {
    const lat = Number(user.lastLat);
    const lng = Number(user.lastLng);
    if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
      user.location = {
        type: 'Point',
        coordinates: [lng, lat],
      };
      await user.save();
      usersMigrated++;
    }
  }
  console.log(`✅ Users migrated: ${usersMigrated} / ${users.length}`);

  // ── Migrate Orders ─────────────────────────────────────────────────
  const orders = await Order.find({
    serviceLat: { $ne: null },
    serviceLng: { $ne: null },
  });

  let ordersMigrated = 0;
  for (const order of orders) {
    const lat = Number(order.serviceLat);
    const lng = Number(order.serviceLng);
    if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
      order.location = {
        type: 'Point',
        coordinates: [lng, lat],
      };
      await order.save();
      ordersMigrated++;
    }
  }
  console.log(`✅ Orders migrated: ${ordersMigrated} / ${orders.length}`);

  // ── Verify indexes exist ───────────────────────────────────────────
  try {
    const userIndexes = await User.collection.indexes();
    const orderIndexes = await Order.collection.indexes();
    const userHas2d = userIndexes.some((i) => JSON.stringify(i.key).includes('2dsphere'));
    const orderHas2d = orderIndexes.some((i) => JSON.stringify(i.key).includes('2dsphere'));
    console.log(`\n📊 Index check:`);
    console.log(`   User.location 2dsphere index: ${userHas2d ? '✅' : '❌ MISSING'}`);
    console.log(`   Order.location 2dsphere index: ${orderHas2d ? '✅' : '❌ MISSING'}`);
    if (!userHas2d || !orderHas2d) {
      console.log('\n⚠️  Missing indexes will be created automatically when Mongoose connects.');
      console.log('   Restart the server to trigger index creation.');
    }
  } catch (err) {
    console.warn('Could not verify indexes:', err.message);
  }

  console.log('\n✅ Migration complete!');
  process.exit(0);
};

run().catch((error) => {
  console.error('Migration failed:', error);
  process.exit(1);
});
