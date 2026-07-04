require('dotenv').config();
const { Cashfree, CFEnvironment } = require("cashfree-pg");

async function testPayment() {
  console.log("Testing Cashfree Integration...");
  console.log("App ID Configured:", !!process.env.CASHFREE_APP_ID);
  
  if (!process.env.CASHFREE_APP_ID) {
    console.error("❌ ERROR: CASHFREE_APP_ID is not set in .env!");
    return;
  }

  Cashfree.XClientId = process.env.CASHFREE_APP_ID;
  Cashfree.XClientSecret = process.env.CASHFREE_SECRET_KEY;
  Cashfree.XEnvironment = process.env.CASHFREE_ENVIRONMENT === 'production' 
    ? CFEnvironment.PRODUCTION 
    : CFEnvironment.SANDBOX;

  const cashfree = new Cashfree();

  try {
    var request = {
      "order_amount": 100,
      "order_currency": "INR",
      "order_id": `test_order_${Date.now()}`,
      "customer_details": {
        "customer_id": "test_customer_123",
        "customer_phone": "9999999999",
      }
    };
    
    console.log("Sending request to Cashfree...");
    const response = await cashfree.PGCreateOrder("2023-08-01", request);
    
    console.log("✅ SUCCESS! Cashfree returned:");
    console.log("Payment Session ID:", response.data.payment_session_id);
    console.log("Order ID:", response.data.order_id);
    console.log("Order Status:", response.data.order_status);
  } catch (error) {
    console.error("❌ ERROR: Cashfree request failed.");
    console.error(error?.response?.data || error.message);
  }
}

testPayment();
