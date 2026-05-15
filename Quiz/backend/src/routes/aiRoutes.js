import express from "express";
import multer from "multer";
import {
  generateQuizFromTopic,
  generateQuizFromFile,
} from "../controllers/aiController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// Cấu hình Multer: Chỉ lưu trên RAM, chặn file > 5MB
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

// Tất cả tính năng AI đều cần đăng nhập
router.use(protect);

router.post("/generate-topic", generateQuizFromTopic);
router.post("/generate-file", upload.single("file"), generateQuizFromFile);

export default router;
