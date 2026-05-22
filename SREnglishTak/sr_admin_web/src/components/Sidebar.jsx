import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  BookOpen, 
  GraduationCap, 
  School, 
  Lightbulb, 
  Languages, 
  Trophy,
  Settings,
  LogOut
} from 'lucide-react';

const Sidebar = ({ onLogout }) => {
  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: Users, label: 'Students', path: '/users' },
    { icon: BookOpen, label: 'Books', path: '/books' },
    { icon: GraduationCap, label: 'Grammar Hub', path: '/grammar' },
    { icon: School, label: 'CBSE Hub', path: '/cbse' },
    { icon: Trophy, label: 'Challenges', path: '/challenges' },
    { icon: Lightbulb, label: 'Daily Tips', path: '/tips' },
    { icon: Languages, label: 'Vocabulary', path: '/vocabulary' },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="stat-icon" style={{ background: 'var(--primary)', marginBottom: 0, width: 32, height: 32 }}>
          <GraduationCap size={20} color="white" />
        </div>
        <span className="logo-text">SR ADMIN</span>
      </div>

      <nav className="nav-menu">
        {menuItems.map((item) => (
          <li key={item.path} className="nav-item">
            <NavLink 
              to={item.path} 
              className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </NavLink>
          </li>
        ))}
      </nav>

      <div className="nav-menu" style={{ borderTop: '1px solid var(--glass-border)', paddingBottom: '1rem' }}>
        <NavLink to="/settings" className="nav-link">
          <Settings size={20} />
          <span>Settings</span>
        </NavLink>
        <button 
          className="nav-link" 
          style={{ background: 'none', border: 'none', width: '100%', cursor: 'pointer' }}
          onClick={onLogout}
        >
          <LogOut size={20} />
          <span>Logout</span>
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
