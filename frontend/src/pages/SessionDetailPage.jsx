import React, { useEffect, useState } from 'react';
import { useNavigate, useOutletContext, useParams } from 'react-router-dom';
import { createReservation, fetchSession, fetchSessionSeats } from '../api';

export default function SessionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { token } = useOutletContext();
  const [session, setSession] = useState(null);
  const [seats, setSeats] = useState([]);
  const [selected, setSelected] = useState([]);
  const [error, setError] = useState('');
  const [promotion, setPromotion] = useState('');

  useEffect(() => {
    fetchSession(id).then(setSession).catch(() => setError('Could not load session'));
    fetchSessionSeats(id).then(setSeats).catch(() => setError('Could not load seat map'));
  }, [id]);

  const toggleSeat = (seatId) => {
    setSelected((prev) =>
      prev.includes(seatId) ? prev.filter((s) => s !== seatId) : [...prev, seatId]
    );
  };

  const handleReserve = async () => {
    if (!token) {
      navigate('/login');
      return;
    }
    setError('');
    try {
      await createReservation(id, selected, promotion || null);
      alert('Reservation confirmed');
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Reservation failed');
    }
  };

  return (
    <div>
      <h2>Session #{id}</h2>
      {error && <div className="error">{error}</div>}
      {session && (
        <div className="card">
          <div className="row"><strong>Movie:</strong> {session.movie?.title}</div>
          <div className="row"><strong>Hall:</strong> {session.hall?.name}</div>
          <div className="row"><strong>Start:</strong> {new Date(session.startTime).toLocaleString()}</div>
          <div className="row"><strong>Price:</strong> ${session.basePrice}</div>
        </div>
      )}
      <div className="seat-grid">
        {seats.map((seat) => {
          const isBooked = seat.status === 'BOOKED';
          const isSelected = selected.includes(seat.seatId);
          return (
            <button
              key={seat.seatId}
              className={`seat ${isBooked ? 'booked' : isSelected ? 'selected' : ''}`}
              disabled={isBooked}
              onClick={() => toggleSeat(seat.seatId)}
            >
              {seat.label || `${seat.row}-${seat.number}`}
            </button>
          );
        })}
      </div>
      <div className="card" style={{ marginTop: '1rem' }}>
        <input
          placeholder="Promotion code (optional)"
          value={promotion}
          onChange={(e) => setPromotion(e.target.value)}
        />
        <button className="btn" onClick={handleReserve} disabled={selected.length === 0}>
          Reserve {selected.length} seat(s)
        </button>
      </div>
    </div>
  );
}
