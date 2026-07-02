import { useState, useEffect, useCallback } from 'react';
import { Search, Filter, RefreshCw, UserCheck, AlertTriangle, ChevronDown, ChevronUp, Loader } from 'lucide-react';
import api from '../api';

const STATUS_COLORS = {
  pending: 'warning',
  assigned: 'info',
  in_progress: 'info',
  completed: 'success',
  cancelled: 'danger',
};



export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState(null);
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch] = useState('');
  const [forceStatusId, setForceStatusId] = useState(null);

  const fetchOrders = useCallback(() => {
    setLoading(true);
    const params = new URLSearchParams();
    if (statusFilter) params.set('status', statusFilter);
    if (search) params.set('search', search);
    api.get(`/admin/orders?${params}`)
      .then(res => setOrders(res.data.data || res.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [statusFilter, search]);

  useEffect(() => {
    fetchOrders();
    const interval = setInterval(fetchOrders, 10000);
    return () => clearInterval(interval);
  }, [fetchOrders]);

  const forceStatus = async (orderId, status) => {
    try {
      await api.patch(`/admin/orders/${orderId}`, { status });
      fetchOrders();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to update status');
    }
    setForceStatusId(null);
  };

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ marginBottom: '0.25rem' }}>Orders</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Live order management · auto-refreshes every 10s</p>
        </div>
        <button className="btn btn-outline" onClick={fetchOrders} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <RefreshCw size={15} /> Refresh
        </button>
      </div>

      {/* Filter Bar */}
      <div style={{ display: 'flex', gap: '1rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
        <div style={{ position: 'relative', flex: 1, minWidth: '200px' }}>
          <Search size={15} style={{ position: 'absolute', left: '0.75rem', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search brand or model..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            style={{ width: '100%', paddingLeft: '2.25rem', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)', borderRadius: '0.5rem', padding: '0.6rem 0.75rem 0.6rem 2.25rem', color: 'var(--text-primary)', fontSize: '0.875rem' }}
          />
        </div>
        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value)}
          style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)', borderRadius: '0.5rem', padding: '0.6rem 1rem', color: 'var(--text-primary)', fontSize: '0.875rem' }}
        >
          <option value="">All Statuses</option>
          {['pending', 'assigned', 'in_progress', 'completed', 'cancelled'].map(s => (
            <option key={s} value={s}>{s}</option>
          ))}
        </select>
      </div>

      <div className="glass-panel table-container">
        <table>
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Device</th>
              <th>Status</th>
              <th>Technician</th>
              <th>Total</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="8" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>Loading orders...</td></tr>
            ) : orders.length === 0 ? (
              <tr><td colSpan="8" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>No orders found.</td></tr>
            ) : orders.map(order => (
              <>
                <tr key={order._id}>
                  <td style={{ fontFamily: 'monospace', fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                    #{order._id?.slice(-8)}
                  </td>
                  <td>
                    <div style={{ fontWeight: 500 }}>{order.user?.name || 'N/A'}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{order.user?.phone || order.user?.email}</div>
                  </td>
                  <td>{order.brand} {order.model}</td>
                  <td>
                    <span className={`badge badge-${STATUS_COLORS[order.status] || 'info'}`}>
                      {order.status}
                    </span>
                  </td>
                  <td>
                    {order.technicianUser?.name
                      ? <span style={{ color: 'var(--accent-primary)' }}>{order.technicianUser.name}</span>
                      : <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>Unassigned</span>
                    }
                  </td>
                  <td>₹{order.customerTotal || order.total || 0}</td>
                  <td style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    {new Date(order.createdAt).toLocaleDateString('en-IN')}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                      <button
                        className="btn btn-outline"
                        style={{ padding: '0.25rem 0.6rem', fontSize: '0.72rem', display: 'flex', alignItems: 'center', gap: '0.25rem' }}
                        onClick={() => setExpanded(expanded === order._id ? null : order._id)}
                      >
                        {expanded === order._id ? <ChevronUp size={12} /> : <ChevronDown size={12} />}
                        Details
                      </button>

                      <button
                        className="btn btn-outline"
                        style={{ padding: '0.25rem 0.6rem', fontSize: '0.72rem', display: 'flex', alignItems: 'center', gap: '0.25rem', color: 'var(--warning)' }}
                        onClick={() => setForceStatusId(forceStatusId === order._id ? null : order._id)}
                      >
                        <AlertTriangle size={12} /> Force
                      </button>
                    </div>
                    {forceStatusId === order._id && (
                      <div style={{ marginTop: '0.5rem', display: 'flex', flexWrap: 'wrap', gap: '0.25rem' }}>
                        {['pending', 'assigned', 'in_progress', 'completed', 'cancelled'].map(s => (
                          <button
                            key={s}
                            className={`badge badge-${STATUS_COLORS[s]}`}
                            style={{ cursor: 'pointer', border: 'none', fontSize: '0.7rem' }}
                            onClick={() => forceStatus(order._id, s)}
                          >
                            {s}
                          </button>
                        ))}
                      </div>
                    )}
                  </td>
                </tr>
                {expanded === order._id && (
                  <tr key={`${order._id}-exp`} style={{ background: 'rgba(255,255,255,0.02)' }}>
                    <td colSpan="8" style={{ padding: '1.25rem 1.5rem' }}>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '1rem', color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
                        <div><span style={{ color: 'var(--text-muted)' }}>Issues: </span>{(order.issues || []).join(', ')}</div>
                        <div><span style={{ color: 'var(--text-muted)' }}>Address: </span>{order.serviceAddress || 'N/A'}</div>
                        <div><span style={{ color: 'var(--text-muted)' }}>Payment: </span>{order.paymentStatus || 'unpaid'}</div>
                        <div><span style={{ color: 'var(--text-muted)' }}>Tech Earning: </span>₹{order.technicianEarning || 0}</div>
                        <div><span style={{ color: 'var(--text-muted)' }}>Technician Phone: </span>{order.technicianUser?.phone || '—'}</div>
                        <div><span style={{ color: 'var(--text-muted)' }}>Customer Email: </span>{order.user?.email || '—'}</div>
                      </div>
                    </td>
                  </tr>
                )}
              </>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
}
