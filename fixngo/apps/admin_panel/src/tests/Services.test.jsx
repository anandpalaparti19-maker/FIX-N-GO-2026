import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Services from '../pages/Services';
import api from '../api';

vi.mock('../api', () => ({
  default: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
  }
}));

describe('Services Component DOM Elements', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders header, search bar, and add button', async () => {
    api.get.mockImplementation((url) => {
      if (url.includes('/admin/services')) {
        return Promise.resolve({ data: { data: [], total: 0, pages: 1 } });
      }
      return Promise.resolve({ data: { data: { brands: [] } } });
    });

    render(<Services />);

    expect(await screen.findByRole('heading', { name: /Services & Catalog/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Add Service/i })).toBeInTheDocument();
  });

  it('displays service list when data is loaded', async () => {
    const mockServices = [
      {
        _id: '1',
        title: 'Screen Repair',
        category: 'smartphone',
        basePrice: 1999,
        estimatedDuration: 60,
        isActive: true,
      },
      {
        _id: '2',
        title: 'Battery Replacement',
        category: 'laptop',
        basePrice: 2499,
        estimatedDuration: 45,
        isActive: false,
      }
    ];

    api.get.mockImplementation((url) => {
      if (url.includes('/admin/services')) {
        return Promise.resolve({ data: { data: mockServices, total: 2, pages: 1 } });
      }
      return Promise.resolve({ data: { data: { brands: [] } } });
    });

    render(<Services />);

    expect(await screen.findByText('Screen Repair')).toBeInTheDocument();
    expect(screen.getByText('Battery Replacement')).toBeInTheDocument();
  });
});
