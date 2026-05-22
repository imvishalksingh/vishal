import React, { useState, useEffect } from 'react';
import { Lightbulb, Plus, Trash2, Calendar, Search, Sparkles, Send } from 'lucide-react';
import { ApiService } from '../services/apiService';

const DailyTips = () => {
  const [tips, setTips] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ content: '', title: 'Grammar Tip' });

  useEffect(() => {
    fetchTips();
  }, []);

  const fetchTips = async () => {
    try {
      const response = await ApiService.getDailyTips();
      setTips(response.data);
    } catch (error) {
      console.error('Error fetching tips:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await ApiService.createDailyTip(form);
      setShowModal(false);
      fetchTips();
      setForm({ content: '', title: 'Grammar Tip' });
    } catch (error) {
      alert('Error creating tip');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this tip?')) {
      try {
        await ApiService.deleteDailyTip(id);
        fetchTips();
      } catch (error) {
        alert('Error deleting tip');
      }
    }
  };

  return (
    <div className="animate-fade-in">
      <div className="header-bar">
        <div className="page-title">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#8b5cf6', marginBottom: '0.25rem' }}>
            <Sparkles size={16} />
            <span style={{ fontSize: '0.75rem', fontWeight: '700', textTransform: 'uppercase' }}>Engagement Engine</span>
          </div>
          <h1>Daily Study Tips</h1>
        </div>
        <button className="btn btn-primary" style={{ background: '#8b5cf6' }} onClick={() => setShowModal(true)}>
          <Plus size={18} /> New Daily Tip
        </button>
      </div>

      <div className="data-table-container" style={{ marginTop: '1.5rem' }}>
        <div className="table-header" style={{ padding: '1.25rem' }}>
           <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
             <Lightbulb size={20} color="#8b5cf6" />
             <h3 style={{ fontSize: '1rem' }}>Active Tips Buffer</h3>
           </div>
           <div style={{ display: 'flex', gap: '0.75rem' }}>
              <div className="btn-ghost" style={{ padding: '0.4rem 0.8rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Search size={16} color="var(--text-muted)" />
                <input 
                  type="text" 
                  placeholder="Search tips..." 
                  style={{ background: 'none', border: 'none', padding: 0, fontSize: '0.8125rem', width: '180px' }}
                />
              </div>
           </div>
        </div>

        <table style={{ width: '100%' }}>
          <thead>
            <tr>
              <th>Date Added</th>
              <th>Category</th>
              <th>Tip Content</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="4" style={{ textAlign: 'center', padding: '4rem' }}><Lightbulb className="animate-spin" /></td></tr>
            ) : tips.map((tip) => (
              <tr key={tip.id}>
                <td style={{ width: '180px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.875rem' }}>
                    <Calendar size={14} color="var(--text-muted)" />
                    {new Date(tip.created_at).toLocaleDateString()}
                  </div>
                </td>
                <td style={{ width: '150px' }}>
                  <span className="status-badge" style={{ background: 'rgba(139, 92, 246, 0.1)', color: '#8b5cf6' }}>{tip.title}</span>
                </td>
                <td>
                  <p style={{ fontSize: '0.9375rem', lineHeight: '1.5', maxWidth: '600px' }}>{tip.content}</p>
                </td>
                <td style={{ width: '100px' }}>
                  <button className="btn btn-ghost" style={{ padding: '0.5rem', color: '#f43f5e' }} onClick={() => handleDelete(tip.id)}>
                    <Trash2 size={18} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1.5rem' }}>
               <div style={{ background: '#8b5cf6', padding: '0.5rem', borderRadius: '10px' }}>
                  <Send size={20} color="white" />
               </div>
               <h2>Push New Daily Tip</h2>
            </div>
            <form onSubmit={handleCreate}>
              <div className="form-group">
                <label>Tip Category/Title</label>
                <input type="text" required placeholder="e.g. Grammar Hack, Pronunciation Tip" value={form.title} onChange={e => setForm({...form, title: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Content</label>
                <textarea rows="5" required placeholder="Type your tip here..." value={form.content} onChange={e => setForm({...form, content: e.target.value})}></textarea>
              </div>
              <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setShowModal(false)}>Discard</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, background: '#8b5cf6' }}>Push to Users</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default DailyTips;
