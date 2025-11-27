import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { fetchSessionsByMovie } from '../api';

export default function SessionPage() {
  const { id } = useParams();
  const [sessions, setSessions] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchSessionsByMovie(id)
      .then(setSessions)
      .catch(() => setError('Could not load sessions'));
  }, [id]);

  return (
    <div>
      <h2>Sessions for movie #{id}</h2>
      {error && <div className="error">{error}</div>}
      <div className="list">
        {sessions.map((s) => (
          <div key={s.id} className="card">
            <div className="row">
              <strong>Hall:</strong> {s.hall?.name}
            </div>
            <div className="row">
              <strong>Start:</strong> {new Date(s.startTime).toLocaleString()}
            </div>
            <div className="row">
              <strong>End:</strong> {new Date(s.endTime).toLocaleString()}
            </div>
            <div className="row">
              <strong>Price:</strong> ${s.basePrice}
            </div>
            <div className="row">
              <strong>Available seats:</strong> {s.availableSeats}
            </div>
          </div>
        ))}
        {sessions.length === 0 && !error && <p>No sessions found.</p>}
      </div>
    </div>
  );
}
