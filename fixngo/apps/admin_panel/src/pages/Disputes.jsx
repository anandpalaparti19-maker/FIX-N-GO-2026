import { useState, useEffect, useCallback } from 'react';
import { RefreshCw, CheckCircle, AlertCircle, Clock } from 'lucide-react';
import api from '../api';

const PRIORITY_COLOR = { high: 'danger', medium: 'warning', low: 'info' };
const STATUS_COLOR = { open: 'warning', in_progress: 'info', resolved: 'success', closed: 'info' };

function ResolveModal({ ticket, onClose, onResolved }) {
  const [notes, setNotes] = useState('');
  const [status, setStatus] = useState('resolved');
  const [loading, setLoading] = useState(false);

  const submit = async () => {
    setLoading(true);
    try {
      await api.patch(`/admin/disputes/${ticket._id}`, { resolutionNotes: notes, status });
      onResolved();
      onClose();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to update ticket');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000
    }}>
      <div className="glass-panel" style={{ width: 520, padding: '2rem', borderRadius: '1rem' }}>
        <h2 style={{ marginBottom: '0.5rem' }}>Resolve Ticket</h2>
        <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem', fontSize: '0.85rem' }}>
          <strong>{ticket.subject}</strong> — {ticket.createdBy?.name}
        </p>

        <div style={{ marginBottom: '1rem' }}>
          <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', display: 'block', marginBottom: '0.4rem' }}>
            Set Status
          </label>
          <select
            value={status}
            onChange={e => setStatus(e.target.value)}
            style={{ width: '100%', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)', borderRadius: '0.5rem', padding: '0.6rem', color: 'var(--text-primary)', fontSize: '0.875rem' }}
          >
            {['in_progress', 'resolved', 'closed'].map(s => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </div>

        <div style={{ marginBottom: '1.5rem' }}>
          <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', display: 'block', marginBottom: '0.4rem' }}>
            Resolution Notes (optional)
          </label>
          <textarea
            value={notes}
            onChange={e => setNotes(e.target.value)}
            placeholder="Describe how this was resolved..."
            rows={4}
            style={{ width: '100%', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)', borderRadius: '0.5rem', padding: '0.75rem', color: 'var(--text-primary)', fontSize: '0.875rem', resize: 'vertical', boxSizing: 'border-box' }}
          />
        </div>

        <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'flex-end' }}>
          <button className="btn btn-outline" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={submit} disabled={loading}>
            {loading ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function Disputes() {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('open');
  const [resolveModal, setResolveModal] = useState(null);

  const fetchTickets = useCallback(() => {
    setLoading(true);
    const params = statusFilter ? `?status=${statusFilter}` : '';
    api.get(`/admin/disputes${params}`)
      .then(res => setTickets(res.data.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [statusFilter]);

  useEffect(() => { fetchTickets(); }, [fetchTickets]);

  const openCount = tickets.filter(t => t.status === 'open').length;
  const highPriorityCount = tickets.filter(t => t.priority === 'high').length;

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ marginBottom: '0.25rem' }}>Disputes & Support</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            {openCount} open · {highPriorityCount} high priority
          </p>
        </div>
        <button className="btn btn-outline" onClick={fetchTickets} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <RefreshCw size={15} /> Refresh
        </button>
      </div>

      {/* Status filter tabs */}
      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
        {['', 'open', 'in_progress', 'resolved', 'closed'].map(s => (
          <button
            key={s}
            className={`btn ${statusFilter === s ? 'btn-primary' : 'btn-outline'}`}
            style={{ padding: '0.35rem 0.9rem', fontSize: '0.8rem' }}
            onClick={() => setStatusFilter(s)}
          >
            {s === '' ? 'All' : s}
          </button>
        ))}
      </div>

      <div className="glass-panel table-container">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Subject</th>
              <th>Category</th>
              <th>Priority</th>
              <th>Status</th>
              <th>Order</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="8" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>Loading...</td></tr>
            ) : tickets.length === 0 ? (
              <tr><td colSpan="8" style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '3rem' }}>
                No {statusFilter || ''} tickets found.
              </td></tr>
            ) : tickets.map(t => (
              <tr key={t._id}>
                <td>
                  <div style={{ fontWeight: 500 }}>{t.createdBy?.name || 'N/A'}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{t.createdBy?.role}</div>
                </td>
                <td style={{ maxWidth: '220px' }}>
                  <div style={{ fontWeight: 500, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {t.subject}
                  </div>
                  {t.message && (
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {t.message}
                    </div>
                  )}
                </td>
                <td style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>{t.category}</td>
                <td>
                  <span className={`badge badge-${PRIORITY_COLOR[t.priority] || 'info'}`}>{t.priority}</span>
                </td>
                <td>
                  <span className={`badge badge-${STATUS_COLOR[t.status] || 'info'}`}>{t.status}</span>
                </td>
                <td style={{ fontFamily: 'monospace', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  {t.orderId ? `#${t.orderId._id?.slice(-8) || t.orderId.slice(-8)}` : '—'}
                </td>
                <td style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                  {new Date(t.createdAt).toLocaleDateString('en-IN')}
                </td>
                <td>
                  {t.status !== 'resolved' && t.status !== 'closed' ? (
                    <button
                      className="btn btn-primary"
                      style={{ padding: '0.25rem 0.7rem', fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.3rem' }}
                      onClick={() => setResolveModal(t)}
                    >
                      <CheckCircle size={12} /> Resolve
                    </button>
                  ) : (
                    <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                      <CheckCircle size={13} color="var(--success)" /> Done
                    </span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {resolveModal && (
        <ResolveModal
          ticket={resolveModal}
          onClose={() => setResolveModal(null)}
          onResolved={fetchTickets}
        />
      )}
    </div>
  );
}
