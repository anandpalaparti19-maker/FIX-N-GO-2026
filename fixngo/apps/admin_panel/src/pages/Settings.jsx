import React, { useState, useEffect } from 'react';
import { Settings2, Server, Database, Mail, MessageSquare, CreditCard, Radio, HardDrive, Clock, Activity, Users, Wrench, ShoppingBag, RefreshCw } from 'lucide-react';
import api from '../api';

export default function Settings() {
  const [settings, setSettings] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchSettings = (isRefresh = false) => {
    if (isRefresh) setRefreshing(true);
    else setLoading(true);

    api.get('/admin/settings')
      .then(res => setSettings(res.data.data))
      .catch(err => console.error(err))
      .finally(() => {
        setLoading(false);
        setRefreshing(false);
      });
  };

  useEffect(() => { fetchSettings(); }, []);

  const formatUptime = (seconds) => {
    const d = Math.floor(seconds / 86400);
    const h = Math.floor((seconds % 86400) / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    const parts = [];
    if (d > 0) parts.push(`${d}d`);
    if (h > 0) parts.push(`${h}h`);
    if (m > 0) parts.push(`${m}m`);
    parts.push(`${s}s`);
    return parts.join(' ');
  };

  const StatusDot = ({ active }) => (
    <span style={{
      display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%',
      background: active ? 'var(--success)' : 'var(--danger)',
      boxShadow: active ? '0 0 6px var(--success)' : '0 0 6px var(--danger)',
      marginRight: '0.5rem', flexShrink: 0,
    }} />
  );

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '60vh', color: 'var(--text-muted)' }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ width: '32px', height: '32px', border: '3px solid var(--accent-primary)', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.8s linear infinite', margin: '0 auto 1rem' }} />
          Loading settings...
        </div>
      </div>
    );
  }

  if (!settings) {
    return (
      <div style={{ textAlign: 'center', padding: '4rem', color: 'var(--text-muted)' }}>
        Failed to load settings. Check backend connection.
      </div>
    );
  }

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Settings2 size={28} color="var(--accent-primary)" /> Platform Settings
          </h1>
          <p style={{ color: 'var(--text-muted)', marginTop: '0.25rem', fontSize: '0.9rem' }}>System configuration and integration status</p>
        </div>
        <button
          className="btn btn-outline"
          onClick={() => fetchSettings(true)}
          disabled={refreshing}
          style={{ gap: '0.4rem' }}
        >
          <RefreshCw size={16} className={refreshing ? 'spinning' : ''} /> Refresh
        </button>
      </div>

      {/* Platform Info */}
      <div className="glass-card" style={{ marginBottom: '1.5rem', padding: '1.5rem' }}>
        <h3 style={{ marginBottom: '1.25rem', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Activity size={18} color="var(--accent-primary)" /> Platform Overview
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1rem' }}>
          <InfoCard icon={<Server size={20} />} label="App Name" value={settings.platform.name} accent="var(--accent-primary)" />
          <InfoCard icon={<HardDrive size={20} />} label="Version" value={settings.platform.version} accent="var(--accent-secondary)" />
          <InfoCard
            icon={<Activity size={20} />}
            label="Environment"
            value={settings.platform.environment}
            accent={settings.platform.environment === 'production' ? 'var(--success)' : 'var(--warning)'}
          />
        </div>
      </div>

      {/* Database Stats */}
      <div className="glass-card" style={{ marginBottom: '1.5rem', padding: '1.5rem' }}>
        <h3 style={{ marginBottom: '1.25rem', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Database size={18} color="var(--info)" /> Database Overview
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: '1rem' }}>
          <StatCard icon={<Users size={22} />} label="Customers" value={settings.counts.customers} color="var(--accent-primary)" />
          <StatCard icon={<Wrench size={22} />} label="Technicians" value={settings.counts.technicians} color="var(--accent-secondary)" />
          <StatCard icon={<ShoppingBag size={22} />} label="Total Orders" value={settings.counts.orders} color="var(--success)" />
          <StatCard icon={<Settings2 size={22} />} label="Services" value={settings.counts.services} color="var(--warning)" />
        </div>
      </div>

      {/* Integrations Status */}
      <div className="glass-card" style={{ marginBottom: '1.5rem', padding: '1.5rem' }}>
        <h3 style={{ marginBottom: '1.25rem', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Radio size={18} color="var(--success)" /> Integration Status
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1rem' }}>
          <IntegrationCard
            icon={<Mail size={20} />}
            name="Email (SMTP)"
            configured={settings.integrations.smtp.configured}
            detail={settings.integrations.smtp.host ? `Host: ${settings.integrations.smtp.host}` : 'Not configured'}
          />
          <IntegrationCard
            icon={<MessageSquare size={20} />}
            name="SMS (Twilio)"
            configured={settings.integrations.twilio.configured}
            detail={settings.integrations.twilio.configured ? 'API keys set' : 'Not configured'}
          />
          <IntegrationCard
            icon={<CreditCard size={20} />}
            name="Payments (Stripe)"
            configured={settings.integrations.stripe.configured}
            detail={settings.integrations.stripe.configured ? 'API keys set' : 'Not configured'}
          />
          <IntegrationCard
            icon={<Radio size={20} />}
            name="MQTT Broker"
            configured={settings.integrations.mqtt.configured}
            detail={settings.integrations.mqtt.url || 'Not configured'}
          />
          <IntegrationCard
            icon={<Database size={20} />}
            name="Redis Cache"
            configured={settings.integrations.redis.configured}
            detail={settings.integrations.redis.configured ? 'Connected' : 'Not configured'}
          />
        </div>
      </div>

      {/* System Info */}
      <div className="glass-card" style={{ padding: '1.5rem' }}>
        <h3 style={{ marginBottom: '1.25rem', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Server size={18} color="var(--accent-secondary)" /> System Information
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '1rem' }}>
          <SystemRow label="Node.js Version" value={settings.system.nodeVersion} />
          <SystemRow label="Platform" value={settings.system.platform} />
          <SystemRow label="Server Uptime" value={formatUptime(settings.system.uptime)} />
          <SystemRow
            label="MongoDB Status"
            value={
              <span style={{ display: 'flex', alignItems: 'center' }}>
                <StatusDot active={settings.system.mongoStatus === 'connected'} />
                {settings.system.mongoStatus}
              </span>
            }
          />
          <SystemRow label="Memory Usage" value={`${settings.system.memoryUsage} MB`} />
        </div>
      </div>

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinning { animation: spin 0.8s linear infinite; }
      `}</style>
    </div>
  );
}

/* ── Sub-components ──────────────────────────────────────────────────────────── */

function InfoCard({ icon, label, value, accent }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: '0.75rem',
      padding: '0.85rem 1rem', background: 'rgba(255,255,255,0.04)',
      borderRadius: 'var(--radius-md)', border: '1px solid var(--border-light)',
    }}>
      <div style={{ color: accent }}>{icon}</div>
      <div>
        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em' }}>{label}</div>
        <div style={{ fontWeight: 600, fontSize: '0.95rem', textTransform: 'capitalize' }}>{value}</div>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, color }) {
  return (
    <div style={{
      padding: '1.25rem 1rem', textAlign: 'center',
      background: 'rgba(255,255,255,0.03)', borderRadius: 'var(--radius-md)',
      border: '1px solid var(--border-light)',
      transition: 'all 0.2s',
    }}>
      <div style={{ color, marginBottom: '0.5rem' }}>{icon}</div>
      <div style={{ fontSize: '1.75rem', fontWeight: 700, color }}>{value}</div>
      <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>{label}</div>
    </div>
  );
}

function IntegrationCard({ icon, name, configured, detail }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: '0.85rem',
      padding: '1rem 1.15rem', background: configured ? 'rgba(16,185,129,0.06)' : 'rgba(239,68,68,0.06)',
      borderRadius: 'var(--radius-md)',
      border: `1px solid ${configured ? 'rgba(16,185,129,0.2)' : 'rgba(239,68,68,0.2)'}`,
    }}>
      <div style={{ color: configured ? 'var(--success)' : 'var(--danger)' }}>{icon}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>{name}</div>
        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{detail}</div>
      </div>
      <span className={`badge badge-${configured ? 'success' : 'danger'}`} style={{ fontSize: '0.7rem' }}>
        {configured ? 'Active' : 'Inactive'}
      </span>
    </div>
  );
}

function SystemRow({ label, value }) {
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '0.7rem 1rem', background: 'rgba(255,255,255,0.03)',
      borderRadius: 'var(--radius-md)', border: '1px solid var(--border-light)',
    }}>
      <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{label}</span>
      <span style={{ fontSize: '0.9rem', fontWeight: 500 }}>{value}</span>
    </div>
  );
}
