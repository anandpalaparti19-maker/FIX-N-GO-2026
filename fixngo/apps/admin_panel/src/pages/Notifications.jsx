import { useState } from 'react';
import { Send, Users, Wrench, Globe, CheckCircle, AlertCircle } from 'lucide-react';
import api from '../api';

const AUDIENCES = [
  { id: 'all', label: 'Everyone', icon: <Globe size={18} />, desc: 'All customers and technicians' },
  { id: 'customers', label: 'Customers', icon: <Users size={18} />, desc: 'All registered customers' },
  { id: 'technicians', label: 'Technicians', icon: <Wrench size={18} />, desc: 'All registered technicians' },
];

export default function Notifications() {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [audience, setAudience] = useState('all');
  const [sending, setSending] = useState(false);
  const [result, setResult] = useState(null);
  const [history, setHistory] = useState([]);

  const send = async () => {
    if (!title.trim() || !message.trim()) {
      setResult({ error: 'Title and message are required.' });
      return;
    }
    setSending(true);
    setResult(null);
    try {
      const res = await api.post('/admin/notifications/broadcast', { title, message, audience });
      const { recipientCount } = res.data;
      setResult({ success: true, recipientCount });
      setHistory(prev => [{
        id: Date.now(),
        title,
        message,
        audience,
        recipientCount,
        sentAt: new Date().toISOString(),
      }, ...prev].slice(0, 20));
      setTitle('');
      setMessage('');
    } catch (err) {
      setResult({ error: err.response?.data?.message || 'Failed to send notification.' });
    } finally {
      setSending(false);
    }
  };

  const charCount = message.length;

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ marginBottom: '0.25rem' }}>Notifications</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Broadcast messages to users via push notifications and in-app alerts</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', alignItems: 'start' }}>
        {/* Compose panel */}
        <div className="glass-panel" style={{ padding: '1.75rem' }}>
          <h3 style={{ marginBottom: '1.5rem', fontSize: '1rem' }}>📢 Compose Broadcast</h3>

          {/* Audience selector */}
          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', display: 'block', marginBottom: '0.75rem', fontWeight: 500 }}>
              Audience
            </label>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
              {AUDIENCES.map(a => (
                <label
                  key={a.id}
                  style={{
                    display: 'flex', alignItems: 'center', gap: '0.75rem',
                    padding: '0.75rem 1rem', borderRadius: '0.5rem', cursor: 'pointer',
                    background: audience === a.id ? 'rgba(99, 102, 241, 0.15)' : 'rgba(255,255,255,0.03)',
                    border: `1px solid ${audience === a.id ? 'var(--accent-primary)' : 'var(--border-light)'}`,
                    transition: 'all 0.2s',
                  }}
                >
                  <input
                    type="radio"
                    name="audience"
                    value={a.id}
                    checked={audience === a.id}
                    onChange={() => setAudience(a.id)}
                    style={{ display: 'none' }}
                  />
                  <span style={{ color: audience === a.id ? 'var(--accent-primary)' : 'var(--text-muted)' }}>{a.icon}</span>
                  <div>
                    <div style={{ fontWeight: 600, fontSize: '0.875rem' }}>{a.label}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{a.desc}</div>
                  </div>
                </label>
              ))}
            </div>
          </div>

          {/* Title */}
          <div style={{ marginBottom: '1rem' }}>
            <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', display: 'block', marginBottom: '0.4rem', fontWeight: 500 }}>
              Title
            </label>
            <input
              type="text"
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Notification title..."
              maxLength={80}
              style={{
                width: '100%', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)',
                borderRadius: '0.5rem', padding: '0.65rem 0.9rem', color: 'var(--text-primary)',
                fontSize: '0.875rem', boxSizing: 'border-box',
              }}
            />
          </div>

          {/* Message */}
          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', display: 'block', marginBottom: '0.4rem', fontWeight: 500 }}>
              Message
              <span style={{ marginLeft: '0.5rem', fontSize: '0.75rem', color: charCount > 200 ? 'var(--danger)' : 'var(--text-muted)' }}>
                ({charCount}/280)
              </span>
            </label>
            <textarea
              value={message}
              onChange={e => setMessage(e.target.value)}
              placeholder="Write your notification message..."
              maxLength={280}
              rows={5}
              style={{
                width: '100%', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)',
                borderRadius: '0.5rem', padding: '0.75rem 0.9rem', color: 'var(--text-primary)',
                fontSize: '0.875rem', resize: 'vertical', boxSizing: 'border-box',
              }}
            />
          </div>

          {/* Result */}
          {result && (
            <div style={{
              display: 'flex', alignItems: 'flex-start', gap: '0.5rem', padding: '0.75rem 1rem',
              borderRadius: '0.5rem', marginBottom: '1rem',
              background: result.success ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
              border: `1px solid ${result.success ? 'rgba(16, 185, 129, 0.3)' : 'rgba(239, 68, 68, 0.3)'}`,
            }}>
              {result.success
                ? <><CheckCircle size={16} color="var(--success)" style={{ marginTop: '1px', flexShrink: 0 }} />
                    <span style={{ color: 'var(--success)', fontSize: '0.875rem' }}>
                      ✓ Sent to {result.recipientCount} recipient{result.recipientCount !== 1 ? 's' : ''}
                    </span></>
                : <><AlertCircle size={16} color="var(--danger)" style={{ marginTop: '1px', flexShrink: 0 }} />
                    <span style={{ color: 'var(--danger)', fontSize: '0.875rem' }}>{result.error}</span></>
              }
            </div>
          )}

          <button
            className="btn btn-primary"
            onClick={send}
            disabled={sending || !title.trim() || !message.trim()}
            style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem', padding: '0.75rem' }}
          >
            {sending ? 'Sending...' : <><Send size={16} /> Send Broadcast</>}
          </button>
        </div>

        {/* History panel */}
        <div className="glass-panel" style={{ padding: '1.75rem' }}>
          <h3 style={{ marginBottom: '1.25rem', fontSize: '1rem' }}>📋 Sent This Session</h3>
          {history.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--text-muted)' }}>
              <Send size={32} style={{ opacity: 0.2, marginBottom: '1rem' }} />
              <p style={{ fontSize: '0.875rem' }}>No broadcasts sent yet this session.</p>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {history.map(h => (
                <div key={h.id} style={{
                  padding: '0.9rem 1rem', borderRadius: '0.5rem',
                  background: 'rgba(255,255,255,0.04)', border: '1px solid var(--border-light)'
                }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '0.25rem' }}>
                    <span style={{ fontWeight: 600, fontSize: '0.875rem' }}>{h.title}</span>
                    <span className={`badge badge-${h.audience === 'all' ? 'info' : h.audience === 'customers' ? 'success' : 'warning'}`}
                      style={{ fontSize: '0.65rem', flexShrink: 0, marginLeft: '0.5rem' }}>
                      {h.audience}
                    </span>
                  </div>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', margin: '0 0 0.4rem' }}>{h.message}</p>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                    <span>{h.recipientCount} recipients</span>
                    <span>{new Date(h.sentAt).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
