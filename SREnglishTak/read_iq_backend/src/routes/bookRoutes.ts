import { Router, type RequestHandler } from 'express';
import { BookController } from '../controllers/bookController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

// Public Routes
router.get('/', BookController.getAll as RequestHandler);
router.get('/:id', BookController.getById as RequestHandler);

// Admin Only Routes
router.get('/admin/all', authenticate as RequestHandler, authorizeAdmin as RequestHandler, BookController.getAllAdmin as RequestHandler);
router.post('/', authenticate as RequestHandler, authorizeAdmin as RequestHandler, BookController.create as RequestHandler);
router.patch('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, BookController.update as RequestHandler);
router.delete('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, BookController.delete as RequestHandler);

export default router;
