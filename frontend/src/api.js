import axios from 'axios';

const api = axios.create({
  baseURL: '/api'
});

export function setAuthToken(token) {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}

export async function login(email, password) {
  const { data } = await api.post('/auth/login', { email, password });
  return data.token;
}

export async function register(payload) {
  const { data } = await api.post('/auth/register', payload);
  return data.token;
}

export async function updateProfile(payload) {
  const { data } = await api.put('/customers/me', payload);
  return data;
}

export async function fetchMovies() {
  const { data } = await api.get('/movies');
  return data;
}

export async function fetchSessionsByMovie(movieId) {
  const { data } = await api.get(`/sessions?movieId=${movieId}`);
  return data;
}

export async function fetchSession(sessionId) {
  const { data } = await api.get(`/sessions/${sessionId}`);
  return data;
}

export async function fetchSessionSeats(sessionId) {
  const { data } = await api.get(`/sessions/${sessionId}/seats`);
  return data;
}

export async function createReservation(sessionId, seatIds, promotionCode) {
  const { data } = await api.post('/reservations', { sessionId, seatIds, promotionCode });
  return data;
}

export async function purchaseReservation(reservationId, paymentMethod, promotionCode) {
  const { data } = await api.post(`/reservations/${reservationId}/purchase`, { paymentMethod, promotionCode });
  return data;
}

export async function fetchHistory() {
  const { data } = await api.get('/reservations/history');
  return data;
}

export default api;
