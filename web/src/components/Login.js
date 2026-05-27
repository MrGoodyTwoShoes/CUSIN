import React, { useState } from 'react';
import axios from 'axios';
import './Login.css';

function Login({ onLogin, apiUrl }) {
  const [phone, setPhone] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [step, setStep] = useState('register'); // register or login

  const handleRegister = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const response = await axios.post(`${apiUrl}/auth/register`, { phone });
      if (response.data.success) {
        setStep('login');
        setError('');
      }
    } catch (err) {
      setError('Registration failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const response = await axios.post(`${apiUrl}/auth/login`, { phone });
      if (response.data.success) {
        onLogin(response.data.data.token, response.data.data.user_id);
      }
    } catch (err) {
      setError('Login failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>CUSIN</h1>
        <p>Civilian Urban Safety Intelligence Network</p>
        
        <form onSubmit={step === 'register' ? handleRegister : handleLogin}>
          <input
            type="tel"
            placeholder="Phone Number (+254...)"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            required
          />
          
          {error && <div className="error">{error}</div>}
          
          <button type="submit" disabled={isLoading} className="primary">
            {isLoading ? 'Processing...' : step === 'register' ? 'Register' : 'Login'}
          </button>
          
          {step === 'register' && (
            <p className="switch-step">
              Already registered? <button type="button" onClick={() => setStep('login')}>Login</button>
            </p>
          )}
        </form>
      </div>
    </div>
  );
}

export default Login;
