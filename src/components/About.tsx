import React from 'react';
import { Globe, Code, Zap, Smartphone } from 'lucide-react';

const About = () => {
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const highlights = [
    {
      icon: <Globe className="w-8 h-8 text-blue-400" />,
      title: "Full Stack Web",
      description: "Building scalable React & Node.js applications with modern architectures"
    },
    {
      icon: <Smartphone className="w-8 h-8 text-purple-400" />,
      title: "Mobile Expert",
      description: "Developing high-performance iOS & Android apps using Flutter and Native tools"
    },
    {
      icon: <Zap className="w-8 h-8 text-yellow-400" />,
      title: "Performance",
      description: "Optimizing both web and mobile experiences for speed, SEO, and user retention"
    },
    {
      icon: <Code className="w-8 h-8 text-green-400" />,
      title: "Clean Code",
      description: "Maintaining high standards with MVVM patterns, TypeScript, and best practices"
    }
  ];

  const services = [
    "Cross-platform Mobile Development (Flutter)",
    "Native Android Development (Kotlin/Compose)",
    "Full Stack Web Development (React + Node.js)",
    "Firebase & Cloud Backend Integration",
    "UI/UX Design Implementation",
    "App Store & Web Deployment"
  ];

  return (
    <section id="about" className="py-20 bg-gray-900 relative overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0 bg-gradient-to-b from-gray-900 via-gray-800/50 to-gray-900"></div>
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl sm:text-5xl font-bold mb-6">
            <span className="bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent">
              About Me
            </span>
          </h2>
          <div className="w-24 h-1 bg-gradient-to-r from-blue-400 to-purple-500 mx-auto mb-8"></div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Content */}
          <div className="space-y-6">
            <p className="text-lg text-gray-300 leading-relaxed">
              I'm a versatile developer with over 3 years of experience in both **Web and Mobile App Development**. 
              I specialize in helping startups transform their ideas into production-ready digital products across all platforms.
            </p>
            <p className="text-lg text-gray-300 leading-relaxed">
              My expertise covers the entire development lifecycle. On the mobile side, I excel at **Flutter** and **Android**, 
              while on the web, I build robust full-stack applications using **React** and **Node.js**. 
              I am passionate about creating seamless, high-performance user experiences that drive business results.
            </p>
            
            <div className="pt-6">
              <h3 className="text-xl font-semibold mb-4 text-blue-400">Services Offered</h3>
              <div className="space-y-2">
                {services.map((service, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <span className="text-green-400">•</span>
                    <span className="text-gray-300">{service}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Call to Action Buttons */}
            <div className="pt-8">
              <div className="flex flex-col sm:flex-row gap-4">
                <button
                  onClick={() => scrollToSection('projects')}
                  className="px-8 py-3 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-300 hover:scale-105 transform"
                >
                  View My Projects
                </button>
                <button
                  onClick={() => scrollToSection('contact')}
                  className="px-8 py-3 border-2 border-blue-600 rounded-lg font-semibold hover:bg-blue-600 transition-all duration-300 hover:scale-105 transform"
                >
                  Hire Me
                </button>
              </div>
            </div>
          </div>

          {/* Highlights Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {highlights.map((highlight, index) => (
              <div
                key={index}
                className="p-6 bg-gray-800/50 rounded-lg border border-gray-700 hover:border-blue-500/50 transition-all duration-300 hover:scale-105 transform"
              >
                <div className="mb-4">{highlight.icon}</div>
                <h3 className="text-xl font-semibold mb-2">{highlight.title}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">
                  {highlight.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;