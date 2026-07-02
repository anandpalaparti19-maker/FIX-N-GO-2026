import React, { useState, useEffect, useCallback } from 'react';
import { Search, UserCheck, UserX, ChevronDown, ChevronUp, Phone, Mail, MapPin, ShoppingBag, Calendar } from 'lucide-react';
import api from '../api';

export default function Customers() {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [expandedId, setExpandedId] = useState(null);
  const [detailData, setDetailData] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(null);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [pages, setPages] = useState(1);

  const fetchCustomers = useCallback(() => {
    setLoading(true);
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    if (statusFilter) params.set('status', statusFilter);
    params.set('page', page);
    params.set('limit', 25);

    api.get(`/admin/customers?${params}`)
      .then(res => {
        setCustomers(res.data.data || []);
        setTotal(res.data.total || 0);
        setPages(res.data.pages || 1);
      })
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  }, [search, statusFilter, page]);

  useEffect(() => { fetchCustomers(); }, [fetchCustomers]);

  const handleToggleExpand = async (id) => {
    if (expandedId === id) {
      setExpandedId(null);
      setDetailData(null);
      return;
    }
    setExpandedId(id);
    setDetailLoading(true);
    try {
      const res = await api.get(`/admin/customers/${id}`);
      setDetailData(res.data.data);
    } catch (err) {
      console.error(err);
      setDetailData(null);
    }
    setDetailLoading(false);
  };

  const handleStatusChange = async (id, newStatus) => {
    setActionLoading(id);
    try {
      await api.patch(`/admin/customers/${id}/status`, { accountStatus: newStatus });
      fetchCustomers();
      if (expandedId === id) {
        const res = await api.get(`/admin/customers/${id}`);
        setDetailData(res.data.data);
      }
    } catch (err) {
      console.error(err);
    }
    setActionLoading(null);
  };

  const statusBadge = (status) => {
    const map = { active: 'success', suspended: 'danger', pending: 'warning' };
    return <span className={`badge badge-${map[status] || 'info'}`}>{status || 'active'}</span>;
  };

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ margin: 0 }}>Customer Management</h1>
          <p style={{ color: 'var(--text-muted)', marginTop: '0.25rem', fontSize: '0.9rem' }}>{total} total customers</p>
        </div>
      </div>

      {/* Filters */}
      <div style={{ display: 'flex', gap: '1rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
        <div style={{ position: 'relative', flex: 1, minWidth: '240px' }}>
          <Search size={16} style={{ position: 'absolute', left: '0.75rem', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search by name, email, or phone..."
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
            style={{
              width: '100%', padding: '0.65rem 0.9rem 0.65rem 2.25rem',
              background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)',
              borderRadius: '0.5rem', color: 'var(--text-primary)', fontSize: '0.875rem',
            }}
          />
        </div>
        <select
          value={statusFilter}
          onChange={e => { setStatusFilter(e.target.value); setPage(1); }}
          style={{
            background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)',
            borderRadius: '0.5rem', padding: '0.65rem 1rem', color: 'var(--text-primary)', fontSize: '0.875rem',
          }}
        >
          <option value="">All Statuses</option>
          <option value="active">Active</option>
          <option value="suspended">Suspended</option>
        </select>
      </div>

      {/* Table */}
      <div className="glass-panel table-container">
        <table>
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Orders</th>
              <th>Status</th>
              <th>City</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="9" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}>
                  <div style={{ width: '20px', height: '20px', border: '2px solid var(--accent-primary)', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
                  Loading customers...
                </div>
              </td></tr>
            ) : customers.length === 0 ? (
              <tr><td colSpan="9" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>No customers found.</td></tr>
            ) : customers.map(c => (
              <React.Fragment key={c._id}>
                <tr style={{ cursor: 'pointer' }} onClick={() => handleToggleExpand(c._id)}>
                  <td style={{ width: '2rem', padding: '0.5rem' }}>
                    {expandedId === c._id ? <ChevronUp size={16} color="var(--text-muted)" /> : <ChevronDown size={16} color="var(--text-muted)" />}
                  </td>
                  <td style={{ fontWeight: 600 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                      <div style={{
                        width: '32px', height: '32px', borderRadius: '50%',
                        background: 'linear-gradient(135deg, var(--accent-primary), var(--accent-secondary))',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: '0.8rem', fontWeight: 700, color: 'white', flexShrink: 0,
                      }}>
                        {(c.name || '?')[0].toUpperCase()}
                      </div>
                      {c.name || 'N/A'}
                    </div>
                  </td>
                  <td style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>{c.email}</td>
                  <td style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>{c.phone || '—'}</td>
                  <td>
                    <span style={{ fontWeight: 600 }}>{c.orderCount || 0}</span>
                    <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginLeft: '0.25rem' }}>
                      ({c.completedOrders || 0} done)
                    </span>
                  </td>
                  <td>{statusBadge(c.accountStatus)}</td>
                  <td style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>{c.city || '—'}</td>
                  <td style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                    {new Date(c.createdAt).toLocaleDateString('en-IN')}
                  </td>
                  <td onClick={e => e.stopPropagation()}>
                    {c.accountStatus === 'suspended' ? (
                      <button
                        className="btn"
                        style={{ backgroundColor: 'var(--success)', color: 'white', border: 'none', padding: '0.3rem 0.75rem', fontSize: '0.75rem' }}
                        onClick={() => handleStatusChange(c._id, 'active')}
                        disabled={actionLoading === c._id}
                      >
                        {actionLoading === c._id ? '...' : <><UserCheck size={14} /> Activate</>}
                      </button>
                    ) : (
                      <button
                        className="btn"
                        style={{ backgroundColor: 'rgba(239,68,68,0.15)', color: 'var(--danger)', border: '1px solid rgba(239,68,68,0.3)', padding: '0.3rem 0.75rem', fontSize: '0.75rem' }}
                        onClick={() => handleStatusChange(c._id, 'suspended')}
                        disabled={actionLoading === c._id}
                      >
                        {actionLoading === c._id ? '...' : <><UserX size={14} /> Suspend</>}
                      </button>
                    )}
                  </td>
                </tr>

                {/* Expanded Detail Row */}
                {expandedId === c._id && (
                  <tr style={{ backgroundColor: 'rgba(255,255,255,0.02)' }}>
                    <td colSpan="9" style={{ padding: '1.5rem' }}>
                      {detailLoading ? (
                        <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '1rem' }}>Loading details...</div>
                      ) : detailData ? (
                        <div style={{ display: 'flex', gap: '2.5rem', flexWrap: 'wrap' }}>
                          {/* Customer Info */}
                          <div style={{ flex: '1', minWidth: '250px' }}>
                            <h4 style={{ marginBottom: '1rem', color: 'var(--accent-primary)', fontSize: '0.9rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Customer Details</h4>
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem' }}>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                                <Mail size={14} /> {detailData.customer.email}
                              </div>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                                <Phone size={14} /> {detailData.customer.phone || 'No phone'}
                              </div>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                                <MapPin size={14} /> {detailData.customer.address || 'No address'}{detailData.customer.city ? `, ${detailData.customer.city}` : ''} {detailData.customer.pincode || ''}
                              </div>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                                <Calendar size={14} /> Joined {new Date(detailData.customer.createdAt).toLocaleDateString('en-IN', { year: 'numeric', month: 'long', day: 'numeric' })}
                              </div>
                            </div>
                            {/* Saved Addresses */}
                            {detailData.customer.customerMeta?.savedAddresses?.length > 0 && (
                              <div style={{ marginTop: '1rem' }}>
                                <h5 style={{ marginBottom: '0.5rem', color: 'var(--text-primary)', fontSize: '0.8rem' }}>Saved Addresses</h5>
                                {detailData.customer.customerMeta.savedAddresses.map((addr, i) => (
                                  <div key={i} style={{ padding: '0.4rem 0.6rem', background: 'rgba(255,255,255,0.04)', borderRadius: '0.4rem', marginBottom: '0.35rem', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                                    <strong style={{ color: 'var(--text-secondary)' }}>{addr.label || 'Address'}:</strong> {addr.address}, {addr.city} {addr.pincode}
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>

                          {/* Recent Orders */}
                          <div style={{ flex: '1.5', minWidth: '300px' }}>
                            <h4 style={{ marginBottom: '1rem', color: 'var(--accent-primary)', fontSize: '0.9rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                              <ShoppingBag size={14} style={{ marginRight: '0.4rem', verticalAlign: 'middle' }} />
                              Recent Orders
                            </h4>
                            {detailData.recentOrders?.length > 0 ? (
                              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.35rem' }}>
                                {detailData.recentOrders.map(order => (
                                  <div key={order._id} style={{
                                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                                    padding: '0.5rem 0.75rem', background: 'rgba(255,255,255,0.04)',
                                    borderRadius: '0.4rem', fontSize: '0.85rem',
                                  }}>
                                    <span style={{ fontWeight: 500 }}>{order.brand} {order.model}</span>
                                    <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
                                      <span className={`badge badge-${order.status === 'completed' ? 'success' : order.status === 'cancelled' ? 'danger' : order.status === 'pending' ? 'warning' : 'info'}`}>
                                        {order.status}
                                      </span>
                                      {order.total != null && <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>₹{order.total}</span>}
                                      <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>
                                        {new Date(order.createdAt).toLocaleDateString('en-IN')}
                                      </span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            ) : (
                              <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>No orders yet.</p>
                            )}
                          </div>
                        </div>
                      ) : (
                        <div style={{ color: 'var(--text-muted)' }}>Failed to load details.</div>
                      )}
                    </td>
                  </tr>
                )}
              </React.Fragment>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pages > 1 && (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '0.75rem', marginTop: '1.5rem' }}>
          <button
            className="btn btn-outline"
            style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }}
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page <= 1}
          >
            Previous
          </button>
          <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
            Page {page} of {pages}
          </span>
          <button
            className="btn btn-outline"
            style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }}
            onClick={() => setPage(p => Math.min(pages, p + 1))}
            disabled={page >= pages}
          >
            Next
          </button>
        </div>
      )}

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
