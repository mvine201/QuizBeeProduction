import User from "../models/User.js";
import Quiz from "../models/Quiz.js";
import QuizResult from "../models/QuizResult.js";

// 1. Lấy danh sách tất cả người dùng (Có phân trang & Tìm kiếm)
export const getAllUsers = async (req, res) => {
  try {
    const keyword = req.query.keyword
      ? {
          $or: [
            { username: { $regex: req.query.keyword, $options: "i" } },
            { email: { $regex: req.query.keyword, $options: "i" } },
          ],
        }
      : {};

    const users = await User.find(keyword)
      .select("-password")
      .sort({ createdAt: -1 });
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 2. Khóa / Mở khóa tài khoản người dùng
export const toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user)
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    if (user.role === "admin")
      return res
        .status(403)
        .json({ message: "Không thể khóa tài khoản Admin" });

    // Đảo ngược trạng thái
    user.status = user.status === "active" ? "blocked" : "active";
    await user.save();

    res.status(200).json({
      message: `Tài khoản đã được ${user.status === "active" ? "mở khóa" : "khóa"} thành công`,
      user: { id: user._id, username: user.username, status: user.status },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ==========================================
// 📝 KIỂM DUYỆT BÀI ĐĂNG (QUIZ)
// ==========================================

// 3. Lấy danh sách các đề thi đang chờ duyệt
export const getPendingQuizzes = async (req, res) => {
  try {
    const quizzes = await Quiz.find({ status: "pending", isPublic: true })
      .populate("author", "username email")
      .select("-questions") // Không cần lấy chi tiết câu hỏi để load cho nhanh
      .sort({ createdAt: -1 });

    res.status(200).json(quizzes);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 4. Duyệt hoặc Từ chối đề thi
export const moderateQuiz = async (req, res) => {
  try {
    const { action } = req.body; // "approve" hoặc "reject"
    const quiz = await Quiz.findById(req.params.id);

    if (!quiz)
      return res.status(404).json({ message: "Không tìm thấy đề thi" });

    if (action === "approve") {
      quiz.status = "approved";
    } else if (action === "reject") {
      quiz.status = "rejected";
      // Tùy chọn: Bạn có thể lưu thêm lý do từ chối vào một trường rejectReason
    } else {
      return res.status(400).json({ message: "Hành động không hợp lệ" });
    }

    await quiz.save();

    res.status(200).json({
      message: `Đã ${action === "approve" ? "duyệt" : "từ chối"} đề thi thành công`,
      quizId: quiz._id,
      status: quiz.status,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// Thêm hàm này vào adminController.js
// 5. Thống kê tổng quan cho dashboard admin
export const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ status: "active" });
    const blockedUsers = await User.countDocuments({ status: "blocked" });

    const totalQuizzes = await Quiz.countDocuments();
    const pendingQuizzes = await Quiz.countDocuments({ status: "pending" });
    const approvedQuizzes = await Quiz.countDocuments({ status: "approved" });

    const totalResults = await QuizResult.countDocuments();

    res.status(200).json({
      users: { total: totalUsers, active: activeUsers, blocked: blockedUsers },
      quizzes: {
        total: totalQuizzes,
        pending: pendingQuizzes,
        approved: approvedQuizzes,
      },
      results: { total: totalResults },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
