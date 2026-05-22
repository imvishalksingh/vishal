import React from 'react';
import { Mail, MessageSquare, Send } from 'lucide-react';

export default function Support() {
  const handleSubmit = (e) => {
    e.preventDefault();
    alert('Thank you for reaching out! We will get back to you shortly.');
  };

  return (
    <div className="animate-fade-in">
      <div className="hero" style={{ padding: '2rem 0 4rem 0' }}>
        <h1 className="text-gradient">How Can We Help You?</h1>
        <p>If you've encountered any issues or have questions regarding SR English Tak, please drop us a message using the form below or email us directly.</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '3rem' }}>
        <div className="glass-panel delay-100 animate-fade-in" style={{ opacity: 0, animationFillMode: 'forwards' }}>
          <h2 style={{ marginBottom: '1.5rem', fontSize: '1.5rem' }}>Send a Message</h2>
          <form className="support-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="name">Full Name</label>
              <input type="text" id="name" className="form-input" placeholder="Enter your full name" required />
            </div>
            <div className="form-group">
              <label htmlFor="email">Email Address</label>
              <input type="email" id="email" className="form-input" placeholder="Enter your email address" required />
            </div>
            <div className="form-group">
              <label htmlFor="subject">Subject</label>
              <input type="text" id="subject" className="form-input" placeholder="How can we help?" required />
            </div>
            <div className="form-group">
              <label htmlFor="message">Message</label>
              <textarea id="message" className="form-input" placeholder="Describe your issue in detail..." required></textarea>
            </div>
            <button type="submit" className="btn-primary" style={{ marginTop: '0.5rem' }}>
              <Send size={18} /> Send Message
            </button>
          </form>
        </div>

        <div className="delay-200 animate-fade-in" style={{ opacity: 0, animationFillMode: 'forwards', display: 'flex', flexDirection: 'column', gap: '2rem' }}>
          <div className="glass-panel">
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
              <div className="feature-icon" style={{ marginBottom: 0 }}><Mail size={24} /></div>
              <h2 style={{ fontSize: '1.5rem' }}>Email Us</h2>
            </div>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '1rem' }}>
              For direct inquiries, technical support, or partnership requests, please email our support team.
            </p>
            <a href="mailto:support@srenglishtak.com" className="text-gradient" style={{ fontWeight: 600, fontSize: '1.1rem' }}>
              support@srenglishtak.com
            </a>
          </div>

          <div className="glass-panel">
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
              <div className="feature-icon" style={{ marginBottom: 0 }}><MessageSquare size={24} /></div>
              <h2 style={{ fontSize: '1.5rem' }}>FAQ</h2>
            </div>
            <p style={{ color: 'var(--text-secondary)' }}>
              Got questions? Usually, queries regarding premium access, account deletion, or challenges can be resolved by exploring the app's internal Help Center. For specific account deletion requests, please ensure you use the email form.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
