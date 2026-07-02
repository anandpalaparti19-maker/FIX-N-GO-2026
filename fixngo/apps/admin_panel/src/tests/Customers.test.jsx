import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Customers from '../pages/Customers';
import api from '../api';

// Mock the API calls
vi.mock('../api', () => ({
  default: {
    get: vi.fn(),
    patch: vi.fn(),
  }
}));

describe('Customers Component DOM Elements', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders header, search bar, and filter dropdown', async () => {
    // Mock the initial fetch response
    api.get.mockResolvedValueOnce({
      data: {
        data: [],
        total: 0,
        pages: 1,
      }
    });

    render(<Customers />);

    // Verify header exists
    expect(screen.getByRole('heading', { name: /Customer Management/i })).toBeInTheDocument();
    
    // Verify search input exists
    expect(screen.getByPlaceholderText(/Search by name, email, or phone/i)).toBeInTheDocument();

    // Verify filter dropdown exists
    expect(screen.getByRole('combobox')).toBeInTheDocument();
    
    await waitFor(() => {
      expect(api.get).toHaveBeenCalledWith(expect.stringContaining('/admin/customers'));
    });
  });

  it('displays customer list when data is loaded', async () => {
    const mockCustomers = [
      {
        _id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        accountStatus: 'active',
        createdAt: new Date().toISOString(),
      },
      {
        _id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '0987654321',
        accountStatus: 'suspended',
        createdAt: new Date().toISOString(),
      }
    ];

    api.get.mockResolvedValueOnce({
      data: {
        data: mockCustomers,
        total: 2,
        pages: 1,
      }
    });

    render(<Customers />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('jane@example.com')).toBeInTheDocument();
      expect(screen.getByText('suspended')).toBeInTheDocument();
    });
  });
});
