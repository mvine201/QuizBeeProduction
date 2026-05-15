import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, trim: true, maxlength: 50 },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, "Email không hợp lệ"],
    },
    password: { type: String, required: true, minlength: 6, select: false },
    role: { type: String, enum: ["user", "admin"], default: "user" },
    status: { type: String, enum: ["active", "blocked"], default: "active" },
    resetPasswordToken: { type: String, select: false },
    resetPasswordExpire: { type: Date, select: false },
  },
  { timestamps: true },
);

/**
 * 🔐 Middleware: Hash password tự động
 * Lưu ý: Không dùng tham số 'next' khi dùng async function để tránh lỗi 500
 */
userSchema.pre("save", async function () {
  if (!this.isModified("password")) return;

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  } catch (error) {
    throw new Error(error);
  }
});

/**
 * 🔑 Method: So sánh password
 */
userSchema.methods.matchPassword = async function (enteredPassword) {
  // 'this.password' chỉ có giá trị khi controller dùng .select("+password")
  return await bcrypt.compare(enteredPassword, this.password);
};

export default mongoose.model("User", userSchema);
