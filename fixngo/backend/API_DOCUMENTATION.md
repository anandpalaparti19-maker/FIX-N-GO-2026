# Fix-N-Go Backend API Documentation

## Base URL
`http://localhost:5000/api`

## Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

---

## PHASE 1: AUTHENTICATION ENDPOINTS

### 1. Register User
**POST** `/auth/register`
- **Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "customer|technician",
    "phone": "9876543210"
  }
  ```
- **Response**: 201 Created with JWT token

### 2. Login User
**POST** `/auth/login`
- **Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "password123",
    "role": "customer|technician"
  }
  ```
- **Response**: 200 OK with JWT token

### 3. Get Profile
**GET** `/auth/profile`
- **Protected**: Yes
- **Response**: 200 OK with user profile data

### 4. Update Profile
**PATCH** `/auth/profile`
- **Protected**: Yes
- **Body**:
  ```json
  {
    "name": "Updated Name",
    "phone": "9876543210",
    "address": "New Address",
    "city": "Hyderabad",
    "pincode": "500034"
  }
  ```
- **Response**: 200 OK with updated profile

### 5. Forgot Password
**POST** `/auth/forgot-password`
- **Body**:
  ```json
  {
    "email": "john@example.com"
  }
  ```
- **Response**: 200 OK with resetToken and OTP sent to email

### 6. Reset Password
**POST** `/auth/reset-password`
- **Body**:
  ```json
  {
    "resetToken": "token-from-forgot-password",
    "otp": "123456",
    "newPassword": "newpassword123"
  }
  ```
- **Response**: 200 OK

### 7. Send Phone OTP
**POST** `/auth/send-otp`
- **Body**:
  ```json
  {
    "phone": "9876543210"
  }
  ```
- **Response**: 200 OK with OTP sent via SMS

### 8. Verify Phone OTP (Registration)
**POST** `/auth/verify-otp`
- **Body** (for signup):
  ```json
  {
    "phone": "9876543210",
    "otp": "123456",
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "customer|technician"
  }
  ```
- **Response**: 201 Created with JWT token

---

## PHASE 2: ORDER MANAGEMENT ENDPOINTS

### 1. Get My Orders (Customer)
**GET** `/orders`
- **Protected**: Yes (Customer)
- **Query Parameters**:
  - `status`: pending|assigned|in_progress|completed|cancelled
  - `sortBy`: createdAt|updatedAt (default: createdAt)
- **Response**: 200 OK with list of orders

### 2. Create Order
**POST** `/orders`
- **Protected**: Yes (Customer)
- **Body**:
  ```json
  {
    "brand": "iPhone",
    "model": "12 Pro",
    "issues": ["Broken Screen", "Touch Not Working"],
    "total": 2999,
    "description": "Screen is cracked badly",
    "customerPhone": "9876543210",
    "serviceAddress": "123 MG Road",
    "city": "Hyderabad",
    "pincode": "500034",
    "serviceLat": 17.4648,
    "serviceLng": 78.3678,
    "estimatedDateTime": "2024-01-15T14:30:00Z"
  }
  ```
- **Response**: 201 Created with order details

### 3. Get Order by ID
**GET** `/orders/:id`
- **Protected**: Yes
- **Response**: 200 OK with order details

### 4. Update Order Status
**PUT** `/orders/:id/status`
- **Protected**: Yes
- **Body**:
  ```json
  {
    "status": "in_progress|completed|cancelled",
    "note": "Work started"
  }
  ```
- **Response**: 200 OK with updated order

### 5. Technician Accept Order
**PUT** `/orders/:id/accept`
- **Protected**: Yes (Technician only)
- **Response**: 200 OK with accepted order

### 6. Technician Reject Order
**PUT** `/orders/:id/reject`
- **Protected**: Yes (Technician only)
- **Response**: 200 OK

### 7. Get Available Orders (Technician)
**GET** `/orders/technician/available`
- **Protected**: Yes (Technician only)
- **Query Parameters**:
  - `radius`: 50 (km, default)
  - `page`: 1
- **Response**: 200 OK with nearby available orders

### 8. Get My Orders (Technician)
**GET** `/orders/technician/my-orders`
- **Protected**: Yes (Technician only)
- **Query Parameters**:
  - `status`: pending|assigned|in_progress|completed
  - `page`: 1
- **Response**: 200 OK with technician's orders

---

## PHASE 3: PAYMENT ENDPOINTS

### 1. Create Payment Intent
**POST** `/payments/create-intent`
- **Protected**: Yes
- **Body**:
  ```json
  {
    "orderId": "507f1f77bcf86cd799439011",
    "amount": 2999
  }
  ```
- **Response**: 201 Created
  ```json
  {
    "success": true,
    "data": {
      "clientSecret": "pi_xxx_secret_xxx",
      "paymentId": "xxx",
      "amount": 2999,
      "orderId": "xxx"
    }
  }
  ```

