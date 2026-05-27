import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Dashboard.css';

const API_URL = 'https://cusin.onrender.com/api/v1';

function Dashboard({ token, userId, onLogout }) {
  const [incidents, setIncidents] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showReportForm, setShowReportForm] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState({
    type: '',
    description: '',
    severity: 'low',
    latitude: -1.2921,
    longitude: 36.8219
  });

  useEffect(() => {
    loadIncidents();
  }, [token]);

  const loadIncidents = async () => {
    try {
      const response = await axios.get(`${API_URL}/incidents`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setIncidents(response.data.data || []);
    } catch (err) {
      setError('Failed to load incidents');
    } finally {
      setIsLoading(false);
    }
  };

  const handleReport = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${API_URL}/incidents`, formData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setShowReportForm(false);
      setFormData({ type: '', description: '', severity: 'low', latitude: -1.2921, longitude: 36.8219 });
      loadIncidents();
    } catch (err) {
      setError('Failed to report incident');
    }
  };

  return (
    <div className="dashboard">
      <header>
        <h1>CUSIN Dashboard</h1>
        <button onClick={onLogout} className="danger">Logout</button>
      </header>

      {error && <div className="error">{error}</div>}

      <div className="dashboard-content">
        <div className="incidents-section">
          <div className="section-header">
            <h2>Recent Incidents</h2>
            <button onClick={() => setShowReportForm(true)} className="primary">
              + Report Incident
            </button>
          </div>

          {isLoading ? (
            <p>Loading...</p>
          ) : incidents.length === 0 ? (
            <p>No incidents reported yet</p>
          ) : (
            <div className="incidents-list">
              {incidents.map((incident) => (
                <div key={incident.id} className="incident-card">
                  <h3>{incident.type || 'Unknown Type'}</h3>
                  <p>{incident.description || 'No description'}</p>
                  <div className="incident-meta">
                    <span className={`severity ${incident.severity}`}>{incident.severity}</span>
                    <span>{new Date(incident.created_at).toLocaleDateString()}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {showReportForm && (
          <div className="modal">
            <div className="modal-content">
              <h2>Report Incident</h2>
              <form onSubmit={handleReport}>
                <input
                  type="text"
                  placeholder="Incident Type"
                  value={formData.type}
                  onChange={(e) => setFormData({...formData, type: e.target.value})}
                  required
                />
                <textarea
                  placeholder="Description"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  required
                />
                <select
                  value={formData.severity}
                  onChange={(e) => setFormData({...formData, severity: e.target.value})}
                >
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                </select>
                <div className="form-actions">
                  <button type="button" onClick={() => setShowReportForm(false)}>Cancel</button>
                  <button type="submit" className="primary">Submit</button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Dashboard;
