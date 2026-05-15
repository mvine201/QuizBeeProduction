import express from "express";
import {
  getUserProfile,
  updateUserProfile,
  changePassword,
} from "../controllers/userController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.use(protect); // Tất cả các route này đều cần đăng nhập

router.route("/profile").get(getUserProfile).put(updateUserProfile);

router.put("/change-password", changePassword);

export default router;