### 2. Confirm Payment
**POST** `/payments/confirm`
- **Protected**: Yes
- **Body**:
  ```json
  {
    "paymentIntentId": "pi_xxx",
    "paymentId": "payment_id",
    "orderId": "order_id"
  }
  ```
- **Response**: 200 OK

### 3. Get Payment History
**GET** `/payments/history`
- **Protected**: Yes
- **Query Parameters**:
  - `page`: 1
- **Response**: 200 OK with list of payments

### 4. Get Technician Earnings
**GET** `/payments/earnings`
- **Protected**: Yes (Technician only)
- **Response**: 200 OK
  ```json
  {
    "success": true,
    "data": {
      "totalEarned": 50000,
      "pendingEarnings": 5000,
      "walletBalance": 10000,
      "completedOrders": 25
    }
  }
  ```

### 5. Get Monthly Earnings Breakdown
**GET** `/payments/earnings/monthly`
- **Protected**: Yes (Technician only)
- **Response**: 200 OK with monthly breakdown

### 6. Request Withdrawal
**POST** `/payments/withdraw`
- **Protected**: Yes (Technician only)
- **Body**:
  ```json
  {
    "amount": 5000,
    "bankAccount": "xxxxxxxxxxxx"
  }
  ```
- **Response**: 200 OK

---

## PHASE 4: RATINGS & REVIEWS ENDPOINTS

### 1. Create Rating
**POST** `/ratings/create`
- **Protected**: Yes
- **Body**:
  ```json
  {
    "orderId": "507f1f77bcf86cd799439011",
    "technicianId": "507f1f77bcf86cd799439012",
    "rating": 5,
    "review": "Excellent service!",
    "categories": {
      "professionalism": 5,
      "quality": 5,
      "punctuality": 5,
      "communication": 5
    }
  }
  ```
- **Response**: 201 Created

### 2. Get Technician Ratings
**GET** `/ratings/technician/:technicianId`
- **Query Parameters**:
  - `page`: 1
- **Response**: 200 OK with list of ratings

### 3. Get Technician Average Rating
**GET** `/ratings/technician/:technicianId/average`
- **Response**: 200 OK
  ```json
  {
    "success": true,
    "data": {
      "technicianId": "xxx",
      "technicianName": "John Doe",
      "averageRating": 4.8,
      "totalRatings": 10,
      "distributionCounts": {
        "5": 8,
        "4": 2,
        "3": 0,
        "2": 0,
        "1": 0
      }
    }
  }
  ```

### 4. Get My Ratings
**GET** `/ratings/my-ratings`
- **Protected**: Yes (Customer)
- **Query Parameters**:
  - `page`: 1
- **Response**: 200 OK with customer's given ratings

---

## PHASE 5: TECHNICIAN PROFILE ENDPOINTS

### 1. Get Technician Public Profile
**GET** `/technician-profile/:technicianId`
- **Response**: 200 OK with profile data

### 2. Get Technician Status
**GET** `/technician-profile/:technicianId/status`
- **Response**: 200 OK with online status and location

### 3. Update Technician Profile
**PUT** `/technician-profile/profile/update`
- **Protected**: Yes (Technician only)
- **Body**:
  ```json
  {
    "experience": "8 years",
    "specialization": ["Mobile Repair", "Water Damage"],
    "emoji": "🛠️",
    "documents": {
      "aadhar": "AADHAR-123456",
      "panCard": "PAN-123456",
      "license": "LICENSE-123456"
    }
  }
  ```
- **Response**: 200 OK

### 4. Update Technician Location
**PUT** `/technician-profile/location/update`
- **Protected**: Yes (Technician only)
- **Body**:
  ```json
  {
    "lat": 17.4648,
    "lng": 78.3678,
    "isOnline": true
  }
  ```
- **Response**: 200 OK

### 5. Get Technician Stats
**GET** `/technician-profile/stats/my`
- **Protected**: Yes (Technician only)
- **Response**: 200 OK
  ```json
  {
    "success": true,
    "data": {
      "completedOrders": 25,
      "pendingOrders": 2,
      "averageRating": 4.8,
      "totalRatings": 10,
      "totalEarnings": 50000,
      "pendingEarnings": 5000,
      "walletBalance": 10000
    }
  }
  ```

---

## Error Responses

All errors follow this format:
```json
{
  "success": false,
  "message": "Error description"
}
```

### Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Server Error

---

## Testing with Postman

1. **Register** → Get token
2. **Login** → Get token
3. **Create Order** → Get orderId
4. **Accept Order** (as technician)
5. **Update Status** → Mark as in_progress
6. **Create Payment Intent** → Get clientSecret
7. **Confirm Payment** → Mark as completed
8. **Create Rating** → Rate the service
9. **Get Technician Stats** → See earnings

---

## Environment Variables Required

```
MONGO_URI=mongodb://127.0.0.1:27017/fixngo
JWT_SECRET=fixngo-secret
NODE_ENV=development
PORT=5000

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890

STRIPE_SECRET_KEY=sk_test_your-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key

REDIS_URL=redis://localhost:6379
```
