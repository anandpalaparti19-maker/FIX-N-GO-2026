import { useState } from 'react';
import api from '../api';

export default function Login({ setAuth }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/auth/login', { email, password, role: 'admin' });
      const user = res.data;

      // Enforce admin role on client side as a second guard
      if (user.role !== 'admin') {
        setError('Access denied. Admin accounts only.');
        return;
      }

      localStorage.setItem('adminToken', user.token);
      setAuth(true);
    } catch (err) {
      const msg = err.response?.data?.message;
      if (msg === 'This account is not a admin') {
        setError('Access denied. Admin accounts only.');
      } else {
        setError('Invalid credentials. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', height: '100vh', alignItems: 'center', justifyContent: 'center', background: 'var(--bg-base)' }}>
      <form onSubmit={handleLogin} className="glass-card" style={{ width: '420px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h2 style={{ color: 'var(--accent-primary)', fontSize: '1.75rem', fontWeight: 'bold' }}>🔧 Fix-N-Go</h2>
          <p style={{ color: 'var(--text-secondary)', marginTop: '0.5rem' }}>Admin Portal</p>
        </div>
        {error && (
          <div style={{ color: 'var(--danger)', marginBottom: '1rem', fontSize: '0.875rem', textAlign: 'center', background: 'rgba(239,68,68,0.08)', padding: '0.75rem', borderRadius: 'var(--radius-md)' }}>
            {error}
          </div>
        )}
        <div className="form-group">
          <label className="form-label">Email</label>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="form-input" required autoComplete="email" />
        </div>
        <div className="form-group">
          <label className="form-label">Password</label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="form-input" required autoComplete="current-password" />
        </div>
        <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '1.25rem', padding: '0.75rem' }} disabled={loading}>
          {loading ? 'Signing in…' : 'Sign In'}
        </button>
      </form>
    </div>
  );
}
