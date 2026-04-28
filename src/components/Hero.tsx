import React from 'react';
import { ArrowDown, Github, Linkedin, Mail, MessageCircle, Code } from 'lucide-react';

const Hero = () => {
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="home" className="min-h-screen flex items-center justify-center relative overflow-hidden pt-24 pb-16">
      {/* Background Gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-900/20 via-purple-900/20 to-teal-900/20"></div>
      
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-purple-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/4 w-32 h-32 bg-teal-500/5 rounded-full blur-2xl animate-bounce delay-500"></div>
        <div className="absolute bottom-1/4 right-1/4 w-24 h-24 bg-pink-500/5 rounded-full blur-2xl animate-pulse delay-700"></div>
      </div>

      {/* Floating Particles */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-10 w-2 h-2 bg-blue-400/30 rounded-full animate-ping delay-1000"></div>
        <div className="absolute top-40 right-20 w-1 h-1 bg-purple-400/40 rounded-full animate-ping delay-2000"></div>
        <div className="absolute bottom-32 left-20 w-1.5 h-1.5 bg-teal-400/30 rounded-full animate-ping delay-3000"></div>
        <div className="absolute bottom-20 right-32 w-1 h-1 bg-pink-400/40 rounded-full animate-ping delay-1500"></div>
        <div className="absolute top-1/3 left-1/3 w-1 h-1 bg-yellow-400/30 rounded-full animate-ping delay-2500"></div>
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          
          {/* Left Side - Content */}
          <div className="text-center lg:text-left animate-fadeIn">
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold mb-6">
              <span className="bg-gradient-to-r from-blue-400 via-purple-500 to-teal-400 bg-clip-text text-transparent">
                Vishal Kumar
              </span>
            </h1>
            <h2 className="text-xl sm:text-2xl lg:text-3xl text-gray-300 mb-8 font-light">
              Full Stack Web & Mobile App Developer
            </h2>
            <div className="space-y-4 text-lg text-gray-400 mb-12 leading-relaxed">
              <p>
                I help startups and businesses turn ideas into high-performance web and mobile applications.
              </p>
              <p>
                3+ years of experience in React, Node.js, Flutter, and Android development.
              </p>
            </div>
            
            {/* Social Links */}
            <div className="flex justify-center lg:justify-start space-x-6">
              <a
                href="https://github.com/imvishalksingh"
                target="_blank"
                rel="noopener noreferrer"
                className="p-3 rounded-full bg-gray-800 hover:bg-blue-600 transition-colors duration-300 hover:scale-110 transform"
                aria-label="GitHub"
              >
                <Github size={24} />
              </a>
              <a
                href="https://www.linkedin.com/in/iamvishalksingh/"
                target="_blank"
                rel="noopener noreferrer"
                className="p-3 rounded-full bg-gray-800 hover:bg-blue-600 transition-colors duration-300 hover:scale-110 transform"
                aria-label="LinkedIn"
              >
                <Linkedin size={24} />
              </a>
              <a
                href="https://leetcode.com/u/iamvishal/"
                target="_blank"
                rel="noopener noreferrer"
                className="p-3 rounded-full bg-gray-800 hover:bg-orange-600 transition-colors duration-300 hover:scale-110 transform"
                aria-label="LeetCode"
              >
                <Code size={24} />
              </a>
              <a
                href="mailto:vishal.techengineer@gmail.com"
                className="p-3 rounded-full bg-gray-800 hover:bg-blue-600 transition-colors duration-300 hover:scale-110 transform"
                aria-label="Email"
              >
                <Mail size={24} />
              </a>
              <a
                href="https://wa.me/917408468364"
                className="p-3 rounded-full bg-gray-800 hover:bg-green-600 transition-colors duration-300 hover:scale-110 transform"
                aria-label="WhatsApp"
              >
                <MessageCircle size={24} />
              </a>
            </div>
          </div>

          {/* Right Side - Profile Photo */}
          <div className="flex justify-center lg:justify-end">
            <div className="relative group">
              {/* Animated Ring Background */}
              <div className="absolute inset-0 rounded-full bg-gradient-to-r from-blue-400 via-purple-500 to-teal-400 animate-spin-slow opacity-75 blur-sm scale-110"></div>
              <div className="absolute inset-0 rounded-full bg-gradient-to-r from-teal-400 via-blue-500 to-purple-400 animate-spin-reverse opacity-50 blur-md scale-125"></div>
              
              {/* Outer Glow Ring */}
              <div className="absolute inset-0 rounded-full bg-gradient-to-r from-blue-400 to-purple-500 opacity-20 animate-pulse scale-150 blur-xl"></div>
              
              {/* Profile Image Container */}
              <div className="relative w-72 h-72 sm:w-80 sm:h-80 lg:w-96 lg:h-96 rounded-full overflow-hidden border-4 border-white/20 backdrop-blur-sm group-hover:scale-105 transition-transform duration-500">
                <img
                  src="/IMG_20240403_002946~2.jpg"
                  alt="Vishal Kumar - Web & Mobile Developer"
                  className="w-full h-full object-cover object-top scale-110"
                />
                
                {/* Overlay Gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-gray-900/20 via-transparent to-transparent"></div>
                
                {/* Floating Elements around Photo */}
                <div className="absolute -top-4 -right-4 w-8 h-8 bg-blue-500/20 rounded-full animate-bounce delay-300"></div>
                <div className="absolute -bottom-4 -left-4 w-6 h-6 bg-purple-500/20 rounded-full animate-bounce delay-700"></div>
                <div className="absolute top-1/4 -left-6 w-4 h-4 bg-teal-500/20 rounded-full animate-pulse delay-1000"></div>
                <div className="absolute bottom-1/4 -right-6 w-5 h-5 bg-pink-500/20 rounded-full animate-pulse delay-500"></div>
              </div>
              
              {/* Status Indicator */}
              <div className="absolute bottom-8 right-8 w-8 h-8 bg-green-500 rounded-full border-4 border-white animate-pulse">
                <div className="absolute inset-0 bg-green-500 rounded-full animate-ping opacity-75"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll Indicator */}
      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <button
          onClick={() => scrollToSection('about')}
          className="p-2 rounded-full bg-gray-800/50 hover:bg-gray-700 transition-colors duration-300"
        >
          <ArrowDown size={24} />
        </button>
      </div>
    </section>
  );
};

export default Hero;