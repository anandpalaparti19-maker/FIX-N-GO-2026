const axios = require('axios');
const Order = require('../models/orderModel');
const User = require('../models/userModel');

// Google Maps API Key
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || 'AIzaSyDemoKey123'; // Demo key for now

// Calculate distance between two coordinates (Haversine formula)
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

// Get nearby orders for technician
const getNearbyOrders = async (req, res, next) => {
  try {
    const { latitude, longitude, radiusKm = 50 } = req.body;
    const technicianId = req.user._id;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }

    // Get available orders (status = pending, not assigned to anyone)
    const orders = await Order.find({ status: 'pending' });

    // Filter and calculate distances
    const nearbyOrders = orders
      .map((order) => {
        if (order.serviceLat && order.serviceLng) {
          const distance = calculateDistance(
            latitude,
            longitude,
            order.serviceLat,
            order.serviceLng
          );
          return { ...order.toObject(), distance };
        }
        return null;
      })
      .filter((order) => order && order.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance)
      .slice(0, 20);

    res.status(200).json({
      success: true,
      data: {
        orders: nearbyOrders,
        count: nearbyOrders.length,
      },
    });
  } catch (error) {
    console.error('Error getting nearby orders:', error);
    next(error);
  }
};

// Get location suggestions (address autocomplete)
const getLocationSuggestions = async (req, res, next) => {
  try {
    const { input, sessionToken } = req.body;

    if (!input) {
      return res.status(400).json({
        success: false,
        message: 'Input is required',
      });
    }

    try {
      const response = await axios.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        {
          params: {
            input,
            key: GOOGLE_MAPS_API_KEY,
            sessiontoken: sessionToken,
          },
        }
      );

      res.status(200).json({
        success: true,
        data: {
          suggestions: response.data.predictions || [],
        },
      });
    } catch (apiError) {
      // Return mock suggestions if API fails
      res.status(200).json({
        success: true,
        data: {
          suggestions: [
            {
              description: input,
              place_id: 'mock_' + input.replace(/\s/g, '_'),
            },
          ],
          note: 'Using mock suggestions (API not configured)',
        },
      });
    }
  } catch (error) {
    console.error('Error getting location suggestions:', error);
    next(error);
  }
};

// Get place details (lat/long from place ID)
const getPlaceDetails = async (req, res, next) => {
  try {
    const { placeId } = req.body;

    if (!placeId) {
      return res.status(400).json({
        success: false,
        message: 'Place ID is required',
      });
    }

    try {
      const response = await axios.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        {
          params: {
            place_id: placeId,
            key: GOOGLE_MAPS_API_KEY,
            fields: 'geometry,formatted_address,address_components',
          },
        }
      );

      if (response.data.result) {
        const { geometry, formatted_address, address_components } =
          response.data.result;
        res.status(200).json({
          success: true,
          data: {
            latitude: geometry.location.lat,
            longitude: geometry.location.lng,
            address: formatted_address,
            addressComponents: address_components || [],
          },
        });
      } else {
        throw new Error('Place not found');
      }
    } catch (apiError) {
      // Return mock coordinates if API fails
      res.status(200).json({
        success: true,
        data: {
          latitude: 17.3850 + Math.random() * 0.5,
          longitude: 78.4867 + Math.random() * 0.5,
          address: 'Hyderabad, India (Mock)',
          note: 'Using mock coordinates (API not configured)',
        },
      });
    }
  } catch (error) {
    console.error('Error getting place details:', error);
    next(error);
  }
};

// Get route between two coordinates
const getRoute = async (req, res, next) => {
  try {
    const { startLat, startLng, endLat, endLng } = req.body;

    if (!startLat || !startLng || !endLat || !endLng) {
      return res.status(400).json({
        success: false,
        message: 'Start and end coordinates are required',
      });
    }

    try {
      const response = await axios.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        {
          params: {
            origin: `${startLat},${startLng}`,
            destination: `${endLat},${endLng}`,
            key: GOOGLE_MAPS_API_KEY,
          },
        }
      );

      if (response.data.routes && response.data.routes.length > 0) {
        const route = response.data.routes[0];
        const leg = route.legs[0];

        res.status(200).json({
          success: true,
          data: {
            distance: leg.distance.text,
            distanceValue: leg.distance.value, // in meters
            duration: leg.duration.text,
            durationValue: leg.duration.value, // in seconds
            steps: route.overview_polyline.points,
            polyline: route.overview_polyline.points,
          },
        });
      } else {
        throw new Error('No routes found');
      }
    } catch (apiError) {
      // Return mock route if API fails
      const mockDistance = calculateDistance(startLat, startLng, endLat, endLng);
      res.status(200).json({
        success: true,
        data: {
          distance: `${mockDistance.toFixed(1)} km (Mock)`,
          distanceValue: mockDistance * 1000,
          duration: `${Math.ceil(mockDistance * 2)} mins (Mock)`,
          durationValue: Math.ceil(mockDistance * 2 * 60),
          polyline: 'mockPolyline',
          note: 'Using mock route (API not configured)',
        },
      });
    }
  } catch (error) {
    console.error('Error getting route:', error);
    next(error);
  }
};

// Update technician location
const updateTechnicianLocation = async (req, res, next) => {
  try {
    const { latitude, longitude } = req.body;
    const technicianId = req.user._id;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }

    const user = await User.findByIdAndUpdate(
      technicianId,
      {
        $set: {
          lastLat: latitude,
          lastLng: longitude,
          lastLocationUpdate: new Date(),
        },
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Location updated',
      data: {
        location: {
          latitude: user.lastLat,
          longitude: user.lastLng,
        },
      },
    });
  } catch (error) {
    console.error('Error updating location:', error);
    next(error);
  }
};

module.exports = {
  calculateDistance,
  getNearbyOrders,
  getLocationSuggestions,
  getPlaceDetails,
  getRoute,
  updateTechnicianLocation,
};
