import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import { rateLimit } from 'express-rate-limit';
import { upload } from './middleware/uploadMiddleware.js';
import { supabaseAdmin } from './config/supabase.js';
import { authenticate, authorizeAdmin } from './middleware/authMiddleware.js';

import bookRoutes from './routes/bookRoutes.js';
import quizRoutes from './routes/quizRoutes.js';
import userRoutes from './routes/userRoutes.js';
import adminRoutes from './routes/adminRoutes.js';
import authRoutes from './routes/authRoutes.js';
import vocabularyRoutes from './routes/vocabularyRoutes.js';
import tipsRoutes from './routes/tipsRoutes.js';
import challengeRoutes from './routes/challengeRoutes.js';
import grammarRoutes from './routes/grammarRoutes.js';
import cbseRoutes from './routes/cbseRoutes.js';
import interestRoutes from './routes/interestRoutes.js';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ─── CORS ────────────────────────────────────────────────────────────────────
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['https://book-backned.vercel.app', 'http://localhost:5173', 'http://localhost:3000', 'https://sr-english-tak.vercel.app'];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.warn(`CORS blocked for origin: ${origin}`);
      callback(null, true); // Temporarily allow all for debugging if it still fails
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));

// ─── Security & Logging ──────────────────────────────────────────────────────
app.use((helmet as any)());
app.use(morgan('dev'));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// ─── Rate Limiters ───────────────────────────────────────────────────────────
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  message: { error: 'Too many attempts, please try again after 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const uploadLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 20,
  message: { error: 'Upload rate limit exceeded.' },
});

// ─── Static Files ────────────────────────────────────────────────────────────
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ─── Protected Upload Endpoint ───────────────────────────────────────────────
app.post(
  '/api/upload',
  uploadLimiter,
  authenticate as express.RequestHandler,
  authorizeAdmin as express.RequestHandler,
  upload.single('file'),
  async (req: any, res: any) => {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    try {
      const file = req.file;
      const fileExt = path.extname(file.originalname);
      const fileName = `${Date.now()}-${Math.floor(Math.random() * 1000)}${fileExt}`;

      const { data, error } = await supabaseAdmin.storage
        .from('books')
        .upload(fileName, file.buffer, {
          contentType: file.mimetype,
          upsert: false,
        });

      if (error) {
        console.error('Supabase storage upload error:', error);
        return res.status(500).json({ error: error.message || 'Failed to upload to Supabase' });
      }

      const { data: { publicUrl } } = supabaseAdmin.storage
        .from('books')
        .getPublicUrl(fileName);

      res.json({ url: publicUrl });
    } catch (error: any) {
      console.error('Upload catch error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);

// ─── Routes ──────────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ message: 'ReadIQ Modular API is running' });
});

app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/books', bookRoutes);
app.use('/api/quizzes', quizRoutes);
app.use('/api/user', userRoutes);
app.use('/api/vocabulary', vocabularyRoutes);
app.use('/api/tips', tipsRoutes);
app.use('/api/challenges', challengeRoutes);
app.use('/api/grammar', grammarRoutes);
app.use('/api/cbse', cbseRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/interests', interestRoutes);

// ─── Global Error Handler ────────────────────────────────────────────────────
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

export default app;
