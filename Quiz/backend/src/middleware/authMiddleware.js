import jwt from "jsonwebtoken";
import User from "../models/User.js";

// 🔐 Middleware bảo vệ route
export const protect = async (req, res, next) => {
  try {
    if (!process.env.JWT_SECRET) {
      throw new Error("JWT_SECRET chưa được cấu hình");
    }

    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        message: "Không có token, truy cập bị từ chối",
      });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 🔥 Lấy user từ DB
    const user = await User.findById(decoded.id).select("-password");

    if (!user) {
      return res.status(401).json({
        message: "User không tồn tại",
      });
    }

    // ❗ Check bị block
    if (user.status === "blocked") {
      return res.status(403).json({
        message: "Tài khoản đã bị khóa",
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      message: "Token không hợp lệ",
    });
  }
};

// 🔒 Middleware kiểm tra admin
export const adminOnly = (req, res, next) => {
  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({
      message: "Chỉ Admin mới có quyền này",
    });
  }
  next();
};
