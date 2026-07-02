import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Orders from './pages/Orders';
import Technicians from './pages/Technicians';
import Customers from './pages/Customers';
import Services from './pages/Services';
import Settings from './pages/Settings';
import Withdrawals from './pages/Withdrawals';
import LiveMap from './pages/LiveMap';
import Analytics from './pages/Analytics';
import Disputes from './pages/Disputes';
import Notifications from './pages/Notifications';
import './index.css';

// ── App ───────────────────────────────────────────────────────────────────────
function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('adminToken'));

  if (!isAuthenticated) {
    return <Login setAuth={setIsAuthenticated} />;
  }

  return (
    <Router>
      <div className="app-container">
        <Sidebar />
        <main className="main-content">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/live-map" element={<LiveMap />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/customers" element={<Customers />} />
            <Route path="/technicians" element={<Technicians />} />
            <Route path="/services" element={<Services />} />
            <Route path="/disputes" element={<Disputes />} />
            <Route path="/withdrawals" element={<Withdrawals />} />
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/settings" element={<Settings />} />
            <Route path="*" element={<Navigate to="/" />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;

