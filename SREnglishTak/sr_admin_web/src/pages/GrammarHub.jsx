import React, { useState, useEffect } from 'react';
import { 
  BookOpen, Plus, Trash2, ChevronRight, LayoutList, 
  FileText, Video, FileQuestion, Edit3, Save, X, 
  Layers, Search, Loader2, Zap, FileUp, Sparkles,
  Maximize2, Minimize2, Eye, Code, Type, Bold, Italic, List
} from 'lucide-react';
import { ApiService } from '../services/apiService';

const GrammarHub = () => {
  const [units, setUnits] = useState([]);
  const [selectedUnit, setSelectedUnit] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingLesson, setEditingLesson] = useState(null); // Full screen editor state
  const [searchTerm, setSearchTerm] = useState('');
  
  // View states
  const [activeView, setActiveView] = useState('lessons'); // 'lessons' or 'bulk'
  const [bulkText, setBulkText] = useState('');
  const [previewMode, setPreviewMode] = useState(false);

  // Modals
  const [showUnitModal, setShowUnitModal] = useState(false);
  const [unitForm, setUnitForm] = useState({ title: '', description: '', unit_order: 1 });

  useEffect(() => {
    fetchUnits();
  }, []);

  const fetchUnits = async () => {
    try {
      const response = await ApiService.getGrammarUnits();
      const sortedUnits = response.data.sort((a, b) => a.unit_order - b.unit_order);
      setUnits(sortedUnits);
      if (sortedUnits.length > 0 && !selectedUnit) {
        handleSelectUnit(sortedUnits[0]);
      }
    } catch (error) {
      console.error('Error fetching units:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectUnit = async (unit) => {
    if (!unit) return;
    setSelectedUnit(unit);
    setLoading(true);
    setEditingLesson(null);
    setActiveView('lessons');
    try {
      const response = await ApiService.getGrammarLessons(unit.id);
      const sortedLessons = response.data.sort((a, b) => a.lesson_order - b.lesson_order);
      setLessons(sortedLessons);
    } catch (error) {
      console.error('Error fetching lessons:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateUnit = async (e) => {
    e.preventDefault();
    try {
      await ApiService.createGrammarUnit(unitForm);
      setShowUnitModal(false);
      fetchUnits();
      setUnitForm({ title: '', description: '', unit_order: units.length + 1 });
    } catch (error) {
      alert('Error: ' + error.message);
    }
  };

  const handleSaveLesson = async () => {
    try {
      if (editingLesson.isNew) {
        await ApiService.createGrammarLesson(selectedUnit.id, editingLesson);
      } else {
        // Need to implement update API in backend or just recreate
        alert('Update is being processed... (Simulated)');
        await ApiService.deleteGrammarLesson(editingLesson.id);
        await ApiService.createGrammarLesson(selectedUnit.id, editingLesson);
      }
      setEditingLesson(null);
      handleSelectUnit(selectedUnit);
    } catch (error) {
      alert('Error saving lesson');
    }
  };

  const handleBulkCreate = async () => {
    if (!selectedUnit) return alert('Select a unit');
    const titles = bulkText.split('\n').filter(t => t.trim().length > 0);
    setLoading(true);
    try {
      const lessonsData = titles.map((title, i) => ({
        title: title.trim(),
        content_type: 'text',
        content_data: '<h2>' + title.trim() + '</h2><p>Start typing your content here...</p>',
        lesson_order: lessons.length + i + 1
      }));
      await ApiService.bulkCreateGrammarLessons(selectedUnit.id, lessonsData);
      setBulkText('');
      handleSelectUnit(selectedUnit);
    } catch (error) {
      alert('Bulk error');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteLesson = async (id) => {
    if (window.confirm('Delete lesson?')) {
      try {
        await ApiService.deleteGrammarLesson(id);
        handleSelectUnit(selectedUnit);
      } catch (error) {
        alert('Error');
      }
    }
  };

  const renderPreview = (content) => {
    return (
      <div 
        className="prose-preview" 
        dangerouslySetInnerHTML={{ __html: content || '<p style="opacity:0.5 italic">No content yet...</p>' }} 
      />
    );
  };

  return (
    <div className="animate-fade-in" style={{ height: 'calc(100vh - 100px)', display: 'flex', flexDirection: 'column' }}>
      
      {/* HEADER */}
      <div className="header-bar" style={{ marginBottom: '1rem' }}>
        <div className="page-title">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--primary)', marginBottom: '0.25rem' }}>
            <Sparkles size={16} />
            <span style={{ fontSize: '0.7rem', fontWeight: '800', textTransform: 'uppercase' }}>Advanced Curriculum Lab</span>
          </div>
          <h1 style={{ fontSize: '1.5rem' }}>Grammar Master Console</h1>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button className="btn btn-ghost" onClick={() => setShowUnitModal(true)}><Plus size={18} /> New Unit</button>
          <button className="btn btn-primary" onClick={() => {
            if (!selectedUnit) return alert('Select a unit first');
            setActiveView('bulk');
          }}><FileUp size={18} /> Bulk Add Lessons</button>
        </div>
      </div>

      {/* MAIN WORKSPACE */}
      <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr', gap: '1.25rem', flex: 1, overflow: 'hidden' }}>
        
        {/* Unit Selector */}
        <div className="data-table-container" style={{ display: 'flex', flexDirection: 'column', background: 'rgba(0,0,0,0.1)' }}>
          <div style={{ padding: '1rem', borderBottom: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: '700', opacity: 0.5 }}>STRUCTURE</span>
            <Layers size={14} opacity={0.5} />
          </div>
          <div style={{ flex: 1, overflowY: 'auto', padding: '0.75rem' }}>
            {units.map((unit) => (
              <div 
                key={unit.id} 
                className={`nav-link ${selectedUnit?.id === unit.id ? 'active' : ''}`}
                style={{ padding: '0.75rem 1rem', marginBottom: '0.4rem', borderRadius: '10px', fontSize: '0.875rem' }}
                onClick={() => handleSelectUnit(unit)}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                   <div style={{ width: '24px', height: '24px', background: selectedUnit?.id === unit.id ? 'var(--primary)' : 'rgba(255,255,255,0.05)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.7rem', fontWeight: '700' }}>
                     {unit.unit_order}
                   </div>
                   <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis' }}>{unit.title}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Content Browser */}
        <div className="data-table-container" style={{ display: 'flex', flexDirection: 'column' }}>
          <div className="table-header" style={{ padding: '1rem 1.5rem' }}>
             <div>
               <h2 style={{ fontSize: '1.25rem' }}>{selectedUnit?.title || 'No Unit Selected'}</h2>
               <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{lessons.length} lessons in this curriculum unit</p>
             </div>
             <div style={{ display: 'flex', gap: '1rem' }}>
                <div className="btn-ghost" style={{ padding: '0.4rem 1rem', display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                  <Search size={16} color="var(--text-muted)" />
                  <input type="text" placeholder="Search lessons..." style={{ background: 'none', border: 'none', fontSize: '0.875rem', width: '200px' }} value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
                </div>
                <button className="btn btn-primary" style={{ background: 'var(--primary)' }} onClick={() => {
                   if (!selectedUnit) return alert('Select unit first');
                   setEditingLesson({ title: '', content_type: 'text', content_data: '<h2>New Lesson</h2><p>Write your lesson content here...</p>', lesson_order: lessons.length + 1, isNew: true });
                }}>
                  <Plus size={18} /> New Lesson
                </button>
             </div>
          </div>

          <div style={{ flex: 1, overflowY: 'auto' }}>
            {activeView === 'bulk' ? (
              <div className="animate-fade-in" style={{ padding: '3rem', maxWidth: '800px', margin: '0 auto' }}>
                 <div style={{ marginBottom: '2rem' }}>
                   <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}><Zap fill="var(--primary)" color="var(--primary)" /> Bulk Curriculum Injector</h2>
                   <p style={{ color: 'var(--text-muted)', marginTop: '0.5rem' }}>List all your lesson titles below. One title per line. We'll generate the entire unit structure for you instantly.</p>
                 </div>
                 <textarea 
                    style={{ width: '100%', height: '300px', background: 'rgba(0,0,0,0.2)', border: '1px solid var(--glass-border)', borderRadius: '16px', padding: '1.5rem', color: 'white', fontSize: '1rem', lineHeight: '1.6' }}
                    placeholder="Nouns: The Basics&#10;Types of Pronouns&#10;Verb Tenses Mastery&#10;..."
                    value={bulkText}
                    onChange={e => setBulkText(e.target.value)}
                 />
                 <div style={{ display: 'flex', gap: '1rem', marginTop: '2rem' }}>
                    <button className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setActiveView('lessons')}>Back to Browser</button>
                    <button className="btn btn-primary" style={{ flex: 2, height: '50px' }} onClick={handleBulkCreate}>Build Curriculum Unit</button>
                 </div>
              </div>
            ) : (
              <table style={{ width: '100%' }}>
                <thead style={{ position: 'sticky', top: 0, background: 'var(--glass)', zIndex: 10 }}>
                  <tr>
                    <th style={{ width: '80px' }}>Order</th>
                    <th>Lesson Title</th>
                    <th>Status</th>
                    <th>Type</th>
                    <th style={{ width: '150px' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? (
                    <tr><td colSpan="5" style={{ textAlign: 'center', padding: '5rem' }}><Loader2 className="animate-spin" size={32} /></td></tr>
                  ) : lessons.filter(l => l.title.toLowerCase().includes(searchTerm.toLowerCase())).map((lesson) => (
                    <tr key={lesson.id} className="row-hover">
                      <td><div style={{ opacity: 0.5 }}>#{lesson.lesson_order}</div></td>
                      <td>
                        <div style={{ fontWeight: '600', fontSize: '1rem' }}>{lesson.title}</div>
                      </td>
                      <td><span className="status-badge status-active">Published</span></td>
                      <td>
                         <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.75rem', opacity: 0.8 }}>
                           {lesson.content_type === 'video' ? <Video size={14} /> : <FileText size={14} />}
                           {lesson.content_type.toUpperCase()}
                         </div>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                          <button className="btn btn-ghost" style={{ padding: '0.5rem' }} onClick={() => setEditingLesson(lesson)}>
                            <Edit3 size={18} />
                          </button>
                          <button className="btn btn-ghost" style={{ padding: '0.5rem', color: '#f43f5e' }} onClick={() => handleDeleteLesson(lesson.id)}>
                            <Trash2 size={18} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      {/* FULL SCREEN POWER EDITOR */}
      {editingLesson && (
        <div className="fullscreen-editor-overlay animate-fade-in">
           <div className="editor-container">
             {/* Editor Toolbar */}
             <div className="editor-header">
               <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <div style={{ background: 'var(--primary)', padding: '0.5rem', borderRadius: '10px' }}>
                    <Edit3 size={20} color="white" />
                  </div>
                  <div>
                    <h2 style={{ fontSize: '1rem', fontWeight: '700' }}>Editing Lesson: {editingLesson.title || 'Untitled'}</h2>
                    <p style={{ fontSize: '0.7rem', color: 'rgba(255,255,255,0.5)' }}>Editing in {selectedUnit?.title}</p>
                  </div>
               </div>
               
               <div style={{ display: 'flex', gap: '1rem' }}>
                  <button className="btn btn-ghost" onClick={() => setPreviewMode(!previewMode)}>
                    {previewMode ? <Code size={18} /> : <Eye size={18} />}
                    {previewMode ? 'Switch to Editor' : 'Live Preview'}
                  </button>
                  <div style={{ width: '1px', background: 'rgba(255,255,255,0.1)', margin: '0 0.5rem' }} />
                  <button className="btn btn-ghost" onClick={() => setEditingLesson(null)}>Discard</button>
                  <button className="btn btn-primary" style={{ background: '#10b981' }} onClick={handleSaveLesson}>
                    <Save size={18} /> Save Curriculum
                  </button>
               </div>
             </div>

             {/* Editor Content Area */}
             <div className="editor-workspace">
                {/* Left Side: Input Form & Editor */}
                <div className={`editor-main ${previewMode ? 'split' : 'full'}`}>
                   <div style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1.5rem', height: '100%' }}>
                      <div className="form-group">
                        <label>Lesson Title</label>
                        <input 
                          type="text" 
                          style={{ fontSize: '1.5rem', fontWeight: '700', padding: '1rem', background: 'rgba(0,0,0,0.2)' }}
                          value={editingLesson.title} 
                          onChange={e => setEditingLesson({...editingLesson, title: e.target.value})} 
                        />
                      </div>
                      
                      <div style={{ display: 'flex', gap: '1rem' }}>
                        <div className="form-group" style={{ flex: 1 }}>
                          <label>Content Type</label>
                          <select value={editingLesson.content_type} onChange={e => setEditingLesson({...editingLesson, content_type: e.target.value})}>
                            <option value="text">Rich Text / HTML</option>
                            <option value="video">Video URL (YouTube/Vimeo)</option>
                            <option value="pdf">PDF Document Link</option>
                          </select>
                        </div>
                        <div className="form-group" style={{ flex: 1 }}>
                          <label>Order in Unit</label>
                          <input type="number" value={editingLesson.lesson_order} onChange={e => setEditingLesson({...editingLesson, lesson_order: parseInt(e.target.value)})} />
                        </div>
                      </div>

                      <div className="form-group" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                         <label style={{ display: 'flex', justifyContent: 'space-between' }}>
                           Lesson Content (HTML/Markdown)
                           <span style={{ fontSize: '0.7rem', opacity: 0.5 }}>Power Editor v1.0</span>
                         </label>
                         
                         {/* Simple Formatting Bar */}
                         <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '0.5rem', padding: '0.5rem', background: 'rgba(0,0,0,0.2)', borderRadius: '8px' }}>
                           <button className="btn-icon" onClick={() => setEditingLesson({...editingLesson, content_data: editingLesson.content_data + '<b></b>'})}><Bold size={14}/></button>
                           <button className="btn-icon" onClick={() => setEditingLesson({...editingLesson, content_data: editingLesson.content_data + '<i></i>'})}><Italic size={14}/></button>
                           <button className="btn-icon" onClick={() => setEditingLesson({...editingLesson, content_data: editingLesson.content_data + '<h2></h2>'})}><Type size={14}/></button>
                           <button className="btn-icon" onClick={() => setEditingLesson({...editingLesson, content_data: editingLesson.content_data + '<ul>\n  <li></li>\n</ul>'})}><List size={14}/></button>
                         </div>

                         <textarea 
                            style={{ flex: 1, background: 'rgba(0,0,0,0.3)', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '12px', padding: '1.5rem', color: 'white', fontFamily: 'monospace', fontSize: '1rem', lineHeight: '1.6', resize: 'none' }}
                            placeholder="Type your lesson content here..."
                            value={editingLesson.content_data}
                            onChange={e => setEditingLesson({...editingLesson, content_data: e.target.value})}
                         />
                      </div>
                   </div>
                </div>

                {/* Right Side: Preview (Optional) */}
                {(previewMode || window.innerWidth > 1400) && (
                  <div className="editor-preview">
                    <div style={{ padding: '1rem', borderBottom: '1px solid var(--glass-border)', background: 'rgba(255,255,255,0.02)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <Eye size={14} /> <span style={{ fontSize: '0.8rem', fontWeight: '600' }}>Live Student View</span>
                    </div>
                    <div style={{ padding: '2rem', overflowY: 'auto', flex: 1 }}>
                       <h1 style={{ marginBottom: '1.5rem' }}>{editingLesson.title}</h1>
                       {editingLesson.content_type === 'video' && (
                         <div style={{ width: '100%', aspectRatio: '16/9', background: '#000', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '2rem' }}>
                           <Video size={48} opacity={0.3} />
                         </div>
                       )}
                       <div className="prose-preview">
                          {renderPreview(editingLesson.content_data)}
                       </div>
                    </div>
                  </div>
                )}
             </div>
           </div>
        </div>
      )}

      {/* Unit Modal */}
      {showUnitModal && (
        <div className="modal-overlay" onClick={() => setShowUnitModal(false)}>
          <div className="modal-content animate-fade-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '450px' }}>
             <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
                <div style={{ background: 'var(--primary)', padding: '0.6rem', borderRadius: '12px' }}>
                  <Layers size={20} color="white" />
                </div>
                <h2>Create Grammar Unit</h2>
             </div>
             <form onSubmit={handleCreateUnit}>
               <div className="form-group">
                 <label>Unit Title</label>
                 <input autoFocus type="text" required placeholder="e.g. Master Tenses" value={unitForm.title} onChange={e => setUnitForm({...unitForm, title: e.target.value})} />
               </div>
               <div className="form-group">
                 <label>Order</label>
                 <input type="number" required value={unitForm.unit_order} onChange={e => setUnitForm({...unitForm, unit_order: parseInt(e.target.value)})} />
               </div>
               <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                 <button type="button" className="btn btn-ghost" style={{ flex: 1 }} onClick={() => setShowUnitModal(false)}>Cancel</button>
                 <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>Initialize Unit</button>
               </div>
             </form>
          </div>
        </div>
      )}

      <style>{`
        .fullscreen-editor-overlay {
          position: fixed;
          top: 0; left: 0; right: 0; bottom: 0;
          background: #0f172a;
          z-index: 1000;
          display: flex;
          flex-direction: column;
        }
        .editor-container {
          height: 100vh;
          display: flex;
          flex-direction: column;
        }
        .editor-header {
          height: 70px;
          background: rgba(30, 41, 59, 0.8);
          border-bottom: 1px solid rgba(255,255,255,0.1);
          padding: 0 2rem;
          display: flex;
          align-items: center;
          justify-content: space-between;
          backdrop-filter: blur(10px);
        }
        .editor-workspace {
          flex: 1;
          display: flex;
          overflow: hidden;
        }
        .editor-main {
          flex: 1;
          overflow-y: auto;
          transition: all 0.3s ease;
        }
        .editor-preview {
          width: 50%;
          background: white;
          color: #334155;
          display: flex;
          flex-direction: column;
          border-left: 1px solid rgba(0,0,0,0.1);
        }
        .prose-preview h1, .prose-preview h2 { color: #1e293b; margin-top: 1.5rem; margin-bottom: 1rem; }
        .prose-preview p { color: #475569; line-height: 1.8; margin-bottom: 1.25rem; }
        .prose-preview b { font-weight: 700; }
        .btn-icon {
          background: rgba(255,255,255,0.05);
          border: 1px solid rgba(255,255,255,0.1);
          color: white;
          padding: 0.4rem;
          border-radius: 6px;
          cursor: pointer;
        }
        .btn-icon:hover { background: rgba(255,255,255,0.1); }
        .row-hover:hover { background: rgba(255,255,255,0.03); }
      `}</style>
    </div>
  );
};

export default GrammarHub;
