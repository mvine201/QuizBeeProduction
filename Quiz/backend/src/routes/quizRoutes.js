import express from "express";
import multer from "multer";

import {
  createQuiz,
  getMyQuizzes,
  getPublicQuizzes,
  getQuizById,
  updateQuiz,
  deleteQuiz,
  getQuizForTake,
  submitQuiz,
  importQuizUniversal,
  parseFilePreview,
  getUserHistory,
  generateQuizFromBank,
} from "../controllers/quizController.js";

import { protect } from "../middleware/authMiddleware.js";
import { addReview, getQuizReviews } from "../controllers/reviewController.js";

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

// --- CÁC ROUTE CỐ ĐỊNH (STATIC) PHẢI ĐẶT TRÊN CÙNG ---

// Public
router.get("/public", protect, getPublicQuizzes);

// 2. Route Lịch sử (Phải đặt TRƯỚC các route có biến :id)
router.get("/user/history", protect, getUserHistory);

// Import & Parse File
router.post("/import", protect, upload.single("file"), importQuizUniversal);
router.post("/parse-file", protect, upload.single("file"), parseFilePreview);

// Review
router.post("/reviews", protect, addReview);
router.get("/:quizId/reviews", getQuizReviews);

// Quiz chung
router.route("/").post(protect, createQuiz).get(protect, getMyQuizzes);
router.post("/generate-from-bank", protect, generateQuizFromBank);
// --- CÁC ROUTE CÓ BIẾN ĐỘNG (:id) ĐẶT DƯỚI CÙNG ---

router.get("/:id/take", protect, getQuizForTake);
router.post("/:id/submit", protect, submitQuiz);

router
  .route("/:id")
  .get(protect, getQuizById)
  .put(protect, updateQuiz)
  .delete(protect, deleteQuiz);

export default router;
