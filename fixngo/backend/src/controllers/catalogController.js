const catalog = require('../data/catalog');
const Service = require('../models/serviceModel');

const getCatalog = async (req, res, next) => {
  try {
    const services = await Service.find().sort({ price: 1 });
    const issues = services.map((s) => ({
      name: s.title,
      emoji: issueEmoji(s.title),
      description: s.description,
      price: s.price,
      id: s._id,
    }));

    res.json({
      brands: catalog.brands,
      issues: issues.length ? issues : defaultIssues(),
    });
  } catch (error) {
    next(error);
  }
};

function issueEmoji(title) {
  const t = title.toLowerCase();
  if (t.includes('screen')) return '🧩';
  if (t.includes('battery')) return '🔋';
  if (t.includes('camera')) return '📷';
  return '🌀';
}

function defaultIssues() {
  return [
    { name: 'Screen Replacement', emoji: '🧩', description: 'Broken screen repair', price: 999 },
    { name: 'Battery Repair', emoji: '🔋', description: 'Battery replacement', price: 799 },
    { name: 'Camera Repair', emoji: '📷', description: 'Camera repair', price: 899 },
    { name: 'Software Fix', emoji: '🌀', description: 'Software troubleshooting', price: 499 },
  ];
}

module.exports = { getCatalog };
