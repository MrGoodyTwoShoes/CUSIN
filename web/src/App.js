import React, { useState, useEffect } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import './App.css';

const API_URL = 'https://cusin.onrender.com/api/v1';

function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [userId, setUserId] = useState(localStorage.getItem('userId'));

  const handleLogin = (newToken, newUserId) => {
    localStorage.setItem('token', newToken);
    localStorage.setItem('userId', newUserId);
    setToken(newToken);
    setUserId(newUserId);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('userId');
    setToken(null);
    setUserId(null);
  };

  return (
    <div className="App">
      {token ? (
        <Dashboard token={token} userId={userId} onLogout={handleLogout} />
      ) : (
        <Login onLogin={handleLogin} apiUrl={API_URL} />
      )}
    </div>
  );
}

export default App;
