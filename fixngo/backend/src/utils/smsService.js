const twilio = require('twilio');

// Initialize Twilio client - use mock if credentials not provided
let client = null;
if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
  client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
  console.log('✓ Twilio SMS service initialized');
} else {
  console.log('⚠ Twilio credentials not configured. Using mock SMS mode.');
}

const sendOtpSms = async (phoneNumber, otp) => {
  try {
    // Ensure phone number is in E.164 format
    const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+91${phoneNumber}`;

    console.log(`Sending OTP SMS to ${formattedPhone}: ${otp}`);

    // If Twilio is not configured, just log and return success (for development)
    if (!client) {
      console.log(`[MOCK SMS] OTP for ${formattedPhone}: ${otp}`);
      return { success: true, message: 'OTP sent successfully (mock mode)', sid: `mock_${Date.now()}` };
    }

    const message = await client.messages.create({
      body: `Your Fix-N-Go OTP is: ${otp}. This OTP is valid for 5 minutes. Do not share it with anyone.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: formattedPhone,
    });

    console.log('SMS sent:', message.sid);
    return { success: true, message: 'OTP sent successfully', sid: message.sid };
  } catch (error) {
    console.error('SMS send error:', error);
    return { success: false, error: error.message };
  }
};

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

module.exports = {
  sendOtpSms,
  generateOTP,
};
