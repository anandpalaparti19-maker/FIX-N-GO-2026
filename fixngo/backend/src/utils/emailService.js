const nodemailer = require('nodemailer');

// Create transporter - use mock if credentials not provided
let transporter = null;

if (process.env.SMTP_USER && process.env.SMTP_PASS) {
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: process.env.SMTP_PORT || 587,
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
  console.log('✓ Email service initialized');
} else {
  // Create test transporter for development
  transporter = nodemailer.createTransport({
    host: 'localhost',
    port: 1025,
    ignoreTLS: true,
  });
  console.log('⚠ Email credentials not configured. Using mock email mode.');
}

const sendPasswordResetEmail = async (email, otp, userName) => {
  try {
    console.log(`Sending password reset email to ${email}`);

    const mailOptions = {
      from: process.env.SMTP_USER || 'noreply@fixngo.com',
      to: email,
      subject: 'Fix-N-Go: Password Reset OTP',
      html: `
        <h2>Password Reset Request</h2>
        <p>Hi ${userName},</p>
        <p>You have requested to reset your password. Use the OTP below to reset your password:</p>
        <h3 style="background-color: #f0f0f0; padding: 10px; border-radius: 5px; text-align: center; font-family: monospace;">
          ${otp}
        </h3>
        <p><strong>This OTP is valid for 10 minutes.</strong></p>
        <p>If you did not request a password reset, please ignore this email.</p>
        <hr />
        <p style="color: #666; font-size: 12px;">Fix-N-Go - Service Booking Platform</p>
      `,
    };

    if (!process.env.SMTP_USER) {
      console.log(`[MOCK EMAIL] Password reset OTP for ${email}: ${otp}`);
      return { success: true, message: 'Reset email sent (mock mode)' };
    }

    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent:', info.response);
    return { success: true, message: 'Reset email sent' };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const generateResetToken = () => {
  return require('crypto').randomBytes(32).toString('hex');
};

module.exports = {
  sendPasswordResetEmail,
  generateOTP,
  generateResetToken,
  transporter,
};
