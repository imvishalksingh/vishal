import React, { useState, useEffect } from 'react';
import { 
  Languages, Plus, Trash2, Search, Volume2, 
  BookOpen, Clock, FileUp, Zap, CheckCircle, 
  AlertCircle, Download, X, Save, Edit3, Loader2 
} from 'lucide-react';
import { ApiService } from '../services/apiService';

const Vocabulary = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  // View states
  const [activeTab, setActiveTab] = useState('directory'); // 'directory' or 'bulk'
  const [showModal, setShowModal] = useState(false);
  
  // Forms
  const [form, setForm] = useState({ word: '', meaning: '', example_sentence: '', category: 'Advanced' });
  const [bulkText, setBulkText] = useState('');
  const [bulkPreview, setBulkPreview] = useState([]);
  const [isRapidMode, setIsRapidMode] = useState(false);

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      const response = await ApiService.getVocabulary();
      setItems(response.data);
    } catch (error) {
      console.error('Error fetching vocabulary:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await ApiService.createVocabulary(form);
      if (isRapidMode) {
        setForm({ ...form, word: '', meaning: '', example_sentence: '' });
        // Keep category the same for speed
        fetchItems();
      } else {
        setShowModal(false);
        fetchItems();
        setForm({ word: '', meaning: '', example_sentence: '', category: 'Advanced' });
      }
    } catch (error) {
      alert('Error adding word');
    }
  };

  const handleBulkParse = () => {
    // Expected format: Word | Meaning | Example (one per line)
    const lines = bulkText.split('\n').filter(l => l.trim().length > 0);
    const parsed = lines.map(line => {
      const parts = line.split('|').map(p => p.trim());
      return {
        word: parts[0] || '',
        meaning: parts[1] || '',
        example_sentence: parts[2] || '',
        category: 'Bulk Import'
      };
    });
    setBulkPreview(parsed);
  };

  const handleBulkSubmit = async () => {
    setLoading(true);
    try {
      const validItems = bulkPreview.filter(item => item.word && item.meaning);
      await ApiService.bulkCreateVocabulary(validItems);
      setBulkText('');
      setBulkPreview([]);
      setActiveTab('directory');
      fetchItems();
    } catch (error) {
      alert('Bulk upload failed: ' + (error.response?.data?.error || error.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this word?')) {
      try {
        await ApiService.deleteVocabulary(id);
        fetchItems();
      } catch (error) {
        alert('Error deleting word');
      }
    }
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', height: 'calc(100vh - 100px)' }}>
      <div className="header-bar">
        <div className="page-title">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#0ea5e9', marginBottom: '0.25rem' }}>
            <Languages size={16} />
            <span style={{ fontSize: '0.75rem', fontWeight: '700', textTransform: 'uppercase' }}>Word Bank Control</span>
          </div>
          <h1>Vocabulary Hub</h1>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button className={`btn ${activeTab === 'bulk' ? 'btn-primary' : 'btn-ghost'}`} style={{ background: activeTab === 'bulk' ? '#0ea5e9' : 'none' }} onClick={() => setActiveTab('bulk')}>
            <FileUp size={18} /> Bulk Import
          </button>
          <button className="btn btn-primary" style={{ background: '#0ea5e9' }} onClick={() => { setShowModal(true); setActiveTab('directory'); }}>
            <Zap size={18} /> Rapid Add
          </button>
        </div>
      </div>

      <div style={{ marginTop: '1.5rem', flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
        
        {activeTab === 'bulk' ? (
          <div className="data-table-container animate-fade-in" style={{ flex: 1, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', padding: '2rem' }}>
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              <div style={{ marginBottom: '1.5rem' }}>
                <h3 style={{ fontSize: '1.1rem', marginBottom: '0.5rem' }}>Bulk Paste Mode</h3>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Paste words in format: <b>Word | Meaning | Example</b> (one per line)</p>
              </div>
              <textarea 
                style={{ flex: 1, background: 'rgba(0,0,0,0.2)', border: '1px solid var(--glass-border)', borderRadius: '12px', padding: '1.5rem', color: 'white', fontFamily: 'monospace', fontSize: '0.9rem' }}
                placeholder="Eloquent | Fluent or persuasive in speaking or writing | She gave an eloquent speech."
                value={bulkText}
                onChange={e => setBulkText(e.target.value)}
              ></textarea>
              <button className="btn btn-primary" style={{ marginTop: '1.5rem', background: '#0ea5e9' }} onClick={handleBulkParse}>
                Preview & Verify Items
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', background: 'rgba(255,255,255,0.02)', borderRadius: '16px', border: '1px solid var(--glass-border)', overflow: 'hidden' }}>
              <div style={{ padding: '1.5rem', borderBottom: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h3 style={{ fontSize: '1rem' }}>Import Preview ({bulkPreview.length} items)</h3>
                {bulkPreview.length > 0 && (
                  <button className="btn btn-primary" style={{ background: '#10b981', padding: '0.4rem 1rem' }} onClick={handleBulkSubmit}>
                    Confirm & Upload All
                  </button>
                )}
              </div>
              <div style={{ flex: 1, overflowY: 'auto', padding: '1rem' }}>
                {bulkPreview.length === 0 ? (
                  <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', opacity: 0.3 }}>
                    <BookOpen size={48} />
                    <p style={{ marginTop: '1rem' }}>No items to preview</p>
                  </div>
                ) : (
                  bulkPreview.map((p, i) => (
                    <div key={i} style={{ padding: '1rem', background: 'rgba(255,255,255,0.03)', borderRadius: '8px', marginBottom: '0.75rem', borderLeft: '3px solid #0ea5e9' }}>
                      <div style={{ fontWeight: '700', color: '#0ea5e9' }}>{p.word}</div>
                      <div style={{ fontSize: '0.85rem', margin: '0.25rem 0' }}>{p.meaning}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>{p.example_sentence}</div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        ) : (
          <div className="data-table-container" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
            <div className="table-header" style={{ padding: '1.25rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <Search size={20} color="#0ea5e9" />
                <input 
                  type="text" 
                  placeholder="Fast Search Vocabulary..." 
                  style={{ background: 'none', border: 'none', fontSize: '1rem', width: '300px' }}
                  value={searchTerm}
                  onChange={e => setSearchTerm(e.target.value)}
                />
              </div>
              <div style={{ display: 'flex', gap: '1rem', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                <span>Total Items: {items.length}</span>
                <span>Active Filters: None</span>
              </div>
            </div>

            <div style={{ flex: 1, overflowY: 'auto' }}>
              <table style={{ width: '100%' }}>
                <thead style={{ position: 'sticky', top: 0, background: 'var(--glass)', zIndex: 10 }}>
                  <tr>
                    <th>Word</th>
                    <th>Category</th>
                    <th>Meaning & Context</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? (
                    <tr><td colSpan="4" style={{ textAlign: 'center', padding: '5rem' }}><Loader2 className="animate-spin" /></td></tr>
                  ) : items.filter(i => i.word.toLowerCase().includes(searchTerm.toLowerCase())).map((item) => (
                    <tr key={item.id} className="row-hover">
                      <td style={{ width: '220px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                          <Volume2 size={16} color="#0ea5e9" opacity={0.6} />
                          <span style={{ fontWeight: '700', fontSize: '1.1rem' }}>{item.word}</span>
                        </div>
                      </td>
                      <td style={{ width: '150px' }}>
                        <span className="status-badge" style={{ background: 'rgba(14, 165, 233, 0.1)', color: '#0ea5e9' }}>{item.category}</span>
                      </td>
                      <td>
                        <div style={{ marginBottom: '0.25rem', fontWeight: '500' }}>{item.meaning}</div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{item.example_sentence}</div>
                      </td>
                      <td style={{ width: '80px' }}>
                         <button className="btn btn-ghost" style={{ padding: '0.4rem', color: '#f43f5e' }} onClick={() => handleDelete(item.id)}>
                            <Trash2 size={18} />
                         </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '500px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
              <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <Zap fill="#0ea5e9" color="#0ea5e9" size={24} /> Rapid Entry Mode
              </h2>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: '600' }}>Stay Open</span>
                <input type="checkbox" checked={isRapidMode} onChange={e => setIsRapidMode(e.target.checked)} style={{ width: '40px', height: '20px' }} />
              </div>
            </div>
            
            <form onSubmit={handleCreate}>
              <div className="form-group">
                <label>The Word</label>
                <input autoFocus type="text" required placeholder="e.g. Resilient" value={form.word} onChange={e => setForm({...form, word: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Category</label>
                <select value={form.category} onChange={e => setForm({...form, category: e.target.value})}>
                  <option value="Basic">Basic</option>
                  <option value="Intermediate">Intermediate</option>
                  <option value="Advanced">Advanced</option>
                  <option value="Idiom">Idiom/Phrase</option>
                </select>
              </div>
              <div className="form-group">
                <label>Meaning</label>
                <textarea rows="2" required value={form.meaning} onChange={e => setForm({...form, meaning: e.target.value})}></textarea>
              </div>
              <div className="form-group">
                <label>Example Sentence</label>
                <textarea rows="2" value={form.example_sentence} onChange={e => setForm({...form, example_sentence: e.target.value})}></textarea>
              </div>
              <div style={{ display: 'flex', gap: '1rem', marginTop: '2rem' }}>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, background: '#0ea5e9', height: '50px' }}>
                  {isRapidMode ? 'Save & Next (Fast)' : 'Save & Close'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <style>{`
        .row-hover:hover { background: rgba(255,255,255,0.02); }
        input:focus, textarea:focus { border-color: #0ea5e9 !important; box-shadow: 0 0 0 2px rgba(14, 165, 233, 0.1); }
      `}</style>
    </div>
  );
};

export default Vocabulary;
