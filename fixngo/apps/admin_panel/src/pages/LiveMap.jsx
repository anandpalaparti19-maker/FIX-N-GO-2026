import { useState, useEffect, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { RefreshCw, Wifi, WifiOff } from 'lucide-react';
import api from '../api';

// Fix Leaflet default marker icon issue with Vite
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

const onlineIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

function secondsAgo(dateStr) {
  const diff = Math.floor((Date.now() - new Date(dateStr)) / 1000);
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  return `${Math.floor(diff / 3600)}h ago`;
}

export default function LiveMap() {
  const [technicians, setTechnicians] = useState([]);
  const [loading, setLoading] = useState(true);
  const [lastRefresh, setLastRefresh] = useState(null);
  const [center] = useState([20.5937, 78.9629]); // India center

  const fetchMap = useCallback(() => {
    api.get('/admin/live-map')
      .then(res => {
        setTechnicians(res.data.data || []);
        setLastRefresh(new Date());
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    fetchMap();
    const interval = setInterval(fetchMap, 10000);
    return () => clearInterval(interval);
  }, [fetchMap]);

  const validTechs = technicians.filter(t => t.lat && t.lng);

  return (
    <div style={{ animation: 'fadeIn 0.4s ease' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ marginBottom: '0.25rem' }}>Live Map</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            {validTechs.length} technician{validTechs.length !== 1 ? 's' : ''} online
            {lastRefresh && ` · updated ${secondsAgo(lastRefresh)}`}
          </p>
        </div>
        <button className="btn btn-outline" onClick={fetchMap} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <RefreshCw size={15} /> Refresh
        </button>
      </div>

      {/* Technician cards row */}
      <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.5rem', overflowX: 'auto', paddingBottom: '0.5rem' }}>
        {loading ? (
          <div style={{ color: 'var(--text-muted)', padding: '1rem' }}>Loading technicians...</div>
        ) : technicians.length === 0 ? (
          <div className="glass-card" style={{ padding: '1rem', color: 'var(--text-muted)', minWidth: '200px' }}>
            No technicians online right now.
          </div>
        ) : technicians.map(t => (
          <div key={t._id} className="glass-card" style={{ minWidth: '180px', padding: '1rem', flexShrink: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
              {t.isOnline
                ? <Wifi size={14} color="var(--success)" />
                : <WifiOff size={14} color="var(--text-muted)" />}
              <span style={{ fontWeight: 600, fontSize: '0.9rem' }}>{t.name}</span>
            </div>
            <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>{t.phone}</div>
            {t.specialization?.length > 0 && (
              <div style={{ fontSize: '0.72rem', color: 'var(--accent-primary)', marginTop: '0.25rem' }}>
                {t.specialization.slice(0, 2).join(', ')}
              </div>
            )}
            <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
              {t.lat && t.lng ? `${t.lat.toFixed(4)}, ${t.lng.toFixed(4)}` : 'No location'}
            </div>
            <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
              Last seen: {secondsAgo(t.lastSeen)}
            </div>
          </div>
        ))}
      </div>

      {/* Map */}
      <div className="glass-panel" style={{ padding: 0, overflow: 'hidden', borderRadius: '1rem', height: '520px' }}>
        <MapContainer
          center={validTechs.length > 0 ? [validTechs[0].lat, validTechs[0].lng] : center}
          zoom={validTechs.length > 0 ? 12 : 5}
          style={{ height: '100%', width: '100%' }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {validTechs.map(t => (
            <Marker key={t._id} position={[t.lat, t.lng]} icon={onlineIcon}>
              <Popup>
                <div style={{ minWidth: '160px' }}>
                  <div style={{ fontWeight: 700, marginBottom: '0.25rem' }}>{t.name}</div>
                  <div style={{ fontSize: '0.8rem', color: '#666' }}>{t.phone}</div>
                  {t.specialization?.length > 0 && (
                    <div style={{ fontSize: '0.75rem', color: '#888', marginTop: '0.25rem' }}>
                      {t.specialization.join(', ')}
                    </div>
                  )}
                  <div style={{ fontSize: '0.72rem', color: '#999', marginTop: '0.5rem' }}>
                    Updated: {secondsAgo(t.lastSeen)}
                  </div>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
    </div>
  );
}
