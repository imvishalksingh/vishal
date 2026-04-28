import React, { useState } from 'react';
import { Mail, Phone, MapPin, Github, Linkedin, MessageCircle, Send, Code } from 'lucide-react';

const Contact = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission here
    console.log('Form submitted:', formData);
    // Reset form
    setFormData({ name: '', email: '', message: '' });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const contactInfo = [
    {
      icon: <Mail className="w-6 h-6" />,
      title: "Email",
      info: "vishal.techengineer@gmail.com",
      href: "mailto:vishal.techengineer@gmail.com"
    },
    {
      icon: <MessageCircle className="w-6 h-6" />,
      title: "WhatsApp",
      info: "+91 7408468364",
      href: "https://wa.me/917408468364"
    },
    {
      icon: <MapPin className="w-6 h-6" />,
      title: "Location",
      info: "India",
      href: "#"
    }
  ];

  const socialLinks = [
    {
      icon: <Github className="w-6 h-6" />,
      href: "https://github.com/imvishalksingh",
      label: "GitHub"
    },
    {
      icon: <Linkedin className="w-6 h-6" />,
      href: "https://www.linkedin.com/in/iamvishalksingh/",
      label: "LinkedIn"
    },
    {
      icon: <Code className="w-6 h-6" />,
      href: "https://leetcode.com/u/iamvishal/",
      label: "LeetCode"
    },
    {
      icon: <MessageCircle className="w-6 h-6" />,
      href: "https://wa.me/917408468364",
      label: "WhatsApp"
    }
  ];

  return (
    <section id="contact" className="py-20 bg-gray-800/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl sm:text-5xl font-bold mb-6">
            <span className="bg-gradient-to-r from-green-400 to-blue-500 bg-clip-text text-transparent">
              Get In Touch
            </span>
          </h2>
          <div className="w-24 h-1 bg-gradient-to-r from-green-400 to-blue-500 mx-auto mb-8"></div>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Ready to turn your idea into a high-performance web or mobile application? Let's discuss your project!
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          {/* Contact Info */}
          <div className="space-y-8">
            <div>
              <h3 className="text-2xl font-semibold mb-6 text-green-400">Let's Build Something Amazing</h3>
              <p className="text-gray-300 mb-8 leading-relaxed">
                I'm available for freelance projects and would love to help bring your digital 
                vision to life. Whether it's a mobile app, a full-stack platform, or a corporate website, 
                I'm here to deliver quality results.
              </p>
            </div>

            <div className="space-y-4">
              {contactInfo.map((item, index) => (
                <a
                  key={index}
                  href={item.href}
                  className="flex items-center gap-4 p-4 bg-gray-900 rounded-lg border border-gray-700 hover:border-green-500/50 transition-all duration-300 hover:scale-105 transform"
                >
                  <div className="text-green-400">{item.icon}</div>
                  <div>
                    <h4 className="font-medium text-white">{item.title}</h4>
                    <p className="text-gray-400">{item.info}</p>
                  </div>
                </a>
              ))}
            </div>

            <div className="pt-8">
              <h4 className="text-lg font-semibold mb-4 text-white">Connect With Me</h4>
              <div className="flex gap-4">
                {socialLinks.map((social, index) => (
                  <a
                    key={index}
                    href={social.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="p-3 bg-gray-900 rounded-lg border border-gray-700 hover:border-green-500/50 hover:bg-green-600 transition-all duration-300 hover:scale-110 transform"
                    aria-label={social.label}
                  >
                    {social.icon}
                  </a>
                ))}
              </div>
            </div>

            {/* Quick Services List */}
            <div className="pt-8">
              <h4 className="text-lg font-semibold mb-4 text-blue-400">Services I Offer</h4>
              <div className="space-y-2">
                {[
                  "Cross-platform Mobile Development (Flutter)",
                  "Full Stack Web Development (React + Node.js)",
                  "Native Android Apps (Kotlin/Compose)",
                  "REST API Design & Integration",
                  "Performance Optimization & Deployment",
                  "Bug Fixing & Maintenance"
                ].map((service, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <span className="text-green-400">•</span>
                    <span className="text-gray-300 text-sm">{service}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <div className="bg-gray-900 p-8 rounded-lg border border-gray-700">
            <h3 className="text-2xl font-semibold mb-6 text-green-400">Start Your Project</h3>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-300 mb-2">
                  Your Name
                </label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-200 text-white"
                  placeholder="Your Name"
                />
              </div>
              
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-300 mb-2">
                  Your Email
                </label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-200 text-white"
                  placeholder="your@email.com"
                />
              </div>
              
              <div>
                <label htmlFor="message" className="block text-sm font-medium text-gray-300 mb-2">
                  Project Details
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  required
                  rows={5}
                  className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-200 text-white resize-none"
                  placeholder="Tell me about your project idea (Web or Mobile), requirements, timeline, and budget..."
                />
              </div>
              
              <button
                type="submit"
                className="w-full bg-gradient-to-r from-green-500 to-blue-600 hover:from-green-600 hover:to-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition-all duration-300 hover:scale-105 transform flex items-center justify-center gap-2"
              >
                <Send size={20} />
                Send Project Details
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Contact;