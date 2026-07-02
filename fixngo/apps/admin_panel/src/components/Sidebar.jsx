import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, ListOrdered, Users, Wrench, LogOut,
  UserCog, Wallet, Map, BarChart2, MessageSquare, Bell,
  Package, Settings,
} from 'lucide-react';

export default function Sidebar() {
  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    window.location.href = '/';
  };

  const navItems = [
    { to: '/', icon: <LayoutDashboard size={20} />, label: 'Dashboard', end: true },
    { to: '/orders', icon: <ListOrdered size={20} />, label: 'Orders' },
    { to: '/live-map', icon: <Map size={20} />, label: 'Live Map' },
    { to: '/analytics', icon: <BarChart2 size={20} />, label: 'Analytics' },
    { to: '/customers', icon: <Users size={20} />, label: 'Customers' },
    { to: '/technicians', icon: <UserCog size={20} />, label: 'Technicians' },
    { to: '/services', icon: <Package size={20} />, label: 'Services' },
    { to: '/disputes', icon: <MessageSquare size={20} />, label: 'Disputes' },
    { to: '/withdrawals', icon: <Wallet size={20} />, label: 'Withdrawals' },
    { to: '/notifications', icon: <Bell size={20} />, label: 'Notifications' },
    { to: '/settings', icon: <Settings size={20} />, label: 'Settings' },
  ];

  return (
    <div className="sidebar">
      <div style={{ padding: '2rem', borderBottom: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        <Wrench color="var(--accent-primary)" size={28} />
        <h2 style={{ fontSize: '1.25rem', margin: 0, fontWeight: 700, letterSpacing: '0.5px' }}>Fix-N-Go</h2>
      </div>
      <nav style={{ padding: '1rem 0', display: 'flex', flexDirection: 'column', gap: '0.25rem', flex: 1, overflowY: 'auto' }}>
        {navItems.map(item => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
          >
            {item.icon}
            {item.label}
          </NavLink>
        ))}
      </nav>
      <div style={{ padding: '1.5rem', borderTop: '1px solid var(--border-light)' }}>
        <button
          onClick={handleLogout}
          className="nav-item"
          style={{ background: 'none', border: 'none', cursor: 'pointer', width: '100%', textAlign: 'left', color: 'var(--danger)', padding: '0.5rem 0' }}
        >
          <LogOut size={20} />
          Logout
        </button>
        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '1rem' }}>
          © 2026 Fix-N-Go Admin
        </div>
      </div>
    </div>
  );
}

