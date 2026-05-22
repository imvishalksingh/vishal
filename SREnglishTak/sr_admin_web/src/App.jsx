import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Students from './pages/Students';
import GrammarHub from './pages/GrammarHub';
import CbseHub from './pages/CbseHub';
import DailyTips from './pages/DailyTips';
import Vocabulary from './pages/Vocabulary';
import Books from './pages/Books';
import Login from './pages/Login';
const Challenges = () => <div className="animate-fade-in"><div className="header-bar"><h1>Challenges</h1></div><div className="data-table-container" style={{padding:'2rem'}}>Coming Soon...</div></div>;

const Layout = ({ children, onLogout }) => {
  return (
    <div className="app-container">
      <Sidebar onLogout={onLogout} />
      <main className="main-content">
        {children}
      </main>
    </div>
  );
};

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('admin_token'));

  const handleLoginSuccess = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    setIsAuthenticated(false);
  };

  if (!isAuthenticated) {
    return <Login onLoginSuccess={handleLoginSuccess} />;
  }

  return (
    <BrowserRouter>
      <Layout onLogout={handleLogout}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/users" element={<Students />} />
          <Route path="/books" element={<Books />} />
          <Route path="/grammar" element={<GrammarHub />} />
          <Route path="/cbse" element={<CbseHub />} />
          <Route path="/challenges" element={<Challenges />} />
          <Route path="/tips" element={<DailyTips />} />
          <Route path="/vocabulary" element={<Vocabulary />} />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}

export default App;
