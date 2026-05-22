import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://book-backned.vercel.app/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add interceptor to include auth token
api.interceptors.request.use(async (config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const ApiService = {
  // Auth
  login: (credentials) => api.post('/auth/login', credentials),
  
  // Stats
  getStats: () => api.get('/admin/stats'),
  
  // Users
  getUsers: () => api.get('/admin/users'),
  getUserProgress: (userId) => api.get(`/admin/users/${userId}/progress`),
  
  // Books
  getBooks: () => api.get('/books'),
  createBook: (data) => api.post('/books', data),
  deleteBook: (id) => api.delete(`/books/${id}`),
  
  // Grammar
  getGrammarUnits: () => api.get('/grammar/units'),
  createGrammarUnit: (data) => api.post('/grammar/units', data),
  deleteGrammarUnit: (id) => api.delete(`/grammar/units/${id}`),
  getGrammarLessons: (unitId) => api.get(`/grammar/units/${unitId}/lessons`),
  createGrammarLesson: (unitId, data) => api.post(`/grammar/units/${unitId}/lessons`, data),
  bulkCreateGrammarLessons: (unitId, lessons) => api.post(`/grammar/units/${unitId}/lessons/bulk`, { lessons }),
  deleteGrammarLesson: (lessonId) => api.delete(`/grammar/lessons/${lessonId}`),
  
  // CBSE
  getCbseCategories: () => api.get('/cbse/categories'),
  createCbseCategory: (data) => api.post('/cbse/categories', data),
  deleteCbseCategory: (id) => api.delete(`/cbse/categories/${id}`),
  getCbseMaterials: (categoryId) => api.get(`/cbse/categories/${categoryId}/materials`),
  createCbseMaterial: (categoryId, data) => api.post(`/cbse/categories/${categoryId}/materials`, data),
  deleteCbseMaterial: (materialId) => api.delete(`/cbse/materials/${materialId}`),
  
  // Tips & Vocabulary
  getDailyTips: () => api.get('/tips'),
  createDailyTip: (data) => api.post('/tips', data),
  deleteDailyTip: (id) => api.delete(`/tips/${id}`),
  
  getVocabulary: () => api.get('/vocabulary'),
  createVocabulary: (data) => api.post('/vocabulary', data),
  bulkCreateVocabulary: (items) => api.post('/vocabulary/bulk', { items }),
  deleteVocabulary: (id) => api.delete(`/vocabulary/${id}`),
  
  // Challenges
  getChallenges: () => api.get('/challenges'),
  createChallenge: (data) => api.post('/challenges', data),
  deleteChallenge: (id) => api.delete(`/challenges/${id}`),
};

export default api;
