import React, { useEffect, useState } from 'react';
import { Link, Outlet, useNavigate } from 'react-router-dom';
import { setAuthToken } from './api';

export default function App() {
  const navigate = useNavigate();
  const [token, setToken] = useState(() => localStorage.getItem('token'));

  useEffect(() => {
    setAuthToken(token);
  }, [token]);

  const handleLogout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setAuthToken(null);
    navigate('/login');
  };

  return (
    <div className="layout">
      <header className="header">
        <Link to="/" className="brand">Online Cinema</Link>
        <nav className="nav">
          <Link to="/">Movies</Link>
          {token && <Link to="/history">My Reservations</Link>}
          {token && <Link to="/profile">Profile</Link>}
          {token ? (
            <button className="btn" onClick={handleLogout}>Logout</button>
          ) : (
            <>
              <Link to="/login">Login</Link>
              <Link to="/register">Register</Link>
            </>
          )}
        </nav>
      </header>
      <main className="content">
        <Outlet context={{ token, setToken }} />
      </main>
    </div>
  );
}
