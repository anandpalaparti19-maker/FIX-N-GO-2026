const Service = require('../models/serviceModel');

const getServices = async (req, res, next) => {
  try {
    const services = await Service.find().sort({ title: 1 });
    res.json(services);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getServices,
};
