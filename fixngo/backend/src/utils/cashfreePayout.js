const axios = require('axios');
const logger = require('./logger');

const getBaseUrl = () => {
  return process.env.CASHFREE_ENVIRONMENT === 'production'
    ? 'https://payout-api.cashfree.com'
    : 'https://payout-gamma.cashfree.com';
};

const getHeaders = () => {
  return {
    'X-Client-Id': process.env.CASHFREE_PAYOUT_CLIENT_ID || process.env.CASHFREE_APP_ID,
    'X-Client-Secret': process.env.CASHFREE_PAYOUT_CLIENT_SECRET || process.env.CASHFREE_SECRET_KEY,
    'Content-Type': 'application/json'
  };
};

/**
 * Get Bearer token for Cashfree Payouts
 */
const authorize = async () => {
  try {
    const response = await axios.post(`${getBaseUrl()}/payout/v1/authorize`, {}, {
      headers: getHeaders()
    });
    if (response.data.status === 'SUCCESS') {
      return response.data.data.token;
    }
    throw new Error(response.data.message || 'Authorization failed');
  } catch (error) {
    logger.error(`Cashfree Authorize Error: ${error.response?.data?.message || error.message}`);
    throw error;
  }
};

/**
 * Add Beneficiary to Cashfree
 */
const addBeneficiary = async (token, user, bankDetails) => {
  const beneId = `tech_${user._id.toString()}`;
  try {
    const response = await axios.post(
      `${getBaseUrl()}/payout/v1/addBeneficiary`,
      {
        beneId,
        name: bankDetails.accountName || user.name,
        email: user.email,
        phone: user.phone || '9999999999',
        bankAccount: bankDetails.accountNumber,
        ifsc: bankDetails.ifscCode,
        address1: 'Not provided',
        city: 'City',
        state: 'State',
        pincode: '000000'
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (response.data.status === 'SUCCESS') {
       return beneId;
    }
    
    if (response.data.message && response.data.message.toLowerCase().includes('already exists')) {
       return beneId;
    }

    throw new Error(response.data.message || 'Failed to add beneficiary');
  } catch (error) {
    if (error.response?.data?.message?.toLowerCase().includes('already exists') || error.response?.data?.subCode === '409') {
      return beneId; // already exists
    }
    logger.error(`Cashfree Add Beneficiary Error: ${error.response?.data?.message || error.message}`);
    throw error;
  }
};

/**
 * Request Transfer
 */
const requestTransfer = async (token, beneId, amount, transferId) => {
  try {
    const response = await axios.post(
      `${getBaseUrl()}/payout/v1/requestTransfer`,
      {
        beneId,
        amount: parseFloat(amount).toFixed(2),
        transferId: transferId, // unique per transfer
        transferMode: 'IMPS',
        remarks: 'Fix-N-Go Withdrawal'
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (response.data.status === 'SUCCESS' || response.data.status === 'PENDING') {
      return { success: true, referenceId: response.data.data?.referenceId };
    }
    
    return { success: false, error: response.data.message || 'Transfer failed' };
  } catch (error) {
    logger.error(`Cashfree Transfer Error: ${error.response?.data?.message || error.message}`);
    return { success: false, error: error.response?.data?.message || error.message };
  }
};

module.exports = {
  authorize,
  addBeneficiary,
  requestTransfer
};
