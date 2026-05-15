import mongoose from "mongoose";

const questionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },
  options: [{ type: String, required: true }],
  correctAnswer: { type: Number, required: true },
  points: { type: Number, default: 10 },
});

const quizSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String },

    timeLimit: { type: Number, required: true },

    shuffleQuestions: { type: Boolean, default: false },
    shuffleAnswers: { type: Boolean, default: false }, // ✅ NEW

    isPublic: { type: Boolean, default: false },

    attemptsAllowed: { type: Number, default: 0 },

    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // 🚀 NEW: Thêm trường status để Admin kiểm duyệt
    status: {
      type: String,
      enum: ["draft", "pending", "approved", "rejected"],
      default: "pending", // Mặc định khi user tạo xong sẽ ở trạng thái chờ duyệt
    },

    questions: [questionSchema],
  },
  { timestamps: true },
);

export default mongoose.model("Quiz", quizSchema);
