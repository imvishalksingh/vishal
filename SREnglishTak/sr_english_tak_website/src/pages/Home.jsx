import React from 'react';
import { BookOpen, BrainCircuit, Gamepad2, Trophy, ArrowRight, Sparkles } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Home() {
  return (
    <div className="animate-fade-in">
      <section className="hero">
        <div className="hero-grid">
          <div className="hero-content">
            <div className="hero-badge animate-fade-in">
              <Sparkles size={16} />
              <span>Next Generation Learning</span>
            </div>
            <h1 className="text-gradient">
              Master English With <br/>
              <span className="text-gradient-accent">SR English Tak</span>
            </h1>
            <p className="delay-100 animate-fade-in">
              The ultimate application designed to accelerate your English fluency. Elevate your vocabulary, dominate reading comprehension, and climb the global leaderboards.
            </p>
            <div className="hero-buttons delay-200 animate-fade-in">
              <a href="#features" className="btn-primary">
                Explore Features <ArrowRight size={20} />
              </a>
              <Link to="/support" className="btn-secondary">
                Get Support
              </Link>
            </div>
            
            <div className="stats-row delay-300 animate-fade-in">
              <div className="stat-item">
                <h4 className="outfit-font">10k+</h4>
                <p>Active Users</p>
              </div>
              <div className="stat-item">
                <h4 className="outfit-font">5k+</h4>
                <p>Daily Words</p>
              </div>
              <div className="stat-item">
                <h4 className="outfit-font">4.9</h4>
                <p>App Rating</p>
              </div>
            </div>
          </div>
          
          <div className="hero-image-wrapper delay-200 animate-fade-in">
            <div className="hero-glow-blob"></div>
            <img 
              src="/hero_image.png" 
              alt="SR English Tak App UI Mockup" 
              className="hero-image"
            />
          </div>
        </div>
      </section>

      <section id="features">
        <div className="section-title">
          <h2 className="text-gradient">Why Choose SR English Tak?</h2>
          <p>We combine advanced learning methodologies with modern gamification to ensure you never lose motivation on your journey to fluency.</p>
        </div>
        
        <div className="features-grid delay-200 animate-fade-in" style={{ opacity: 0 }}>
          <div className="glass-panel feature-card">
            <div className="feature-icon-wrapper"><BookOpen size={28} /></div>
            <h3>Extensive Vocabulary</h3>
            <p>Master thousands of heavily curated words precisely selected for practical usage. Learn through contextual examples and deep meaning definitions.</p>
          </div>
          
          <div className="glass-panel feature-card">
            <div className="feature-icon-wrapper"><Gamepad2 size={28} /></div>
            <h3>Gamified Challenges</h3>
            <p>Compete in dynamic daily challenges. Climb global leaderboards and measure your reading proficiency against thousands of other learners.</p>
          </div>
          
          <div className="glass-panel feature-card">
            <div className="feature-icon-wrapper"><BrainCircuit size={28} /></div>
            <h3>Smart Analytics</h3>
            <p>Stay on track. Our intelligent dashboard visualizes your performance history and highlights critical areas needing immediate improvement.</p>
          </div>
          
          <div className="glass-panel feature-card">
            <div className="feature-icon-wrapper"><Trophy size={28} /></div>
            <h3>Exams & Retention</h3>
            <p>Take sophisticated quizzes generated seamlessly from your reading content to cement language concepts permanently into your long-term memory.</p>
          </div>
        </div>
      </section>

      {/* How it Works Section */}
      <section id="how-it-works" style={{ marginTop: '6rem' }}>
        <div className="section-title">
          <h2 className="text-gradient">How It Works</h2>
          <p>Your journey to English fluency broken down into three simple steps.</p>
        </div>
        <div className="features-grid delay-100 animate-fade-in" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))' }}>
          <div className="glass-panel feature-card" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <div style={{ fontSize: '3rem', fontWeight: 800, color: 'var(--accent-primary)', marginBottom: '1rem' }}>1</div>
            <h3>Read & Discover</h3>
            <p style={{ textAlign: 'center' }}>Engage with curated stories and news to encounter new vocabulary in real-world contexts.</p>
          </div>
          <div className="glass-panel feature-card" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <div style={{ fontSize: '3rem', fontWeight: 800, color: 'var(--accent-secondary)', marginBottom: '1rem' }}>2</div>
            <h3>Practice & Compete</h3>
            <p style={{ textAlign: 'center' }}>Take daily challenges and quizzes to test your understanding and climb the leaderboard.</p>
          </div>
          <div className="glass-panel feature-card" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <div style={{ fontSize: '3rem', fontWeight: 800, color: 'var(--accent-tertiary)', marginBottom: '1rem' }}>3</div>
            <h3>Track & Master</h3>
            <p style={{ textAlign: 'center' }}>Monitor your progress through the smart analytics dashboard and achieve total fluency.</p>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" style={{ marginTop: '8rem', marginBottom: '4rem' }}>
        <div className="section-title">
          <h2 className="text-gradient">What Our Users Say</h2>
          <p>Join thousands of learners who have transformed their English skills.</p>
        </div>
        <div className="features-grid delay-200 animate-fade-in">
          <div className="glass-panel feature-card" style={{ padding: '2rem' }}>
            <div style={{ display: 'flex', color: '#fbbf24', marginBottom: '1rem', gap: '4px' }}>
              {'★★★★★'}
            </div>
            <p style={{ fontStyle: 'italic', marginBottom: '1.5rem', color: 'var(--text-primary)' }}>"SR English Tak completely changed the way I learn. The daily challenges make vocabulary building genuinely fun and addictive!"</p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'var(--accent-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>A</div>
              <div>
                <h4 style={{ margin: 0, fontSize: '1rem' }}>Anonymous User</h4>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Pro Learner</span>
              </div>
            </div>
          </div>
          <div className="glass-panel feature-card" style={{ padding: '2rem' }}>
            <div style={{ display: 'flex', color: '#fbbf24', marginBottom: '1rem', gap: '4px' }}>
              {'★★★★★'}
            </div>
            <p style={{ fontStyle: 'italic', marginBottom: '1.5rem', color: 'var(--text-primary)' }}>"The reading comprehension quizzes are exactly what I needed to prepare for my exams. Simply the best English app out there."</p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'var(--accent-secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>R</div>
              <div>
                <h4 style={{ margin: 0, fontSize: '1rem' }}>Raj Kumar</h4>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Student</span>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Call to Action */}
      <section className="glass-panel delay-300 animate-fade-in" style={{ marginTop: '8rem', textAlign: 'center', padding: '4rem 2rem', background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(59, 130, 246, 0.1))', borderColor: 'rgba(139, 92, 246, 0.3)' }}>
        <h2 style={{ fontSize: '2.5rem', marginBottom: '1.5rem' }}>Ready to Elevate Your English?</h2>
        <p style={{ color: 'var(--text-secondary)', maxWidth: '600px', margin: '0 auto 2.5rem auto', fontSize: '1.1rem' }}>
          Download SR English Tak today and join the community of learners who are mastering English the smart way.
        </p>
        <button className="btn-primary" style={{ padding: '1rem 3rem', fontSize: '1.2rem' }}>Get Started Now</button>
      </section>

    </div>
  );
}
