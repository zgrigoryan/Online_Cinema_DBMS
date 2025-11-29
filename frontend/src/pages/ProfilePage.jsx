import React, { useState } from 'react';
import { useOutletContext } from 'react-router-dom';
import { updateProfile } from '../api';

export default function ProfilePage() {
  const { token } = useOutletContext();
  const [form, setForm] = useState({ firstName: '', lastName: '', email: '', phone: '' });
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  if (!token) {
    return <div className="error">Login to edit your profile.</div>;
  }

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setMessage('');
    try {
      await updateProfile(form);
      setMessage('Profile updated.');
    } catch (err) {
      setError(err.response?.data?.message || 'Update failed');
    }
  };

  return (
    <div className="card">
      <h2>Profile</h2>
      <form className="form" onSubmit={handleSubmit}>
        <input name="firstName" placeholder="First name" value={form.firstName} onChange={handleChange} required />
        <input name="lastName" placeholder="Last name" value={form.lastName} onChange={handleChange} required />
        <input name="email" type="email" placeholder="Email" value={form.email} onChange={handleChange} />
        <input name="phone" placeholder="Phone" value={form.phone} onChange={handleChange} />
        {error && <div className="error">{error}</div>}
        {message && <div className="success">{message}</div>}
        <button className="btn" type="submit">Save</button>
      </form>
    </div>
  );
}
