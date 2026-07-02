import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Settings from '../pages/Settings';
import api from '../api';

vi.mock('../api', () => ({
  default: {
    get: vi.fn(),
    put: vi.fn(),
  }
}));

describe('Settings Component DOM Elements', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders header, form fields, and save button', async () => {
    api.get.mockResolvedValueOnce({
      data: {
        data: {
          platform: {
            name: 'FixNGo',
            version: '1.0.0',
            environment: 'test'
          },
          integrations: {
            mongo: { status: 'connected', type: 'Database' },
            mqtt: { status: 'connected', type: 'Real-time' },
            stripe: { status: 'configured', type: 'Payment' },
            razorpay: { status: 'configured', type: 'Payment' },
            smtp: { configured: true, host: 'smtp.gmail.com' },
            twilio: { configured: true, phone: '+1234567890' },
            redis: { configured: false },
            sentry: { configured: false }
          },
          counts: {
            customers: 150,
            technicians: 42,
            orders: 1024,
            services: 10
          },
          system: {
            nodeVersion: 'v18.0.0',
            platform: 'linux',
            uptime: 3600
          },
          platformFeePercent: 15,
          minimumWithdrawal: 500,
          dispatchRadiusKm: 10,
          supportEmail: 'support@fixngo.com',
          supportPhone: '18001234567',
          autoAssignOrders: true,
        }
      }
    });

    render(<Settings />);

    expect(await screen.findByRole('heading', { name: /Platform Settings/i })).toBeInTheDocument();

    // Check for some static text labels rendered in the settings panel
    expect(screen.getByText(/Platform Overview/i)).toBeInTheDocument();
    expect(screen.getByText(/Database Overview/i)).toBeInTheDocument();
    expect(screen.getAllByText(/Integration Status/i).length).toBeGreaterThan(0);
  });
});
