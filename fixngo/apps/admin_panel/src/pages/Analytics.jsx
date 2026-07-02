import { useState, useEffect } from 'react';
import {
  Chart as ChartJS,
  CategoryScale, LinearScale, BarElement, ArcElement,
  Title, Tooltip, Legend, PointElement, LineElement,
} from 'chart.js';
import { Bar, Doughnut } from 'react-chartjs-2';
import { TrendingUp, DollarSign, Package, Star } from 'lucide-react';
import api from '../api';

ChartJS.register(
  CategoryScale, LinearScale, BarElement, ArcElement,
  Title, Tooltip, Legend, PointElement, LineElement
);

const CHART_OPTS = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { labels: { color: '#94a3b8' } } },
  scales: {
    x: { ticks: { color: '#64748b' }, grid: { color: 'rgba(255,255,255,0.05)' } },
    y: { ticks: { color: '#64748b' }, grid: { color: 'rgba(255,255,255,0.05)' } },
  },
};

const STATUS_PALETTE = {
  pending: '#f59e0b',
  assigned: '#3b82f6',
  in_progress: '#06b6d4',
  completed: '#10b981',
  cancelled: '#ef4444',
};

export default function Analytics() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [days, setDays] = useState(30);

  useEffect(() => {
    setLoading(true);
    api.get(`/admin/analytics?days=${days}`)
      .then(res => setData(res.data.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [days]);

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '60vh', color: 'var(--text-muted)' }}>
        Loading analytics...
      </div>
    );
  }

  const totalRevenue = data?.totalRevenue || 0;
  const totalOrders = data?.dailyStats?.reduce((s, d) => s + d.orders, 0) || 0;
  const completedOrders = data?.dailyStats?.reduce((s, d) => s + d.completed, 0) || 0;
  const completionRate = totalOrders > 0 ? ((completedOrders / totalOrders) * 100).toFixed(1) : 0;

  const barData = {
    labels: (data?.dailyStats || []).map(d => d._id.slice(5)), // MM-DD
    datasets: [
      {
        label: 'Orders',
        data: (data?.dailyStats || []).map(d => d.orders),
        backgroundColor: 'rgba(59, 130, 246, 0.7)',
        borderRadius: 4,
      },
      {
        label: 'Revenue (₹)',
        data: (data?.dailyStats || []).map(d => d.revenue),
        backgroundColor: 'rgba(16, 185, 129, 0.7)',
        borderRadius: 4,
        yAxisID: 'y',
      },
    ],
  };

  const doughnutData = {
    labels: (data?.byStatus || []).map(s => s._id),
    datasets: [{
      data: (data?.byStatus || []).map(s => s.count),
      backgroundColor: (data?.byStatus || []).map(s => STATUS_PALETTE[s._id] || '#6b7280'),
      borderWidth: 0,
    }],
  };

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ marginBottom: '0.25rem' }}>Analytics</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Platform performance overview</p>
        </div>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          {[7, 14, 30, 90].map(d => (
            <button
              key={d}
              className={`btn ${days === d ? 'btn-primary' : 'btn-outline'}`}
              style={{ padding: '0.35rem 0.8rem', fontSize: '0.8rem' }}
              onClick={() => setDays(d)}
            >
              {d}d
            </button>
          ))}
        </div>
      </div>

      {/* Stat cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
        {[
          { title: 'Total Revenue', value: `₹${totalRevenue.toLocaleString('en-IN')}`, icon: <DollarSign size={20} color="#10b981" />, sub: `last ${days} days` },
          { title: 'Total Orders', value: totalOrders, icon: <Package size={20} color="#3b82f6" />, sub: `last ${days} days` },
          { title: 'Completed', value: completedOrders, icon: <TrendingUp size={20} color="#06b6d4" />, sub: `${completionRate}% rate` },
          { title: 'Top Technician', value: data?.topTechnicians?.[0]?.name || '—', icon: <Star size={20} color="#f59e0b" />, sub: `${data?.topTechnicians?.[0]?.jobs || 0} jobs` },
        ].map(c => (
          <div key={c.title} className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '0.82rem', color: 'var(--text-secondary)', fontWeight: 500 }}>{c.title}</span>
              <div style={{ padding: '0.35rem', background: 'rgba(255,255,255,0.06)', borderRadius: '8px' }}>{c.icon}</div>
            </div>
            <div>
              <div style={{ fontSize: '1.8rem', fontWeight: 700, lineHeight: 1.1 }}>{c.value}</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '3px' }}>{c.sub}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts row */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem', marginBottom: '2rem' }}>
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1.25rem', fontSize: '0.95rem', color: 'var(--text-secondary)' }}>Orders & Revenue — Daily</h3>
          <div style={{ height: '280px' }}>
            <Bar data={barData} options={CHART_OPTS} />
          </div>
        </div>
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1.25rem', fontSize: '0.95rem', color: 'var(--text-secondary)' }}>Orders by Status</h3>
          <div style={{ height: '280px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            {doughnutData.labels.length > 0
              ? <Doughnut data={doughnutData} options={{ ...CHART_OPTS, scales: undefined, cutout: '65%' }} />
              : <p style={{ color: 'var(--text-muted)' }}>No data</p>
            }
          </div>
        </div>
      </div>

      {/* Technician leaderboard */}
      <div className="glass-panel table-container">
        <h3 style={{ padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--border-light)', margin: 0, fontSize: '0.95rem' }}>
          🏆 Top Technicians — last {days} days
        </h3>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Name</th>
              <th>Phone</th>
              <th>Jobs Done</th>
              <th>Earned</th>
            </tr>
          </thead>
          <tbody>
            {(data?.topTechnicians || []).length === 0 ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '2rem' }}>No data for this period.</td></tr>
            ) : (data?.topTechnicians || []).map((t, i) => (
              <tr key={t._id}>
                <td style={{ color: i === 0 ? '#f59e0b' : 'var(--text-muted)', fontWeight: 700 }}>
                  {i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : `#${i + 1}`}
                </td>
                <td style={{ fontWeight: 500 }}>{t.name}</td>
                <td style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>{t.phone}</td>
                <td>
                  <span className="badge badge-success">{t.jobs}</span>
                </td>
                <td style={{ fontWeight: 600, color: 'var(--accent-primary)' }}>₹{(t.earned || 0).toLocaleString('en-IN')}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
