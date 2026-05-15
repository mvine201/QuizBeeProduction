import express from "express";
import {
  register,
  login,
  forgotPassword,
  resetPassword,
  verifyOTP, // 👈 Cực kỳ quan trọng: Phải import hàm này
} from "../controllers/authController.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/forgot-password", forgotPassword);

// Route kiểm tra mã OTP (Method: GET)
router.get("/verify-otp/:token", verifyOTP);

// Route đặt lại mật khẩu mới (Method: PUT)
router.put("/reset-password/:token", resetPassword);

export default router;
