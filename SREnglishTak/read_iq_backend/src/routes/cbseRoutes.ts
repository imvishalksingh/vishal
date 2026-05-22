import { Router, type RequestHandler } from 'express';
import { CbseController } from '../controllers/cbseController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

// Categories
router.get('/categories', CbseController.getCategories as RequestHandler);
router.post('/categories', authenticate as RequestHandler, authorizeAdmin as RequestHandler, CbseController.createCategory as RequestHandler);
router.delete('/categories/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, CbseController.deleteCategory as RequestHandler);

// Materials
router.get('/categories/:categoryId/materials', CbseController.getMaterials as RequestHandler);
router.post('/categories/:categoryId/materials', authenticate as RequestHandler, authorizeAdmin as RequestHandler, CbseController.createMaterial as RequestHandler);
router.delete('/materials/:materialId', authenticate as RequestHandler, authorizeAdmin as RequestHandler, CbseController.deleteMaterial as RequestHandler);

export default router;
