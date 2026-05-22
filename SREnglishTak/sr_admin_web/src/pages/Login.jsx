import React, { useState } from 'react';
import { ShieldCheck, Loader2, Info } from 'lucide-react';
import { GoogleLogin } from '@react-oauth/google';
import axios from 'axios';

const Login = ({ onLoginSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSuccess = async (credentialResponse) => {
    setLoading(true);
    setError('');
    
    try {
      // Send the ID Token to the backend
      const API_URL = import.meta.env.VITE_API_URL || 'https://book-backned.vercel.app/api';
      const response = await axios.post(`${API_URL}/auth/google`, {
        id_token: credentialResponse.credential
      });

      const { session, user } = response.data;
      
      if (user.role !== 'admin') {
        setError('Access denied. This account does not have admin privileges.');
        setLoading(false);
        return;
      }

      localStorage.setItem('admin_token', session.access_token);
      localStorage.setItem('admin_user', JSON.stringify(user));
      
      onLoginSuccess();
    } catch (err) {
      console.error('Login error:', err);
      setError(err.response?.data?.error || 'Authentication failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-container" style={{ justifyContent: 'center', alignItems: 'center' }}>
      <div className="animate-fade-in" style={{ width: '100%', maxWidth: '420px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2.5rem' }}>
          <div className="stat-icon" style={{ 
            background: 'var(--primary)', 
            margin: '0 auto 1.5rem', 
            width: '64px', 
            height: '64px' 
          }}>
            <ShieldCheck size={32} color="white" />
          </div>
          <h1 style={{ fontSize: '2rem', fontWeight: '800', marginBottom: '0.5rem' }}>Admin Portal</h1>
          <p style={{ color: 'var(--text-muted)' }}>Secure access for SR English Tak management.</p>
        </div>

        <div className="data-table-container" style={{ padding: '2.5rem', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          {error && (
            <div style={{ 
              background: 'rgba(244, 63, 94, 0.1)', 
              color: '#fb7185', 
              padding: '0.75rem 1rem', 
              borderRadius: '12px', 
              fontSize: '0.875rem',
              marginBottom: '1.5rem',
              border: '1px solid rgba(244, 63, 94, 0.2)',
              width: '100%'
            }}>
              {error}
            </div>
          )}

          <div style={{ width: '100%', display: 'flex', justifyContent: 'center' }}>
            <GoogleLogin
              onSuccess={handleSuccess}
              onError={() => setError('Google Sign-In failed. Please try again.')}
              useOneTap
              theme="filled_blue"
              shape="pill"
              size="large"
              width="320"
            />
          </div>

          {loading && (
            <div style={{ marginTop: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--primary)' }}>
              <Loader2 className="animate-spin" size={18} />
              <span style={{ fontWeight: '600' }}>Verifying Admin Identity...</span>
            </div>
          )}

          <div style={{ marginTop: '2rem', padding: '1rem', background: 'rgba(255,255,255,0.02)', borderRadius: '12px', display: 'flex', gap: '0.75rem' }}>
            <Info size={18} color="var(--text-muted)" style={{ flexShrink: 0 }} />
            <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', lineHeight: '1.4' }}>
              Only authorized administrators can access this dashboard. Please sign in with your registered work email.
            </p>
          </div>
        </div>

        <p style={{ textAlign: 'center', marginTop: '2rem', fontSize: '0.875rem', color: 'var(--text-muted)' }}>
          © {new Date().getFullYear()} SR English Tak • Cloud Infrastructure
        </p>
      </div>
    </div>
  );
};

export default Login;
