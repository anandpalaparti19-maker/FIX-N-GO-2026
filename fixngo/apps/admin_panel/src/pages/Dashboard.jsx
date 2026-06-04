import { useState, useEffect } from 'react';
import { Activity, DollarSign, Users, Wrench } from 'lucide-react';
import api from '../api';

export default function Dashboard() {
  const [stats, setStats] = useState({ revenue: 0, active: 0, total: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/orders')
      .then(res => {
        const orders = res.data.orders || [];
        const active = orders.filter(o => o.status === 'pending' || o.status === 'assigned' || o.status === 'in_progress').length;
        const total = orders.length;
        const revenue = orders.filter(o => o.status === 'completed').reduce((sum, o) => sum + (o.estimatedPrice || 0), 0);
        setStats({ revenue, active, total });
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div style={{ animation: 'fadeIn 0.5s ease' }}>
      <h1 style={{ marginBottom: '2rem' }}>Dashboard Overview</h1>
      
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        <StatCard title="Total Revenue" value={loading ? '...' : `$${stats.revenue.toLocaleString()}`} icon={<DollarSign size={24} color="#10b981" />} trend="All time" />
        <StatCard title="Active Orders" value={loading ? '...' : stats.active} icon={<Activity size={24} color="#3b82f6" />} trend="Requires action" />
        <StatCard title="Total Orders" value={loading ? '...' : stats.total} icon={<Users size={24} color="#8b5cf6" />} trend="All time" />
        <StatCard title="Technicians" value="Managed" icon={<Wrench size={24} color="#f59e0b" />} trend="via Database" />
      </div>

      <div className="glass-card" style={{ height: '400px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <p style={{ color: 'var(--text-secondary)' }}>Advanced Revenue visualization pending analytics endpoint.</p>
      </div>
    </div>
  );
}

function StatCard({ title, value, icon, trend }) {
  return (
    <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3 style={{ fontSize: '1rem', color: 'var(--text-secondary)', fontWeight: 500 }}>{title}</h3>
        <div style={{ padding: '0.5rem', background: 'rgba(255,255,255,0.05)', borderRadius: 'var(--radius-md)' }}>
          {icon}
        </div>
      </div>
      <div>
        <div style={{ fontSize: '2rem', fontWeight: 700, color: 'var(--text-primary)' }}>{value}</div>
        <div style={{ fontSize: '0.875rem', color: 'var(--success)', marginTop: '0.25rem' }}>{trend}</div>
      </div>
    </div>
  );
}
