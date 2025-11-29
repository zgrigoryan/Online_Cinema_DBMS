import React, { useEffect, useState } from 'react';
import { useNavigate, useOutletContext, useParams } from 'react-router-dom';
import { createReservation, fetchSession, fetchSessionSeats, purchaseReservation } from '../api';

export default function SessionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { token } = useOutletContext();
  const [session, setSession] = useState(null);
  const [seats, setSeats] = useState([]);
  const [selected, setSelected] = useState([]);
  const [error, setError] = useState('');
  const [promotion, setPromotion] = useState('');
  const [reservationId, setReservationId] = useState(null);
  const [paymentMethod, setPaymentMethod] = useState('CREDIT_CARD');

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
      const reservation = await createReservation(id, selected, promotion || null);
      setReservationId(reservation.id);
      alert('Reservation created. Complete purchase to confirm.');
    } catch (err) {
      setError(err.response?.data?.message || 'Reservation failed');
    }
  };

  const handlePurchase = async () => {
    if (!reservationId) return;
    setError('');
    try {
      await purchaseReservation(reservationId, paymentMethod, promotion || null);
      alert('Purchase completed');
      navigate('/history');
    } catch (err) {
      setError(err.response?.data?.message || 'Purchase failed');
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
          <div className="row"><strong>Price:</strong> ${session.sessionPrice}</div>
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
              <div>{seat.label || `${seat.row}-${seat.number}`}</div>
              <div className="muted">${seat.price?.toFixed(2)}</div>
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
        {!reservationId && (
          <button className="btn" onClick={handleReserve} disabled={selected.length === 0}>
            Reserve {selected.length} seat(s)
          </button>
        )}
        {reservationId && (
          <div className="purchase">
            <select value={paymentMethod} onChange={(e) => setPaymentMethod(e.target.value)}>
              <option value="CREDIT_CARD">Credit Card</option>
              <option value="DEBIT_CARD">Debit Card</option>
              <option value="PAYPAL">PayPal</option>
              <option value="CASH">Cash</option>
            </select>
            <button className="btn" onClick={handlePurchase}>
              Complete Purchase
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
