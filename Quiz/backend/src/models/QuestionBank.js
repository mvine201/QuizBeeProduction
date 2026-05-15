import mongoose from "mongoose";

// Tái sử dụng cấu trúc câu hỏi
const questionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },
  options: [{ type: String, required: true }],
  correctAnswer: { type: Number, required: true },
  points: { type: Number, default: 10 },
});

const questionBankSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    // Chứa một mảng lớn các câu hỏi
    questions: [questionSchema],
  },
  { timestamps: true },
);

export default mongoose.model("QuestionBank", questionBankSchema);
