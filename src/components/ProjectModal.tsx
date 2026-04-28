import React from 'react';
import { X, ExternalLink, Github, Calendar, User, Code, Star } from 'lucide-react';

interface ProjectModalProps {
  project: any;
  isOpen: boolean;
  onClose: () => void;
}

const ProjectModal: React.FC<ProjectModalProps> = ({ project, isOpen, onClose }) => {
  if (!isOpen || !project) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/80 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>
      
      {/* Modal */}
      <div className="relative min-h-screen flex items-center justify-center p-4">
        <div className="relative bg-gray-900 rounded-2xl max-w-6xl w-full max-h-[90vh] overflow-y-auto border border-gray-700">
          {/* Header */}
          <div className="sticky top-0 bg-gray-900/95 backdrop-blur-sm border-b border-gray-700 p-6 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="p-2 bg-gray-800 rounded-lg">
                {project.icon}
              </div>
              <div>
                <h2 className="text-2xl font-bold text-white">{project.title}</h2>
                <p className="text-gray-400">{project.role}</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
            >
              <X size={24} className="text-gray-400" />
            </button>
          </div>

          {/* Content */}
          <div className="p-6">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              
              {/* Left Column - Screenshots */}
              <div className="space-y-6">
                <div>
                  <h3 className="text-xl font-semibold mb-4 text-blue-400">Screenshots</h3>
                  <div className="space-y-4">
                    {project.screenshots.map((screenshot: string, index: number) => (
                      <div key={index} className="relative group">
                        <img
                          src={screenshot}
                          alt={`${project.title} screenshot ${index + 1}`}
                          className="w-full rounded-lg border border-gray-700 hover:border-blue-500/50 transition-all duration-300"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity rounded-lg"></div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Right Column - Details */}
              <div className="space-y-6">
                
                {/* Project Info */}
                <div className="bg-gray-800/50 rounded-lg p-6 border border-gray-700">
                  <h3 className="text-xl font-semibold mb-4 text-purple-400">Project Overview</h3>
                  <div className="space-y-4">
                    <div className="flex items-center gap-3">
                      <User className="w-5 h-5 text-blue-400" />
                      <div>
                        <span className="text-gray-400">Client: </span>
                        <span className="text-white">{project.client}</span>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <Calendar className="w-5 h-5 text-green-400" />
                      <div>
                        <span className="text-gray-400">Duration: </span>
                        <span className="text-white">{project.duration}</span>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <Code className="w-5 h-5 text-yellow-400" />
                      <div>
                        <span className="text-gray-400">Platform: </span>
                        <span className="text-white">{project.platform}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Description */}
                <div>
                  <h3 className="text-xl font-semibold mb-4 text-green-400">Description</h3>
                  <p className="text-gray-300 leading-relaxed">{project.detailedDescription}</p>
                </div>

                {/* Key Features */}
                <div>
                  <h3 className="text-xl font-semibold mb-4 text-blue-400">Key Features</h3>
                  <div className="grid grid-cols-1 gap-3">
                    {project.features.map((feature: string, index: number) => (
                      <div key={index} className="flex items-start gap-3 p-3 bg-gray-800/30 rounded-lg">
                        <Star className="w-4 h-4 text-yellow-400 mt-0.5 flex-shrink-0" />
                        <span className="text-gray-300">{feature}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Technologies */}
                <div>
                  <h3 className="text-xl font-semibold mb-4 text-purple-400">Technologies Used</h3>
                  <div className="flex flex-wrap gap-2">
                    {project.tags.map((tag: string, index: number) => (
                      <span
                        key={index}
                        className="px-3 py-1 bg-gradient-to-r from-blue-600/20 to-purple-600/20 border border-blue-500/30 text-blue-300 rounded-full text-sm font-medium"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Challenges & Solutions */}
                {project.challenges && (
                  <div>
                    <h3 className="text-xl font-semibold mb-4 text-red-400">Challenges & Solutions</h3>
                    <div className="space-y-3">
                      {project.challenges.map((challenge: any, index: number) => (
                        <div key={index} className="p-4 bg-gray-800/30 rounded-lg border-l-4 border-red-500">
                          <h4 className="font-semibold text-red-300 mb-2">{challenge.problem}</h4>
                          <p className="text-gray-300 text-sm">{challenge.solution}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Results */}
                {project.results && (
                  <div>
                    <h3 className="text-xl font-semibold mb-4 text-green-400">Results & Impact</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      {project.results.map((result: any, index: number) => (
                        <div key={index} className="text-center p-4 bg-gray-800/30 rounded-lg">
                          <div className="text-2xl font-bold text-green-400">{result.value}</div>
                          <div className="text-sm text-gray-400">{result.label}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Action Buttons */}
                <div className="flex gap-4 pt-4">
                  {project.demo && (
                    <a
                      href={project.demo}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 rounded-lg transition-all duration-300 hover:scale-105 transform font-semibold"
                    >
                      <ExternalLink size={20} />
                      Live Demo
                    </a>
                  )}
                  <a
                    href="#"
                    className="flex items-center gap-2 px-6 py-3 bg-gray-800 hover:bg-gray-700 rounded-lg transition-colors duration-200 font-semibold"
                  >
                    <Github size={20} />
                    View Code
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProjectModal;