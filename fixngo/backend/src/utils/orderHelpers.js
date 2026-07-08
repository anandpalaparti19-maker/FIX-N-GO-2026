const HUB_LAT = 17.4648;
const HUB_LNG = 78.3678;

const defaultChecklist = (issues = []) => {
  const items = [
    { key: 'inspect', label: 'Inspect device', done: false },
    { key: 'repair', label: 'Complete repair/service', done: false },
    { key: 'test', label: 'Test and verify', done: false },
    { key: 'payment', label: 'Collect payment', done: false },
  ];
  if (issues.length > 0) {
    items[1].label = `Service: ${issues[0]}`;
  }
  return items;
};

const technicianCut = (total) => Math.round((total / 1.1) * 0.9);

const pushStatusHistory = (order, status, note = '') => {
  if (!order.statusHistory) order.statusHistory = [];
  order.statusHistory.push({ status, note, at: new Date() });
};

const haversineKm = (lat1, lon1, lat2, lon2) => {
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

/** Assign customer service coordinates near Hyderabad hub when missing. */
const assignServiceCoords = (order, seed = '') => {
  if (order.serviceLat != null && order.serviceLng != null) return;
  const key = seed || order._id?.toString() || String(Date.now());
  const hash = key.split('').reduce((s, c) => s + c.charCodeAt(0), 0);
  const angle = (hash % 360) * (Math.PI / 180);
  const km = 0.25 + (hash % 60) / 100;
  order.serviceLat = HUB_LAT + (km / 111) * Math.cos(angle);
  order.serviceLng = HUB_LNG + (km / (111 * Math.cos((HUB_LAT * Math.PI) / 180))) * Math.sin(angle);
};

const formatOrderForTech = (order, technician = null) => {
  const customer = order.user;
  const shortId = order._id.toString().slice(-4).toUpperCase();
  const lat = order.serviceLat;
  const lng = order.serviceLng;
  let distanceKm = null;
  if (
    technician?.lastLat != null &&
    technician?.lastLng != null &&
    lat != null &&
    lng != null
  ) {
    distanceKm = Math.round(haversineKm(technician.lastLat, technician.lastLng, lat, lng) * 10) / 10;
  }

  return {
    _id: order._id,
    jobId: `#${shortId}`,
    brand: order.brand,
    model: order.model,
    issues: order.issues,
    title: order.issues[0] || 'Repair service',
    serviceType: order.issues[0] || 'Repair service',
    device: `${order.brand} ${order.model}`,
    deviceModel: `${order.brand} ${order.model}`,
    customerName: customer?.name || 'Customer',
    customerPhone: order.customerPhone || customer?.phone || '',
    serviceAddress: order.serviceAddress,
    location: { address: order.serviceAddress },
    city: order.city,
    pincode: order.pincode,
    serviceLat: lat,
    serviceLng: lng,
    distanceKm,
    distance: distanceKm,
    total: order.total,
    earning: order.technicianEarning || technicianCut(order.total),
    estimatedPrice: order.total,
    status: order.status,
    dispatchStatus: order.dispatchStatus,
    checklist: order.checklist,
    paymentStatus: order.paymentStatus,
    createdAt: order.createdAt,
    updatedAt: order.updatedAt,
  };
};

module.exports = {
  HUB_LAT,
  HUB_LNG,
  defaultChecklist,
  technicianCut,
  pushStatusHistory,
  haversineKm,
  assignServiceCoords,
  formatOrderForTech,
};
