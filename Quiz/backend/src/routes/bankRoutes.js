import express from "express";
import {
  createBank,
  getMyBanks,
  getBankById,
  updateBank,
  deleteBank,
} from "../controllers/bankController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.use(protect); // Tất cả thao tác ngân hàng đều cần đăng nhập

router.route("/").post(createBank).get(getMyBanks);
router.route("/:id").get(getBankById).put(updateBank).delete(deleteBank);

export default router;
