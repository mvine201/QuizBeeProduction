import express from "express";
import {
  createReport,
  getPendingReports,
  processReport,
} from "../controllers/reportController.js";
import { protect, adminOnly } from "../middleware/authMiddleware.js";

const router = express.Router();

// User gửi báo cáo
router.post("/", protect, createReport);

// Admin quản lý báo cáo
router.get("/pending", protect, adminOnly, getPendingReports);
router.put("/:id/process", protect, adminOnly, processReport);

export default router;
