import React, { useState, useEffect } from 'react';
import { Search, User, Mail, Shield, ChevronRight, Loader2 } from 'lucide-react';
import { ApiService } from '../services/apiService';

const Students = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await ApiService.getUsers();
        setUsers(response.data);
      } catch (error) {
        console.error('Error fetching users:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchUsers();
  }, []);

  const filteredUsers = users.filter(user => 
    user.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in">
      <div className="header-bar">
        <div className="page-title">
          <h1>Student Directory</h1>
          <p>Manage and monitor your student community.</p>
        </div>
        <div className="btn-ghost" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Search size={18} color="var(--text-muted)" />
          <input 
            type="text" 
            placeholder="Search students..." 
            style={{ background: 'none', border: 'none', padding: 0, fontSize: '0.875rem', width: '200px' }}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="data-table-container">
        <div className="table-header">
          <h3 style={{ fontSize: '1rem' }}>Registered Users ({filteredUsers.length})</h3>
        </div>
        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Role</th>
              <th>Joined Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="4" style={{ textAlign: 'center', padding: '5rem' }}>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem' }}>
                  <Loader2 className="animate-spin" size={32} color="var(--primary)" />
                  <span style={{ color: 'var(--text-muted)' }}>Retrieving student directory...</span>
                </div>
              </td></tr>
            ) : filteredUsers.length === 0 ? (
              <tr><td colSpan="4" style={{ textAlign: 'center', padding: '3rem' }}>No students found.</td></tr>
            ) : (
              filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                      <div style={{ 
                        width: '40px', 
                        height: '40px', 
                        borderRadius: '12px', 
                        background: 'var(--glass)', 
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'center',
                        border: '1px solid var(--glass-border)'
                      }}>
                        <User size={20} color="var(--primary)" />
                      </div>
                      <div>
                        <div style={{ fontWeight: '600' }}>{user.full_name || 'Unnamed Student'}</div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                          <Mail size={12} /> {user.email}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className={`status-badge ${user.role === 'admin' ? 'status-active' : 'status-pending'}`}>
                      {user.role?.toUpperCase() || 'USER'}
                    </span>
                  </td>
                  <td style={{ color: 'var(--text-muted)' }}>
                    {new Date(user.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                  </td>
                  <td>
                    <button className="btn btn-ghost" style={{ padding: '0.4rem' }}>
                      <ChevronRight size={18} />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Students;
