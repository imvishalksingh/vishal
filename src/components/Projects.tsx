import React, { useState } from 'react';
import { ExternalLink, ShoppingBag, Globe, Briefcase, Layout, Smartphone } from 'lucide-react';
import ProjectModal from './ProjectModal';

const Projects = () => {
  const [selectedProject, setSelectedProject] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const projects = [
    {
      title: "Leonardi — Premium E-Commerce",
      description: "A high-end e-commerce platform for a luxury men's accessories brand. Features a sophisticated aesthetic, advanced filtering, and cinematic transitions.",
      detailedDescription: "Leonardi is a premium lifestyle e-commerce application designed for a luxury brand specializing in men's accessories. The project focuses on bridging the gap between luxury aesthetics and high-performance commerce logic. Built with React 18 and Tailwind CSS, it handles complex product hierarchies while maintaining a frictionless user journey.",
      image: "/leonardi_mockup_1777375232844.png",
      screenshots: [],
      tags: ["React 18", "Tailwind v4", "Framer Motion", "Vite"],
      icon: <Layout className="w-6 h-6" />,
      role: "Full Stack Web Developer",
      client: "Luxury Lifestyle Brand",
      duration: "1.5 month",
      platform: "Web",
      features: [
        "Real-time filtering by material, pattern, and color",
        "Quick View modals & slide-out management drawers",
        "Cinematic hero carousels with Framer Motion",
        "Google OAuth & custom authentication flows",
        "Predictive global search with suggestions",
        "SEO excellence with dynamic meta-tag management",
        "Multi-level mega-menu and navigation drawer",
        "Integrated CMS-driven lifestyle blog engine"
      ],
      challenges: [
        {
          problem: "Managing complex global state for filters and cart",
          solution: "Implemented specialized service layers and robust state management for seamless data flow"
        },
        {
          problem: "High-performance SEO for a single-page app",
          solution: "Leveraged react-helmet-async for dynamic meta-tag injection and optimized indexability"
        }
      ],
      results: [
        { value: "40%", label: "Faster build with Vite" },
        { value: "98+", label: "Lighthouse SEO score" },
        { value: "Premium", label: "UX feel" },
        { value: "Mobile", label: "First approach" }
      ],
      demo: "http://leonardi.in/"
    },
    {
      title: "Kuddoland — Kids Platform",
      description: "A vibrant child-friendly web platform featuring a playful UI, custom animations, and engaging content for young audiences.",
      detailedDescription: "Kuddoland is a kids-focused web platform designed with a fun, colorful experience. Built with React and Vite, it features custom animations and a playful design language using Baloo 2 & Rubik fonts.",
      image: "/kuddoland_mockup_1777375298381.png",
      screenshots: [],
      tags: ["React", "Vite", "Firebase", "CSS3"],
      icon: <Globe className="w-6 h-6" />,
      role: "Full Stack Web Developer",
      client: "Kuddoland",
      duration: "2.3 month",
      platform: "Web",
      features: [
        "Playful UI with custom color palette",
        "Smooth page animations and interactions",
        "Content management via Firebase",
        "Responsive layout for all devices",
        "Custom Google Fonts integration"
      ],
      demo: "http://kuddoland.com/"
    },
    {
      title: "Alpha Busi — Business Services",
      description: "A professional corporate platform with service showcases, lead capture, CRM integration, and automated deployment.",
      detailedDescription: "AlphaBusi is a corporate business services platform featuring integrated lead capture with Bigin/Zoho CRM, reCAPTCHA validation, and a polished corporate web presence.",
      image: "/alphabusi_mockup_v2_1777375501711.png",
      screenshots: [],
      tags: ["React", "Node.js", "CRM Integration", "cPanel"],
      icon: <Briefcase className="w-6 h-6" />,
      role: "Full Stack Web Developer",
      client: "Alpha Wings Tech Group",
      duration: "2.7 month",
      platform: "Web",
      features: [
        "Lead capture with Bigin/Zoho CRM mapping",
        "Google reCAPTCHA v2 protection",
        "Mega dropdown navigation menus",
        "Automated PowerShell deploy pipeline",
        "SEO optimized structured meta tags"
      ],
      demo: "https://alphabusi.com/"
    },
    {
      title: "Home Decor E-commerce App",
      description: "A modern Flutter shopping app with category browsing, Firebase auth, real-time Firestore sync, and a seamless checkout flow.",
      detailedDescription: "A comprehensive e-commerce mobile solution featuring a modern UI with smooth animations. Includes real-time inventory, personalized recommendations, and a seamless checkout process.",
      image: "/furnix-vertical (1).webp",
      screenshots: ["/furnix-vertical (1).webp"],
      tags: ["Flutter", "Firebase", "Provider", "Stripe"],
      icon: <ShoppingBag className="w-6 h-6" />,
      role: "Full Stack Mobile Developer",
      client: "Furniture startup",
      duration: "3.5 month",
      platform: "iOS & Android",
      features: [
        "Firebase Auth (Email & Social Login)",
        "Real-time cart sync across devices",
        "Advanced product filtering and search",
        "Stripe payment gateway integration",
        "Order tracking with real-time updates",
        "Wishlist with offline support"
      ],
      demo: "https://fryshop-ui-kit.vercel.app/"
    },
    {
      title: "Meal Order MVP",
      description: "A food ordering MVP with menu browsing, cart, and profile features. Built with Flutter for fast user interaction and order sync.",
      detailedDescription: "A streamlined food ordering application designed for quick service restaurants. Focuses on speed and simplicity with real-time order tracking and GPS integration.",
      image: "/preview.png",
      screenshots: ["/preview.png"],
      tags: ["Flutter", "Firebase", "Maps API"],
      icon: <Smartphone className="w-6 h-6" />,
      role: "Mobile App Developer",
      client: "Restaurant prototype",
      duration: "1.2 month",
      platform: "iOS & Android",
      features: [
        "Dynamic menu with customization",
        "Real-time order tracking with GPS",
        "User profile and order history",
        "Digital wallet payment options",
        "Offline menu browsing support"
      ]
    }
  ];

  const openModal = (project: any) => {
    setSelectedProject(project);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedProject(null);
  };

  return (
    <section id="projects" className="py-20 bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl sm:text-5xl font-bold mb-6">
            <span className="bg-gradient-to-r from-blue-400 to-teal-500 bg-clip-text text-transparent">
              Web & Mobile Projects
            </span>
          </h2>
          <div className="w-24 h-1 bg-gradient-to-r from-blue-400 to-teal-500 mx-auto mb-8"></div>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            A showcase of my work across full-stack web and mobile application development
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {projects.map((project, index) => (
            <div
              key={index}
              className="bg-gray-800 rounded-lg overflow-hidden border border-gray-700 hover:border-blue-500/50 transition-all duration-300 hover:scale-105 transform group cursor-pointer"
              onClick={() => openModal(project)}
            >
              <div className="relative overflow-hidden">
                <img
                  src={project.image}
                  alt={project.title}
                  className="w-full h-48 object-cover transition-transform duration-300 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-gray-900 via-transparent to-transparent"></div>
                <div className="absolute top-4 right-4 p-2 bg-gray-900/80 rounded-full">
                  {project.icon}
                </div>
                <div className="absolute inset-0 bg-blue-600/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
                  <span className="text-white font-semibold bg-blue-600 px-4 py-2 rounded-lg">
                    View Details
                  </span>
                </div>
              </div>
              
              <div className="p-6">
                <h3 className="text-xl font-semibold mb-2 text-white">{project.title}</h3>
                <div className="text-sm text-blue-400 mb-1">Role: {project.role}</div>
                {project.client && (
                  <div className="text-sm text-gray-400 mb-3">Client: {project.client}</div>
                )}
                <p className="text-gray-400 mb-4 leading-relaxed text-sm">{project.description}</p>
                
                <div className="mb-4">
                  <h4 className="text-sm font-semibold text-green-400 mb-2">Features:</h4>
                  <ul className="text-sm text-gray-400 space-y-1">
                    {project.features.slice(0, 3).map((feature, featureIndex) => (
                      <li key={featureIndex} className="flex items-start gap-2">
                        <span className="text-green-400 mt-1">•</span>
                        <span>{feature}</span>
                      </li>
                    ))}
                    {project.features.length > 3 && (
                      <li className="text-blue-400 text-xs">
                        +{project.features.length - 3} more...
                      </li>
                    )}
                  </ul>
                </div>
                
                <div className="flex flex-wrap gap-2 mb-6">
                  {project.tags.slice(0, 3).map((tag, tagIndex) => (
                    <span
                      key={tagIndex}
                      className="px-3 py-1 bg-gray-700 text-blue-400 rounded-full text-sm font-medium"
                    >
                      {tag}
                    </span>
                  ))}
                  {project.tags.length > 3 && (
                    <span className="px-3 py-1 bg-gray-700 text-gray-400 rounded-full text-sm">
                      +{project.tags.length - 3}
                    </span>
                  )}
                </div>
                
                <div className="flex gap-4">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      openModal(project);
                    }}
                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors duration-200 text-sm font-medium"
                  >
                    View Details
                  </button>
                  {project.demo && project.demo !== '#' && (
                    <a
                      href={project.demo}
                      target="_blank"
                      rel="noopener noreferrer"
                      onClick={(e) => e.stopPropagation()}
                      className="flex items-center gap-2 px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg transition-colors duration-200 text-sm"
                    >
                      <ExternalLink size={16} />
                      <span>{project.platform === 'Web' ? 'Live Site' : 'Demo'}</span>
                    </a>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Project Modal */}
      <ProjectModal
        project={selectedProject}
        isOpen={isModalOpen}
        onClose={closeModal}
      />
    </section>
  );
};

export default Projects;