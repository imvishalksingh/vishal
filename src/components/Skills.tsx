import React from 'react';

const Skills = () => {
  const skillCategories = [
    {
      title: "Mobile Development",
      skills: [
        { name: "Flutter", level: 95 },
        { name: "Dart", level: 93 },
        { name: "Kotlin", level: 88 },
        { name: "Jetpack Compose", level: 85 },
        { name: "iOS/Android Deploy", level: 90 }
      ]
    },
    {
      title: "Web Development",
      skills: [
        { name: "React.js / Next.js", level: 92 },
        { name: "Node.js / Express", level: 88 },
        { name: "TypeScript", level: 90 },
        { name: "Tailwind CSS", level: 92 },
        { name: "HTML5 / CSS3", level: 95 }
      ]
    },
    {
      title: "Backend & DevOps",
      skills: [
        { name: "Firebase / Firestore", level: 92 },
        { name: "MongoDB / SQL", level: 85 },
        { name: "REST APIs", level: 90 },
        { name: "Git & GitHub", level: 92 },
        { name: "cPanel / Vercel", level: 88 }
      ]
    }
  ];

  const additionalTools = [
    "Vite", "Figma", "Postman", "AdMob", "Google Sign-In", "Stripe", "Redux", "Zustand"
  ];

  return (
    <section id="skills" className="py-20 bg-gray-800/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl sm:text-5xl font-bold mb-6">
            <span className="bg-gradient-to-r from-purple-400 to-pink-500 bg-clip-text text-transparent">
              Skills & Expertise
            </span>
          </h2>
          <div className="w-24 h-1 bg-gradient-to-r from-purple-400 to-pink-500 mx-auto mb-8"></div>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Technologies and tools I use to build exceptional digital experiences across Web and Mobile
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
          {skillCategories.map((category, categoryIndex) => (
            <div
              key={categoryIndex}
              className="bg-gray-900 rounded-lg p-8 border border-gray-700 hover:border-purple-500/50 transition-all duration-300"
            >
              <h3 className="text-2xl font-semibold mb-6 text-center text-purple-400">
                {category.title}
              </h3>
              <div className="space-y-6">
                {category.skills.map((skill, skillIndex) => (
                  <div key={skillIndex} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="text-gray-300 font-medium">{skill.name}</span>
                      <span className="text-sm text-gray-400">{skill.level}%</span>
                    </div>
                    <div className="w-full bg-gray-700 rounded-full h-2">
                      <div
                        className="bg-gradient-to-r from-purple-500 to-pink-500 h-2 rounded-full transition-all duration-1000 ease-out"
                        style={{ width: `${skill.level}%` }}
                      ></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Additional Tools */}
        <div className="text-center">
          <h3 className="text-2xl font-semibold mb-6 text-purple-400">Additional Tools</h3>
          <div className="flex flex-wrap justify-center gap-4">
            {additionalTools.map((tool, index) => (
              <span
                key={index}
                className="px-4 py-2 bg-gray-900 rounded-full text-sm font-medium text-purple-400 border border-gray-700 hover:border-purple-500/50 transition-colors duration-200"
              >
                {tool}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default Skills;