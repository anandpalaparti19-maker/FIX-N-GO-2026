# Fix-N-Go: Professional Mobile Repair Platform

Fix-N-Go is a comprehensive solution for on-demand mobile repair services, featuring dedicated applications for Customers and Technicians, managed by a robust administrative backend.

## 🚀 Project Overview

This repository follows a monorepo structure containing all components of the Fix-N-Go ecosystem:

- **`fixngo/backend/`**: Node.js/Express API with MongoDB, handling authentication, bookings, and real-time updates.
- **`fixngo/apps/customer_app/`**: Flutter application for users to book repairs and track service progress.
- **`fixngo/apps/technician_app/`**: Flutter application for field technicians to manage service requests.
- **`fixngo/apps/admin_panel/`**: Web dashboard for platform management and analytics.

## 🛠 Tech Stack

- **Frontend**: Flutter (Cross-platform Mobile), React/Node (Admin)
- **Backend**: Node.js, Express.js
- **Database**: MongoDB (Mongoose ODM)
- **Real-time**: Socket.io for live tracking
- **Infrastructure**: Redis (Caching), Stripe (Payments), Twilio (SMS Notifications)

## 🚦 Quick Start[FixNGo-Customer-Debug.apk](fixngo/FixNGo-Customer-Debug.apk)

### 1. Backend Setup
```bash
cd fixngo/backend
npm install
npm run dev
```
*API Base URL: `http://localhost:5000`*

### 2. Flutter Apps Setup
```bash
cd fixngo/apps/customer_app
flutter pub get
flutter run
```
*Note: For Android Emulators, use `10.0.2.2:5000` to access the local backend.*

---
© 2026 Fix-N-Go Private Limited. All rights reserved.

# FIX-N-GO-2026
