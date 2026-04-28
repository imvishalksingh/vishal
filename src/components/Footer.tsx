import React from 'react';
import { Heart, Globe } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="bg-gray-900 border-t border-gray-800 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <div className="flex items-center justify-center gap-2 mb-4">
            <span className="text-gray-400">Built with</span>
            <Heart className="w-5 h-5 text-red-500 animate-pulse" />
            <span className="text-gray-400">using</span>
            <Globe className="w-5 h-5 text-blue-400" />
            <span className="text-gray-400">React & Node.js</span>
          </div>
          <p className="text-gray-400 mb-4">
            © 2024 Vishal Kumar. All rights reserved.
          </p>
          <div className="flex justify-center space-x-6 text-sm text-gray-500">
            <a href="mailto:vishal.techengineer@gmail.com" className="hover:text-gray-300 transition-colors duration-200">
              Email Me
            </a>
            <a href="https://wa.me/917408468364" className="hover:text-gray-300 transition-colors duration-200">
              WhatsApp
            </a>
            <a href="https://github.com/imvishalksingh" target="_blank" rel="noopener noreferrer" className="hover:text-gray-300 transition-colors duration-200">
              GitHub
            </a>
            <a href="https://www.linkedin.com/in/iamvishalksingh/" target="_blank" rel="noopener noreferrer" className="hover:text-gray-300 transition-colors duration-200">
              LinkedIn
            </a>
            <a href="https://leetcode.com/u/iamvishal/" target="_blank" rel="noopener noreferrer" className="hover:text-gray-300 transition-colors duration-200">
              LeetCode
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;