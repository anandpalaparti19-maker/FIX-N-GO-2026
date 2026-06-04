import { useState } from 'react';
import api from '../api';

export default function Login({ setAuth }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post('/auth/login', { email, password });
      // In a real app we might verify the user's role here
      localStorage.setItem('adminToken', res.data.token);
      setAuth(true);
    } catch (err) {
      setError('Invalid credentials. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', height: '100vh', alignItems: 'center', justifyContent: 'center', background: 'var(--bg-base)' }}>
      <form onSubmit={handleLogin} className="glass-card" style={{ width: '400px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h2 style={{ color: 'var(--accent-primary)', fontSize: '1.75rem', fontWeight: 'bold' }}>Fix-N-Go</h2>
          <p style={{ color: 'var(--text-secondary)', marginTop: '0.5rem' }}>Admin Portal Login</p>
        </div>
        {error && <div style={{ color: 'var(--danger)', marginBottom: '1rem', fontSize: '0.875rem', textAlign: 'center' }}>{error}</div>}
        <div className="form-group">
          <label className="form-label">Email</label>
          <input type="email" value={email} onChange={e => setEmail(e.target.value)} className="form-input" required />
        </div>
        <div className="form-group">
          <label className="form-label">Password</label>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} className="form-input" required />
        </div>
        <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '1rem', padding: '0.75rem' }} disabled={loading}>
          {loading ? 'Authenticating...' : 'Sign In'}
        </button>
      </form>
    </div>
  );
}
