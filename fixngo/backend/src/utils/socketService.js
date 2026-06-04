const socketIO = require('socket.io');
const jwt = require('jsonwebtoken');
const Order = require('../models/orderModel');
const User = require('../models/userModel');

let io;
const connectedUsers = new Map(); // userId -> socket.id mapping

const initializeSocket = (server) => {
  io = socketIO(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // Middleware to verify JWT
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication error: Token missing'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;
      socket.userRole = decoded.role;
      next();
    } catch (err) {
      next(new Error('Authentication error: Invalid token'));
    }
  });

  // Connection handler
  io.on('connection', (socket) => {
    console.log(`User ${socket.userId} connected with socket ${socket.id}`);
    connectedUsers.set(socket.userId, socket.id);

    // User joined
    socket.on('user-online', (data) => {
      console.log(`User ${socket.userId} is online`);
      io.emit('user-status', {
        userId: socket.userId,
        status: 'online',
        timestamp: new Date(),
      });
    });

    // Order status update
    socket.on('order-status-update', async (data) => {
      try {
        const { orderId, status, note } = data;
        const order = await Order.findById(orderId);

        if (!order) {
          socket.emit('error', { message: 'Order not found' });
          return;
        }

        // Verify authorization
        if (
          order.user?.toString() !== socket.userId &&
          order.technicianUser?.toString() !== socket.userId
        ) {
          socket.emit('error', { message: 'Not authorized' });
          return;
        }

        // Update order
        order.status = status;
        if (note) {
          order.statusHistory?.push({
            status: status,
            timestamp: new Date(),
            note: note,
          });
        }
        await order.save();

        // Broadcast to relevant users
        io.emit('order-updated', {
          orderId: orderId,
          status: status,
          note: note,
          timestamp: new Date(),
        });

        console.log(`Order ${orderId} updated to ${status}`);
      } catch (error) {
        console.error('Error updating order status:', error);
        socket.emit('error', { message: 'Error updating order' });
      }
    });

    // Technician location update
    socket.on('location-update', async (data) => {
      try {
        const { latitude, longitude, orderId } = data;

        // Update user location
        await User.findByIdAndUpdate(socket.userId, {
          lastLat: latitude,
          lastLng: longitude,
          lastLocationUpdate: new Date(),
        });

        // Broadcast location to relevant customers
        if (orderId) {
          const order = await Order.findById(orderId);
          if (order && order.user) {
            io.to(connectedUsers.get(order.user.toString()) || '').emit(
              'technician-location',
              {
                technicianId: socket.userId,
                orderId: orderId,
                latitude: latitude,
                longitude: longitude,
                timestamp: new Date(),
              }
            );
          }
        }
      } catch (error) {
        console.error('Error updating location:', error);
      }
    });

    // Order notification
    socket.on('order-notification', (data) => {
      try {
        const { recipientId, type, title, message, orderId } = data;
        const recipientSocketId = connectedUsers.get(recipientId);

        if (recipientSocketId) {
          io.to(recipientSocketId).emit('notification', {
            type: type, // 'order_accepted', 'order_arrived', 'order_completed'
            title: title,
            message: message,
            orderId: orderId,
            timestamp: new Date(),
          });
        }
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });

    // Chat message
    socket.on('chat-message', (data) => {
      try {
        const { recipientId, message, orderId } = data;
        const recipientSocketId = connectedUsers.get(recipientId);

        if (recipientSocketId) {
          io.to(recipientSocketId).emit('chat-message', {
            senderId: socket.userId,
            message: message,
            orderId: orderId,
            timestamp: new Date(),
          });
        }
      } catch (error) {
        console.error('Error sending chat message:', error);
      }
    });

    // Disconnect handler
    socket.on('disconnect', () => {
      console.log(`User ${socket.userId} disconnected`);
      connectedUsers.delete(socket.userId);
      io.emit('user-status', {
        userId: socket.userId,
        status: 'offline',
        timestamp: new Date(),
      });
    });

    // Error handler
    socket.on('error', (error) => {
      console.error(`Socket error for user ${socket.userId}:`, error);
    });
  });

  return io;
};

const emitOrderUpdate = (orderId, data) => {
  if (io) {
    io.emit('order-updated', {
      orderId,
      ...data,
      timestamp: new Date(),
    });
  }
};

const emitNotification = (userId, data) => {
  if (io) {
    const socketId = connectedUsers.get(userId);
    if (socketId) {
      io.to(socketId).emit('notification', {
        ...data,
        timestamp: new Date(),
      });
    }
  }
};

const getConnectedUsers = () => {
  return Array.from(connectedUsers.keys());
};

const isUserOnline = (userId) => {
  return connectedUsers.has(userId.toString());
};

module.exports = {
  initializeSocket,
  emitOrderUpdate,
  emitNotification,
  getConnectedUsers,
  isUserOnline,
};
