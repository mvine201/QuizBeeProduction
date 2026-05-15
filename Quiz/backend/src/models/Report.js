import mongoose from "mongoose";

const reportSchema = new mongoose.Schema(
  {
    quiz: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Quiz",
      required: true,
    },
    reporter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    reason: {
      type: String,
      required: true,
      enum: [
        "Nội dung phản cảm",
        "Sai kiến thức/đáp án",
        "Spam/Trùng lặp",
        "Lý do khác",
      ],
    },
    description: {
      type: String,
      required: true,
      maxlength: 500,
    },
    status: {
      type: String,
      enum: ["pending", "resolved", "dismissed"],
      default: "pending",
    },
  },
  { timestamps: true },
);

// Tránh việc 1 user spam report cùng 1 đề thi nhiều lần
reportSchema.index({ quiz: 1, reporter: 1 }, { unique: true });

export default mongoose.model("Report", reportSchema);
