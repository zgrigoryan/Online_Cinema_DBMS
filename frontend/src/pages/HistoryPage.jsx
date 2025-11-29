import React, { useEffect, useState } from 'react';
import { useOutletContext } from 'react-router-dom';
import { fetchHistory } from '../api';

export default function HistoryPage() {
  const { token } = useOutletContext();
  const [rows, setRows] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!token) return;
    fetchHistory()
      .then(setRows)
      .catch(() => setError('Could not load history'));
  }, [token]);

  if (!token) {
    return <div className="error">Login to view your reservations.</div>;
  }

  return (
    <div>
      <h2>My Reservations</h2>
      {error && <div className="error">{error}</div>}
      <div className="list">
        {rows.map((r) => (
          <div className="card" key={r.reservationId}>
            <div className="row"><strong>Status:</strong> {r.status}</div>
            <div className="row"><strong>Movie:</strong> {r.movieTitle}</div>
            <div className="row"><strong>Hall:</strong> {r.hallName}</div>
            <div className="row"><strong>Show:</strong> {r.showDate} {r.startTime}</div>
            <div className="row"><strong>Total:</strong> ${r.totalAmount}</div>
            {r.promotionCode && <div className="row"><strong>Promo:</strong> {r.promotionCode}</div>}
            <div className="row"><strong>Tickets:</strong> {r.tickets.map(t => `${t.row}-${t.number} (${t.category})`).join(', ')}</div>
          </div>
        ))}
        {rows.length === 0 && !error && <p>No reservations yet.</p>}
      </div>
    </div>
  );
}
