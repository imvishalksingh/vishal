import React, { useState, useEffect } from 'react';
import { 
  Book, Plus, Trash2, Search, ExternalLink, 
  BookOpen, Star, Clock, Filter, Grid, List as ListIcon 
} from 'lucide-react';
import { ApiService } from '../services/apiService';

const Books = () => {
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [bookForm, setBookForm] = useState({
    title: '',
    author: '',
    cover_url: '',
    pdf_url: '',
    description: '',
    category: 'Classic',
    reading_time_minutes: 30
  });

  useEffect(() => {
    fetchBooks();
  }, []);

  const fetchBooks = async () => {
    try {
      const response = await ApiService.getBooks();
      setBooks(response.data);
    } catch (error) {
      console.error('Error fetching books:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await ApiService.createBook(bookForm);
      setShowModal(false);
      fetchBooks();
      setBookForm({ title: '', author: '', cover_url: '', pdf_url: '', description: '', category: 'Classic', reading_time_minutes: 30 });
    } catch (error) {
      alert('Error creating book');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this book?')) {
      try {
        await ApiService.deleteBook(id);
        fetchBooks();
      } catch (error) {
        alert('Error deleting book');
      }
    }
  };

  const filteredBooks = books.filter(b => 
    b.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    b.author?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in">
      <div className="header-bar">
        <div className="page-title">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#f59e0b', marginBottom: '0.25rem' }}>
            <Book size={16} />
            <span style={{ fontSize: '0.75rem', fontWeight: '700', textTransform: 'uppercase' }}>Digital Library</span>
          </div>
          <h1>Books Management</h1>
        </div>
        <div style={{ display: 'flex', gap: '1rem' }}>
           <div className="btn-ghost" style={{ padding: '0.4rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Search size={18} color="var(--text-muted)" />
            <input 
              type="text" 
              placeholder="Search library..." 
              style={{ background: 'none', border: 'none', padding: 0, fontSize: '0.875rem', width: '200px' }}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn btn-primary" style={{ background: '#f59e0b' }} onClick={() => setShowModal(true)}>
            <Plus size={18} /> Add New Book
          </button>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1.5rem', marginTop: '1.5rem' }}>
        {loading ? (
          <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: '4rem' }}><BookOpen className="animate-spin" /></div>
        ) : filteredBooks.map((book) => (
          <div key={book.id} className="data-table-container" style={{ padding: '0', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
            <div style={{ display: 'flex', gap: '1rem', padding: '1.25rem' }}>
              <div style={{ width: '80px', height: '110px', borderRadius: '8px', overflow: 'hidden', background: 'var(--glass)', flexShrink: 0 }}>
                {book.cover_url ? (
                  <img src={book.cover_url} alt={book.title} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : (
                  <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <BookOpen size={24} opacity={0.2} />
                  </div>
                )}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <span className="status-badge" style={{ fontSize: '0.6rem', color: '#f59e0b', background: 'rgba(245, 158, 11, 0.1)' }}>{book.category}</span>
                  <button className="btn btn-ghost" style={{ padding: '0.25rem', color: '#f43f5e' }} onClick={() => handleDelete(book.id)}>
                    <Trash2 size={16} />
                  </button>
                </div>
                <h3 style={{ fontSize: '1rem', fontWeight: '700', marginTop: '0.5rem', marginBottom: '0.25rem' }}>{book.title}</h3>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>by {book.author || 'Unknown'}</p>
              </div>
            </div>
            
            <div style={{ padding: '1rem 1.25rem', background: 'rgba(255,255,255,0.02)', borderTop: '1px solid var(--glass-border)', marginTop: 'auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
               <div style={{ display: 'flex', gap: '1rem' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.25rem', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                    <Clock size={14} /> {book.reading_time_minutes}m
                  </div>
               </div>
               <a href={book.pdf_url} target="_blank" rel="noreferrer" className="btn btn-ghost" style={{ fontSize: '0.75rem', padding: '0.4rem 0.8rem', color: '#f59e0b' }}>
                 Read Online <ExternalLink size={12} />
               </a>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '600px' }}>
            <h2>Register New Book</h2>
            <form onSubmit={handleCreate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.25rem', marginTop: '1.5rem' }}>
              <div className="form-group" style={{ gridColumn: '1 / -1' }}>
                <label>Book Title</label>
                <input type="text" required value={bookForm.title} onChange={e => setBookForm({...bookForm, title: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Author</label>
                <input type="text" required value={bookForm.author} onChange={e => setBookForm({...bookForm, author: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Category</label>
                <select value={bookForm.category} onChange={e => setBookForm({...bookForm, category: e.target.value})}>
                  <option value="Classic">Classic Literature</option>
                  <option value="Scientific">Scientific Research</option>
                  <option value="Fiction">Fiction</option>
                  <option value="Non-Fiction">Non-Fiction</option>
                  <option value="Grammar">Grammar Guide</option>
                </select>
              </div>
              <div className="form-group">
                <label>Cover Image URL</label>
                <input type="url" value={bookForm.cover_url} onChange={e => setBookForm({...bookForm, cover_url: e.target.value})} />
              </div>
              <div className="form-group">
                <label>PDF/Reader URL</label>
                <input type="url" required value={bookForm.pdf_url} onChange={e => setBookForm({...bookForm, pdf_url: e.target.value})} />
              </div>
              <div className="form-group" style={{ gridColumn: '1 / -1' }}>
                <label>Description</label>
                <textarea rows="3" value={bookForm.description} onChange={e => setBookForm({...bookForm, description: e.target.value})}></textarea>
              </div>
              <div style={{ gridColumn: '1 / -1', display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, background: '#f59e0b' }}>Add to Library</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Books;
