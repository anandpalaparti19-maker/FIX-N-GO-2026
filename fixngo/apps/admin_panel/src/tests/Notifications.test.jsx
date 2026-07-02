import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Notifications from '../pages/Notifications';
import api from '../api';

vi.mock('../api', () => ({
  default: {
    post: vi.fn(),
  }
}));

describe('Notifications Component DOM Elements', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders title, inputs, and send button', () => {
    render(<Notifications />);

    expect(screen.getByRole('heading', { name: /Notifications/i })).toBeInTheDocument();
    expect(screen.getByText(/Compose Broadcast/i)).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/Notification title.../i)).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/Write your notification message.../i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Send Broadcast/i })).toBeInTheDocument();
    
    // Check audiences
    expect(screen.getByText('Everyone')).toBeInTheDocument();
    expect(screen.getByText('Customers')).toBeInTheDocument();
    expect(screen.getByText('Technicians')).toBeInTheDocument();
  });

  it('handles user input and API call correctly', async () => {
    api.post.mockResolvedValueOnce({
      data: { recipientCount: 50 }
    });

    render(<Notifications />);

    const titleInput = screen.getByPlaceholderText(/Notification title.../i);
    const messageInput = screen.getByPlaceholderText(/Write your notification message.../i);
    const sendButton = screen.getByRole('button', { name: /Send Broadcast/i });

    // Initially button should be disabled because fields are empty
    expect(sendButton).toBeDisabled();

    // Type in fields
    fireEvent.change(titleInput, { target: { value: 'Test Title' } });
    fireEvent.change(messageInput, { target: { value: 'Test Message' } });

    // Button should now be enabled
    expect(sendButton).not.toBeDisabled();

    // Click send
    fireEvent.click(sendButton);

    expect(sendButton).toBeDisabled(); // while sending
    expect(screen.getByText(/Sending.../i)).toBeInTheDocument();

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith('/admin/notifications/broadcast', {
        title: 'Test Title',
        message: 'Test Message',
        audience: 'all' // default
      });
      // Should show success message
      expect(screen.getByText(/Sent to 50 recipients/i)).toBeInTheDocument();
    });
  });
});
