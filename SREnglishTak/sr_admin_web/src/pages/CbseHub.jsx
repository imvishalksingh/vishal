import React, { useState, useEffect } from 'react';
import { 
  School, Plus, Trash2, Folder, FileText, Globe, 
  Video, Search, LayoutGrid, List, MoreVertical, 
  Download, Eye, ExternalLink, ChevronRight, Filter,
  FileUp, Zap, Sparkles, FolderPlus, Layers, Loader2, Clock
} from 'lucide-react';
import { ApiService } from '../services/apiService';

const CbseHub = () => {
  const [categories, setCategories] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [materials, setMaterials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewMode, setViewMode] = useState('grid');
  const [selectedClass, setSelectedClass] = useState('Class 10'); // New Class Filter

  // Rapid/Bulk States
  const [activeView, setActiveView] = useState('browser');
  const [bulkText, setBulkText] = useState('');

  // Modals
  const [showCatModal, setShowCatModal] = useState(false);
  const [showMatModal, setShowMatModal] = useState(false);

  // Form states
  const [catForm, setCatForm] = useState({ name: '', description: '', icon_url: '', class_name: 'Class 10' });
  const [matForm, setMatForm] = useState({ title: '', material_type: 'chapter_wise', file_url: '', thumbnail_url: '' });

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      const response = await ApiService.getCbseCategories();
      setCategories(response.data);
      
      // Smartly find the first category matching the selected class
      const initialCat = response.data.find(c => (c.class_name === selectedClass) || (c.name.includes(selectedClass)));
      if (initialCat && !selectedCategory) {
        handleSelectCategory(initialCat);
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectCategory = async (category) => {
    if (!category) return;
    setSelectedCategory(category);
    setLoading(true);
    setActiveView('browser');
    try {
      const response = await ApiService.getCbseMaterials(category.id);
      setMaterials(response.data);
    } catch (error) {
      console.error('Error fetching materials:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateCategory = async (e) => {
    e.preventDefault();
    try {
      // Extract class_name so we don't send a non-existent column to the DB
      const { class_name, ...formData } = catForm;
      const finalForm = {
        ...formData,
        name: formData.name.includes(class_name) ? formData.name : `${class_name} - ${formData.name}`
      };
      await ApiService.createCbseCategory(finalForm);
      setShowCatModal(false);
      fetchCategories();
      setCatForm({ name: '', description: '', icon_url: '', class_name: selectedClass });
    } catch (error) {
      alert('Error: ' + (error.response?.data?.error || error.message));
    }
  };

  const handleCreateMaterial = async (e) => {
    e.preventDefault();
    try {
      await ApiService.createCbseMaterial(selectedCategory.id, matForm);
      setShowMatModal(false);
      handleSelectCategory(selectedCategory);
      setMatForm({ title: '', material_type: 'chapter_wise', file_url: '', thumbnail_url: '' });
    } catch (error) {
      alert('Error: ' + error.message);
    }
  };

  const handleBulkMaterialUpload = async () => {
    if (!selectedCategory) return alert('Select folder');
    const lines = bulkText.split('\n').filter(l => l.trim().length > 0);
    setLoading(true);
    let successCount = 0;
    try {
      for (const line of lines) {
        const parts = line.split('|').map(s => s.trim());
        if (parts.length >= 2) {
           const [title, url, type] = parts;
           
           // Map to allowed DB types: 'model_paper', 'pyq', 'notes', 'syllabus'
           let dbType = 'notes'; // Default
           const rawType = (type || '').toLowerCase();
           if (rawType.includes('pyq')) dbType = 'pyq';
           else if (rawType.includes('model')) dbType = 'model_paper';
           else if (rawType.includes('syllabus')) dbType = 'syllabus';
           else dbType = 'notes'; // Handles chapter_wise, notes, and video for now

           await ApiService.createCbseMaterial(selectedCategory.id, {
             title,
             file_url: url,
             material_type: dbType,
             thumbnail_url: ''
           });
           successCount++;
        }
      }
      alert(`Successfully added ${successCount} items!`);
      setBulkText('');
      handleSelectCategory(selectedCategory);
    } catch (error) {
      console.error('Bulk error details:', error);
      alert(`Added ${successCount} items, but stopped at an error: ${error.response?.data?.error || error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteMaterial = async (id) => {
    if (window.confirm('Delete material?')) {
      try {
        await ApiService.deleteCbseMaterial(id);
        handleSelectCategory(selectedCategory);
      } catch (error) {
        alert('Error');
      }
    }
  };

  // Filter categories by Class (Smart matching)
  const filteredCategories = categories.filter(cat => 
    (cat.class_name === selectedClass) || 
    (cat.name.toLowerCase().includes(selectedClass.toLowerCase()))
  );

  const filteredMaterials = materials.filter(m => 
    m.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in" style={{ height: 'calc(100vh - 100px)', display: 'flex', flexDirection: 'column' }}>
      
      {/* HEADER */}
      <div className="header-bar" style={{ marginBottom: '1.5rem' }}>
        <div className="page-title">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#10b981', marginBottom: '0.25rem' }}>
            <Sparkles size={16} />
            <span style={{ fontSize: '0.75rem', fontWeight: '700', textTransform: 'uppercase' }}>CBSE Master Management</span>
          </div>
          <h1>Board Curriculum Library</h1>
        </div>
        <div style={{ display: 'flex', gap: '1rem' }}>
           <button className="btn btn-ghost" onClick={() => setShowCatModal(true)}>
            <FolderPlus size={18} /> Create Subject
          </button>
           <button className="btn btn-primary" style={{ background: '#10b981' }} onClick={() => {
             if (!selectedCategory) return alert('Select folder first');
             setActiveView('bulk');
           }}>
            <FileUp size={18} /> Bulk Load Resources
          </button>
        </div>
      </div>

      {/* WORKSPACE */}
      <div style={{ display: 'grid', gridTemplateColumns: '300px 1fr', gap: '1.5rem', flex: 1, overflow: 'hidden' }}>
        
        {/* Left: Enhanced Folder Sidebar with Class Filter */}
        <div className="data-table-container" style={{ display: 'flex', flexDirection: 'column', background: 'rgba(15, 23, 42, 0.4)' }}>
           
           {/* CLASS SELECTOR TABS */}
           <div style={{ display: 'flex', padding: '0.5rem', background: 'rgba(0,0,0,0.2)', borderRadius: '12px', margin: '0.75rem' }}>
             {['Class 10', 'Class 12'].map(cls => (
               <button 
                 key={cls}
                 onClick={() => setSelectedClass(cls)}
                 style={{ 
                   flex: 1, 
                   padding: '0.6rem', 
                   border: 'none', 
                   borderRadius: '8px', 
                   fontSize: '0.75rem', 
                   fontWeight: '700',
                   cursor: 'pointer',
                   background: selectedClass === cls ? '#10b981' : 'transparent',
                   color: selectedClass === cls ? 'white' : 'rgba(255,255,255,0.4)',
                   transition: 'all 0.2s'
                 }}
               >
                 {cls.toUpperCase()}
               </button>
             ))}
           </div>

           <div style={{ padding: '0.5rem 1.25rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', opacity: 0.5 }}>
             <h3 style={{ fontSize: '0.7rem', fontWeight: '800' }}>FOLDERS ({filteredCategories.length})</h3>
             <Layers size={12} />
          </div>

          <div style={{ flex: 1, overflowY: 'auto', padding: '0.75rem' }}>
            {filteredCategories.length > 0 ? filteredCategories.map((cat) => (
              <div 
                key={cat.id} 
                className={`nav-link ${selectedCategory?.id === cat.id ? 'active' : ''}`}
                style={{ 
                  marginBottom: '0.4rem', 
                  cursor: 'pointer', 
                  padding: '0.8rem 1rem',
                  borderRadius: '10px',
                  background: selectedCategory?.id === cat.id ? 'rgba(16, 185, 129, 0.1)' : 'transparent',
                  color: selectedCategory?.id === cat.id ? '#10b981' : 'inherit'
                }}
                onClick={() => handleSelectCategory(cat)}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                  <Folder size={16} fill={selectedCategory?.id === cat.id ? '#10b981' : 'none'} opacity={0.7} />
                  <div style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
                    <span style={{ fontSize: '0.85rem', fontWeight: selectedCategory?.id === cat.id ? '700' : '500', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {cat.name.replace('Class 10 - ', '').replace('Class 12 - ', '')}
                    </span>
                  </div>
                </div>
              </div>
            )) : (
              <div style={{ textAlign: 'center', padding: '2rem', opacity: 0.3, fontSize: '0.8rem' }}>No folders for {selectedClass}</div>
            )}
          </div>
        </div>

        {/* Right: Powerful Browser Area */}
        <div className="data-table-container" style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
           
           <div className="table-header" style={{ padding: '1.25rem 2rem' }}>
               <div>
                  <h2 style={{ fontSize: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <Folder size={20} color="#10b981" /> {selectedCategory?.name}
                  </h2>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Found {materials.length} professional resources in this collection</p>
               </div>
               
               <div style={{ display: 'flex', gap: '1rem' }}>
                  <div className="btn-ghost" style={{ padding: '0.4rem 1rem', display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                    <Search size={18} color="var(--text-muted)" />
                    <input 
                      type="text" 
                      placeholder="Search items..." 
                      style={{ background: 'none', border: 'none', fontSize: '0.875rem', width: '180px' }}
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                    />
                  </div>
                  <button className="btn btn-primary" style={{ background: '#10b981' }} onClick={() => {
                    if (!selectedCategory) return alert('Select folder first');
                    setShowMatModal(true);
                  }}>
                    <Plus size={18} /> Add Single Resource
                  </button>
               </div>
            </div>

            <div style={{ flex: 1, overflowY: 'auto', padding: '2rem' }}>
              {activeView === 'bulk' ? (
                <div className="animate-fade-in" style={{ maxWidth: '800px', margin: '0 auto' }}>
                   <div style={{ marginBottom: '2rem' }}>
                     <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}><Zap color="#10b981" fill="#10b981" /> High-Speed Resource Uploader</h2>
                     <p style={{ opacity: 0.6, marginTop: '0.5rem' }}>Inject multiple resources into <b>{selectedCategory?.name}</b> instantly.</p>
                     <p style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', padding: '0.75rem', borderRadius: '8px', marginTop: '1rem' }}>
                       Format: <b>Title | URL | Type</b> (Types: model_paper, pyq, chapter_wise, syllabus, video)
                     </p>
                   </div>
                   <textarea 
                      style={{ width: '100%', height: '350px', background: 'rgba(0,0,0,0.2)', border: '1px solid var(--glass-border)', borderRadius: '16px', padding: '1.5rem', color: 'white', fontSize: '1rem', fontFamily: 'monospace' }}
                      placeholder="2024 Model Paper Set A | https://link.com | model_paper&#10;2023 Physics PYQ | https://link.com | pyq"
                      value={bulkText}
                      onChange={e => setBulkText(e.target.value)}
                   />
                   <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                     <button className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setActiveView('browser')}>Cancel</button>
                     <button className="btn btn-primary" style={{ flex: 2, background: '#10b981', height: '55px' }} onClick={handleBulkMaterialUpload}>Execute Bulk Upload</button>
                   </div>
                </div>
              ) : (
                <>
                  {loading ? (
                    <div style={{ textAlign: 'center', padding: '5rem' }}><Loader2 className="animate-spin" size={32} /></div>
                  ) : (
                    ['chapter_wise', 'pyq', 'model_paper', 'syllabus', 'video'].map(type => {
                      const typeMaterials = filteredMaterials.filter(m => m.material_type === type);
                      if (typeMaterials.length === 0) return null;
                      
                      return (
                        <div key={type} style={{ marginBottom: '3rem' }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1.25rem', borderBottom: '1px solid rgba(255,255,255,0.05)', paddingBottom: '0.75rem' }}>
                             <div style={{ background: 'rgba(16, 185, 129, 0.1)', padding: '0.4rem', borderRadius: '8px' }}>
                               {type === 'pyq' ? <Clock size={16} color="#10b981" /> : <FileText size={16} color="#10b981" />}
                             </div>
                             <h3 style={{ fontSize: '1rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                               {type.replace('_', ' ')} <span style={{ opacity: 0.3, fontSize: '0.8rem' }}>({typeMaterials.length})</span>
                             </h3>
                          </div>

                          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1rem' }}>
                            {typeMaterials.map((mat) => (
                              <div key={mat.id} className="stat-card" style={{ padding: '1.25rem', display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                 <div style={{ width: '45px', height: '45px', background: mat.material_type === 'video' ? 'rgba(59, 130, 246, 0.1)' : 'rgba(239, 68, 68, 0.1)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                                    {mat.material_type === 'video' ? <Video size={20} color="#3b82f6" /> : <FileText size={20} color="#ef4444" />}
                                 </div>
                                 <div style={{ flex: 1, overflow: 'hidden' }}>
                                    <div style={{ fontWeight: '600', fontSize: '0.9rem', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{mat.title}</div>
                                    <div style={{ fontSize: '0.7rem', opacity: 0.5 }}>{mat.material_type.toUpperCase()} • 2024</div>
                                 </div>
                                 <div style={{ display: 'flex', gap: '0.25rem' }}>
                                    <a href={mat.file_url} target="_blank" rel="noreferrer" className="btn btn-ghost" style={{ padding: '0.4rem' }}><Eye size={16} /></a>
                                    <button className="btn btn-ghost" style={{ padding: '0.4rem', color: '#f43f5e' }} onClick={() => handleDeleteMaterial(mat.id)}><Trash2 size={16} /></button>
                                 </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      );
                    })
                  )}
                </>
              )}
            </div>
        </div>
      </div>

      {/* MODALS */}
      {showCatModal && (
        <div className="modal-overlay" onClick={() => setShowCatModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '450px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
              <div style={{ background: '#10b981', padding: '0.6rem', borderRadius: '12px' }}>
                <FolderPlus size={20} color="white" />
              </div>
              <h2>Create New Subject</h2>
            </div>
            <form onSubmit={handleCreateCategory}>
              <div className="form-group">
                <label>Target Class</label>
                <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
                   {['Class 10', 'Class 12'].map(cls => (
                     <label key={cls} style={{ flex: 1, padding: '0.75rem', background: catForm.class_name === cls ? 'rgba(16, 185, 129, 0.1)' : 'rgba(0,0,0,0.1)', border: `1px solid ${catForm.class_name === cls ? '#10b981' : 'transparent'}`, borderRadius: '10px', textAlign: 'center', cursor: 'pointer' }}>
                        <input type="radio" name="class_name" value={cls} checked={catForm.class_name === cls} onChange={e => setCatForm({...catForm, class_name: e.target.value})} style={{ display: 'none' }} />
                        <span style={{ fontSize: '0.8rem', fontWeight: '700', color: catForm.class_name === cls ? '#10b981' : 'inherit' }}>{cls}</span>
                     </label>
                   ))}
                </div>
              </div>
              <div className="form-group">
                <label>Subject Name</label>
                <input type="text" required placeholder="e.g. Mathematics" value={catForm.name} onChange={e => setCatForm({...catForm, name: e.target.value})} />
              </div>
              <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setShowCatModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, background: '#10b981' }}>Add to Library</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showMatModal && (
        <div className="modal-overlay" onClick={() => setShowMatModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '500px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
               <div style={{ background: '#10b981', padding: '0.6rem', borderRadius: '12px' }}>
                  <FileUp size={20} color="white" />
               </div>
               <h2>Add Resource to {selectedCategory?.name}</h2>
            </div>
            <form onSubmit={handleCreateMaterial}>
              <div className="form-group">
                <label>Resource Title</label>
                <input type="text" required value={matForm.title} onChange={e => setMatForm({...matForm, title: e.target.value})} />
              </div>
              <div className="form-group">
                  <label>Resource Type</label>
                  <select value={matForm.material_type} onChange={e => setMatForm({...matForm, material_type: e.target.value})}>
                    <option value="notes">Chapter-wise Notes</option>
                    <option value="pyq">Previous Year Question (PYQ)</option>
                    <option value="model_paper">Model Paper</option>
                    <option value="syllabus">Latest Syllabus</option>
                  </select>
              </div>
              <div className="form-group">
                <label>Direct Link (URL)</label>
                <input type="url" required placeholder="https://..." value={matForm.file_url} onChange={e => setMatForm({...matForm, file_url: e.target.value})} />
              </div>
              <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setShowMatModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, background: '#10b981' }}>Register Resource</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default CbseHub;
