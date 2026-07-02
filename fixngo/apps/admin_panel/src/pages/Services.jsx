import React, { useState, useEffect } from 'react';
import { Plus, Pencil, Trash2, X, Check, Package, DollarSign, Smartphone } from 'lucide-react';
import api from '../api';

export default function Services() {
  const [services, setServices] = useState([]);
  const [brands, setBrands] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({ title: '', description: '', price: '' });
  const [saving, setSaving] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState(null);

  const fetchServices = () => {
    setLoading(true);
    Promise.all([
      api.get('/admin/services'),
      api.get('/catalog').catch(() => ({ data: { brands: [] } })),
    ])
      .then(([servicesRes, catalogRes]) => {
        setServices(servicesRes.data.data || []);
        setBrands(catalogRes.data.brands || []);
      })
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchServices(); }, []);

  const resetForm = () => {
    setFormData({ title: '', description: '', price: '' });
    setEditingId(null);
    setShowForm(false);
  };

  const handleEdit = (service) => {
    setFormData({ title: service.title, description: service.description, price: service.price });
    setEditingId(service._id);
    setShowForm(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.title || !formData.description || !formData.price) return;
    setSaving(true);
    try {
      if (editingId) {
        await api.put(`/admin/services/${editingId}`, formData);
      } else {
        await api.post('/admin/services', formData);
      }
      resetForm();
      fetchServices();
    } catch (err) {
      console.error(err);
    }
    setSaving(false);
  };

  const handleDelete = async (id) => {
    try {
      await api.delete(`/admin/services/${id}`);
      setDeleteConfirm(null);
      fetchServices();
    } catch (err) {
      console.error(err);
    }
  };

  const issueEmoji = (title) => {
    const t = title.toLowerCase();
    if (t.includes('screen')) return '🧩';
    if (t.includes('battery')) return '🔋';
    if (t.includes('camera')) return '📷';
    if (t.includes('speaker') || t.includes('audio')) return '🔊';
    if (t.includes('charging') || t.includes('port')) return '🔌';
    if (t.includes('water') || t.includes('liquid')) return '💧';
    if (t.includes('software') || t.includes('os')) return '💻';
    if (t.includes('button') || t.includes('key')) return '🔘';
    return '🔧';
  };

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ margin: 0 }}>Services & Catalog</h1>
          <p style={{ color: 'var(--text-muted)', marginTop: '0.25rem', fontSize: '0.9rem' }}>Manage repair services and device catalog</p>
        </div>
        <button
          className="btn btn-primary"
          onClick={() => { resetForm(); setShowForm(true); }}
          style={{ gap: '0.4rem' }}
        >
          <Plus size={18} /> Add Service
        </button>
      </div>

      {/* Add/Edit Form Modal */}
      {showForm && (
        <div style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(4px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000,
        }} onClick={() => resetForm()}>
          <div
            className="glass-panel"
            style={{
              padding: '2rem', width: '100%', maxWidth: '480px',
              animation: 'slideUp 0.3s ease',
            }}
            onClick={e => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h2 style={{ margin: 0, fontSize: '1.25rem' }}>{editingId ? 'Edit Service' : 'Add New Service'}</h2>
              <button onClick={resetForm} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}>
                <X size={20} />
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Service Name</label>
                <input
                  className="form-input"
                  type="text"
                  placeholder="e.g., Screen Replacement"
                  value={formData.title}
                  onChange={e => setFormData({ ...formData, title: e.target.value })}
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Description</label>
                <textarea
                  className="form-input"
                  placeholder="Brief description of the service..."
                  value={formData.description}
                  onChange={e => setFormData({ ...formData, description: e.target.value })}
                  required
                  rows={3}
                  style={{ resize: 'vertical', fontFamily: 'inherit' }}
                />
              </div>
              <div className="form-group">
                <label className="form-label">Price (₹)</label>
                <input
                  className="form-input"
                  type="number"
                  min="0"
                  step="1"
                  placeholder="999"
                  value={formData.price}
                  onChange={e => setFormData({ ...formData, price: e.target.value })}
                  required
                />
              </div>
              <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'flex-end', marginTop: '1.5rem' }}>
                <button type="button" className="btn btn-outline" onClick={resetForm}>Cancel</button>
                <button type="submit" className="btn btn-primary" disabled={saving}>
                  {saving ? 'Saving...' : <><Check size={16} /> {editingId ? 'Update' : 'Create'}</>}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteConfirm && (
        <div style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(4px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000,
        }} onClick={() => setDeleteConfirm(null)}>
          <div
            className="glass-panel"
            style={{ padding: '2rem', width: '100%', maxWidth: '400px', textAlign: 'center' }}
            onClick={e => e.stopPropagation()}
          >
            <Trash2 size={40} color="var(--danger)" style={{ marginBottom: '1rem' }} />
            <h3 style={{ marginBottom: '0.5rem' }}>Delete Service?</h3>
            <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem', fontSize: '0.9rem' }}>
              This will permanently remove "<strong>{deleteConfirm.title}</strong>". This action cannot be undone.
            </p>
            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
              <button className="btn btn-outline" onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button
                className="btn"
                style={{ backgroundColor: 'var(--danger)', color: 'white', border: 'none' }}
                onClick={() => handleDelete(deleteConfirm._id)}
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Services Grid */}
      <div style={{ marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '1.1rem', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Package size={20} color="var(--accent-primary)" /> Repair Services
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 400 }}>({services.length})</span>
        </h2>

        {loading ? (
          <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-muted)' }}>
            <div style={{ width: '24px', height: '24px', border: '2px solid var(--accent-primary)', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.8s linear infinite', margin: '0 auto 0.75rem' }} />
            Loading services...
          </div>
        ) : services.length === 0 ? (
          <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-muted)' }}>
            No services yet. Click "Add Service" to create one.
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1rem' }}>
            {services.map(service => (
              <div key={service._id} className="glass-card" style={{ display: 'flex', flexDirection: 'column' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '0.75rem' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                    <span style={{ fontSize: '1.5rem' }}>{issueEmoji(service.title)}</span>
                    <h3 style={{ margin: 0, fontSize: '1rem' }}>{service.title}</h3>
                  </div>
                  <div style={{ display: 'flex', gap: '0.35rem' }}>
                    <button
                      onClick={() => handleEdit(service)}
                      style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-light)', borderRadius: '0.4rem', padding: '0.35rem', cursor: 'pointer', color: 'var(--text-secondary)', transition: 'all 0.15s' }}
                      title="Edit"
                    >
                      <Pencil size={14} />
                    </button>
                    <button
                      onClick={() => setDeleteConfirm(service)}
                      style={{ background: 'rgba(239,68,68,0.1)', border: '1px solid rgba(239,68,68,0.2)', borderRadius: '0.4rem', padding: '0.35rem', cursor: 'pointer', color: 'var(--danger)', transition: 'all 0.15s' }}
                      title="Delete"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
                <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem', margin: '0 0 1rem', flex: 1 }}>{service.description}</p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid var(--border-light)', paddingTop: '0.75rem' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem', color: 'var(--success)', fontWeight: 700, fontSize: '1.1rem' }}>
                    <DollarSign size={16} /> ₹{service.price}
                  </div>
                  <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>
                    Updated {new Date(service.updatedAt).toLocaleDateString('en-IN')}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Device Catalog Section */}
      <div>
        <h2 style={{ fontSize: '1.1rem', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Smartphone size={20} color="var(--accent-secondary)" /> Device Catalog
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 400 }}>({brands.length} brands)</span>
        </h2>

        {brands.length === 0 ? (
          <div className="glass-panel" style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-muted)' }}>
            No brands in catalog. Update <code>backend/src/data/catalog.js</code> to add brands.
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1rem' }}>
            {brands.map((brand, idx) => (
              <div key={idx} className="glass-card">
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '1rem' }}>
                  <span style={{ fontSize: '1.75rem' }}>{brand.emoji}</span>
                  <h3 style={{ margin: 0, fontSize: '1.05rem' }}>{brand.name}</h3>
                  <span className="badge badge-info" style={{ marginLeft: 'auto' }}>{brand.models?.length || 0} models</span>
                </div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.4rem' }}>
                  {brand.models?.map((model, mIdx) => (
                    <span key={mIdx} style={{
                      padding: '0.3rem 0.7rem', background: 'rgba(255,255,255,0.06)',
                      borderRadius: '9999px', fontSize: '0.8rem', color: 'var(--text-secondary)',
                      border: '1px solid var(--border-light)',
                    }}>
                      {model}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
        <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginTop: '1rem', fontStyle: 'italic' }}>
          💡 Device catalog (brands/models) is managed in <code style={{ color: 'var(--accent-primary)' }}>backend/src/data/catalog.js</code>. Edit that file to add or remove devices.
        </p>
      </div>

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
