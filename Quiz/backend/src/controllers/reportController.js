import Report from "../models/Report.js";
import Quiz from "../models/Quiz.js";

// [USER] Gửi báo cáo
export const createReport = async (req, res) => {
  try {
    const { quizId, reason, description } = req.body;

    // Kiểm tra xem đề thi có tồn tại không
    const quizExists = await Quiz.findById(quizId);
    if (!quizExists)
      return res.status(404).json({ message: "Không tìm thấy đề thi" });

    // Kiểm tra xem user này đã report đề này chưa
    const alreadyReported = await Report.findOne({
      quiz: quizId,
      reporter: req.user._id,
    });
    if (alreadyReported) {
      return res
        .status(400)
        .json({ message: "Bạn đã gửi báo cáo cho đề thi này rồi!" });
    }

    const report = await Report.create({
      quiz: quizId,
      reporter: req.user._id,
      reason,
      description,
    });

    // Tự động hóa: Nếu đề thi bị report >= 3 lần, chuyển về trạng thái pending (ẩn đi)
    const reportCount = await Report.countDocuments({ quiz: quizId });
    if (reportCount >= 3) {
      quizExists.status = "pending";
      await quizExists.save();
    }

    res.status(201).json({
      message: "Gửi báo cáo thành công! Cảm ơn bạn đã đóng góp.",
      report,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// [ADMIN] Lấy danh sách báo cáo đang chờ xử lý
export const getPendingReports = async (req, res) => {
  try {
    const reports = await Report.find({ status: "pending" })
      .populate("reporter", "username email")
      .populate({
        path: "quiz",
        select: "title author status",
        populate: { path: "author", select: "username" },
      })
      .sort({ createdAt: -1 });

    res.status(200).json(reports);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// [ADMIN] Xử lý báo cáo
export const processReport = async (req, res) => {
  try {
    const { action } = req.body; // "delete_quiz" hoặc "dismiss"
    const report = await Report.findById(req.params.id).populate("quiz");

    if (!report)
      return res.status(404).json({ message: "Không tìm thấy báo cáo" });

    if (action === "delete_quiz") {
      // 1. Xóa đề thi
      if (report.quiz) {
        await Quiz.findByIdAndDelete(report.quiz._id);
      }
      // 2. Đánh dấu tất cả report liên quan đến đề này là đã giải quyết
      await Report.updateMany(
        { quiz: report.quiz?._id },
        { status: "resolved" },
      );

      return res.status(200).json({
        message: "Đã xóa đề thi vi phạm và đóng các báo cáo liên quan.",
      });
    } else if (action === "dismiss") {
      // Bỏ qua báo cáo này (đề thi không có lỗi)
      report.status = "dismissed";
      await report.save();

      // Phục hồi lại trạng thái approved cho đề thi nếu nó lỡ bị hệ thống tự động ẩn
      if (report.quiz && report.quiz.status === "pending") {
        await Quiz.findByIdAndUpdate(report.quiz._id, { status: "approved" });
      }

      return res
        .status(200)
        .json({ message: "Đã bỏ qua báo cáo và khôi phục đề thi." });
    } else {
      return res.status(400).json({ message: "Hành động không hợp lệ" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
