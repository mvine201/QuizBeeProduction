import mongoose from "mongoose";

const quizResultSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    quiz: { type: mongoose.Schema.Types.ObjectId, ref: "Quiz", required: true },
    score: { type: Number, required: true }, // Tổng điểm (thang 100 hoặc tùy ý)
    correctCount: { type: Number, required: true }, // Số câu đúng
    totalQuestions: { type: Number, required: true }, // Tổng số câu
    // Lưu lại chi tiết bài làm để hiển thị câu đúng/sai
    userAnswers: [
      {
        questionId: { type: mongoose.Schema.Types.ObjectId },
        selectedOption: { type: Number }, // Đáp án user chọn (0, 1, 2, 3)
        isCorrect: { type: Boolean },
      },
    ],
  },
  { timestamps: true },
);

export default mongoose.model("QuizResult", quizResultSchema);
