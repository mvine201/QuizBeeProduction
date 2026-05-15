import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./src/config/db.js";
import authRoutes from "./src/routes/authRoutes.js";
import quizRoutes from "./src/routes/quizRoutes.js";
import adminRoutes from "./src/routes/adminRoutes.js";
import bankRoutes from "./src/routes/bankRoutes.js";
import aiRoutes from "./src/routes/aiRoutes.js";
import reportRoutes from "./src/routes/reportRoutes.js";
import userRoutes from "./src/routes/userRoutes.js";

dotenv.config();
const app = express();

// Kết nối Database
await connectDB();

// 🌐 Middleware
app.use(cors({ origin: "*" }));
app.use(express.json());

// 🧾 Logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// 🚀 Routes
app.use("/api/auth", authRoutes);
app.use("/api/quizzes", quizRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/banks", bankRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/users", userRoutes);
app.get("/", (req, res) => {
  res.send("API đang chạy ngon lành!");
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ message: "API không tồn tại" });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error("❌ Error:", err.message);
  res.status(500).json({
    message: err.message || "Lỗi server",
  });
});

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
