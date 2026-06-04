require('dotenv').config();
const express = require('express');
const cors = require('cors');
const colors = require('colors');
const http = require('http');
const connectDB = require('./config/db');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorMiddleware');
const { initializeSocket } = require('./utils/socketService');

const app = express();
const server = http.createServer(app);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

connectDB();

// Initialize Socket.io
initializeSocket(server);
console.log('Socket.io initialized'.cyan);

app.use(routes);

app.use(errorHandler);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`.yellow.bold);
  console.log(`WebSocket server ready on port ${PORT}`.cyan);
});

module.exports = { app, server };
