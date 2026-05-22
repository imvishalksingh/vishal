import React, { useState, useEffect } from 'react';
import { Users, BookOpen, FileQuestion, Trophy, Timer, Flame, CheckCircle, Loader2 } from 'lucide-react';
import { ApiService } from '../services/apiService';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await ApiService.getStats();
        setStats(response.data);
      } catch (error) {
        console.error('Error fetching stats:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '60vh', gap: '1rem' }}>
      <Loader2 className="animate-spin" size={48} color="var(--primary)" />
      <span style={{ color: 'var(--text-muted)', fontWeight: '600' }}>Preparing Dashboard...</span>
    </div>
  );

  const statCards = [
    { label: 'Total Students', value: stats?.totalUsers || 0, icon: Users, color: '#6366f1' },
    { label: 'Books Published', value: stats?.totalBooks || 0, icon: BookOpen, color: '#3b82f6' },
    { label: 'Active Quizzes', value: stats?.totalQuizzes || 0, icon: Trophy, color: '#f59e0b' },
    { label: 'Reading Minutes', value: stats?.readingMinutesToday || 0, icon: Timer, color: '#10b981' },
  ];

  return (
    <div className="animate-fade-in">
      <div className="header-bar">
        <div className="page-title">
          <h1>Admin Overview</h1>
          <p>Welcome back! Here's what's happening with SR English Tak today.</p>
        </div>
      </div>

      <div className="stats-grid">
        {statCards.map((card, i) => (
          <div key={i} className="stat-card">
            <div className="stat-icon" style={{ background: `${card.color}20`, color: card.color }}>
              <card.icon size={24} />
            </div>
            <div className="stat-value">{card.value}</div>
            <div className="stat-label">{card.label}</div>
          </div>
        ))}
      </div>

      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))' }}>
        <div className="data-table-container" style={{ padding: '2rem' }}>
          <h3 style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <Flame color="#f43f5e" size={20} />
            Activity Metrics
          </h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>7d Active Readers</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700' }}>{stats?.activeReaders7d || 0}</div>
            </div>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Total Sessions</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700' }}>{stats?.totalReadingSessions || 0}</div>
            </div>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Completed Books</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700' }}>{stats?.completedBooks || 0}</div>
            </div>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Quizzes Taken</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700' }}>{stats?.totalQuizResults || 0}</div>
            </div>
          </div>
        </div>

        <div className="data-table-container" style={{ padding: '2rem' }}>
          <h3 style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <CheckCircle color="#10b981" size={20} />
            System Status
          </h3>
          <div className="nav-menu" style={{ padding: 0 }}>
             <div className="nav-link" style={{ background: 'rgba(255,255,255,0.03)', marginBottom: '0.75rem' }}>
               <span>API Backend</span>
               <span className="status-badge status-active" style={{ marginLeft: 'auto' }}>Operational</span>
             </div>
             <div className="nav-link" style={{ background: 'rgba(255,255,255,0.03)', marginBottom: '0.75rem' }}>
               <span>Database</span>
               <span className="status-badge status-active" style={{ marginLeft: 'auto' }}>Healthy</span>
             </div>
             <div className="nav-link" style={{ background: 'rgba(255,255,255,0.03)', marginBottom: '0.75rem' }}>
               <span>Authentication</span>
               <span className="status-badge status-active" style={{ marginLeft: 'auto' }}>Operational</span>
             </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
