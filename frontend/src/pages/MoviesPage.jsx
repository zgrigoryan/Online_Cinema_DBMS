import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { fetchMovies } from '../api';

export default function MoviesPage() {
  const [movies, setMovies] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchMovies()
      .then(setMovies)
      .catch(() => setError('Could not load movies'));
  }, []);

  return (
    <div>
      <h2>Now Showing</h2>
      {error && <div className="error">{error}</div>}
      <div className="grid">
        {movies.map((m) => (
          <div key={m.id} className="card">
            <h3>{m.title}</h3>
            <p>{m.description}</p>
            <p className="muted">{m.durationMinutes} min</p>
            <Link className="btn" to={`/sessions/${m.id}`}>Sessions</Link>
          </div>
        ))}
      </div>
    </div>
  );
}
