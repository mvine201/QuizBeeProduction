import express from "express";
import {
  getAllUsers,
  toggleUserStatus,
  getPendingQuizzes,
  moderateQuiz,
  getDashboardStats,
} from "../controllers/adminController.js";
import { protect, adminOnly } from "../middleware/authMiddleware.js";

const router = express.Router();

// Tất cả các route này đều phải đi qua 2 lớp bảo vệ: Đã đăng nhập & Là Admin
router.use(protect, adminOnly);

// --- Routes Quản lý User ---
router.get("/users", getAllUsers);
router.put("/users/:id/toggle-status", toggleUserStatus);

// --- Routes Kiểm duyệt Quiz ---
router.get("/quizzes/pending", getPendingQuizzes);
router.put("/quizzes/:id/moderate", moderateQuiz);
// --- Route Thống kê Dashboard ---
router.get("/stats", getDashboardStats);
export default router;
