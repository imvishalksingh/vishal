import React from 'react';
import { BrowserRouter, Routes, Route, Link, useLocation } from 'react-router-dom';

import Home from './pages/Home';
import PrivacyPolicy from './pages/PrivacyPolicy';
import Terms from './pages/Terms';
import Support from './pages/Support';

// A simple hook to scroll to top on route change
function ScrollToTop() {
  const { pathname } = useLocation();
  React.useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);
  return null;
}

function Layout({ children }) {
  const location = useLocation();
  
  return (
    <>
      <div className="bg-glow"></div>
      
      <header className="header">
        <div className="container header-nav">
          <Link to="/" className="logo">
            <img src="/logo.png" alt="SR English Tak Logo" style={{ height: 40, objectFit: 'contain' }} />
          </Link>
          <nav className="nav-links">
            <Link to="/" className={`nav-link ${location.pathname === '/' ? 'active' : ''}`}>Home</Link>
            <Link to="/privacy-policy" className={`nav-link ${location.pathname === '/privacy-policy' ? 'active' : ''}`}>Privacy Policy</Link>
            <Link to="/terms" className={`nav-link ${location.pathname === '/terms' ? 'active' : ''}`}>Terms of Service</Link>
            <Link to="/support" className={`nav-link ${location.pathname === '/support' ? 'active' : ''}`}>Contact Support</Link>
          </nav>
        </div>
      </header>

      <main className="main-content">
        <div className="container">
          {children}
        </div>
      </main>

      <footer className="footer">
        <div className="container footer-content">
          <div className="logo" style={{ fontSize: '1.25rem' }}>
            <img src="/logo.png" alt="SR English Tak Logo" style={{ height: 32, objectFit: 'contain' }} />
          </div>
          <div className="footer-links">
            <Link to="/privacy-policy">Privacy Policy</Link>
            <Link to="/terms">Terms</Link>
            <Link to="/support">Support</Link>
          </div>
          <div className="copyright">
            © {new Date().getFullYear()} SR English Tak. All rights reserved.
          </div>
        </div>
      </footer>
    </>
  );
}

function App() {
  return (
    <BrowserRouter>
      <ScrollToTop />
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/privacy-policy" element={<PrivacyPolicy />} />
          <Route path="/terms" element={<Terms />} />
          <Route path="/support" element={<Support />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}

export default App;
