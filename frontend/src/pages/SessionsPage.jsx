import React, { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { fetchSessionsByMovie } from '../api';

export default function SessionsPage() {
  const { movieId } = useParams();
  const [sessions, setSessions] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchSessionsByMovie(movieId)
      .then(setSessions)
      .catch(() => setError('Could not load sessions'));
  }, [movieId]);

  return (
    <div>
      <h2>Sessions for movie #{movieId}</h2>
      {error && <div className="error">{error}</div>}
      <div className="list">
        {sessions.map((s) => (
          <div key={s.id} className="card">
            <div className="row"><strong>Hall:</strong> {s.hall?.name}</div>
            <div className="row"><strong>Start:</strong> {new Date(s.startTime).toLocaleString()}</div>
            <div className="row"><strong>End:</strong> {new Date(s.endTime).toLocaleString()}</div>
            <div className="row"><strong>Price:</strong> ${s.basePrice}</div>
            <div className="row"><strong>Available seats:</strong> {s.availableSeats}</div>
            <Link className="btn" to={`/sessions/${s.id}`}>Book</Link>
          </div>
        ))}
        {sessions.length === 0 && !error && <p>No sessions found.</p>}
      </div>
    </div>
  );
}
