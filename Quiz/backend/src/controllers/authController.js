import User from "../models/User.js";
import jwt from "jsonwebtoken";
import sendEmail from "../utils/sendEmail.js";
import crypto from "crypto";

const generateToken = (user) => {
  return jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
    expiresIn: "1d",
  });
};

export const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    if (!username || !email || !password)
      return res.status(400).json({ message: "Thiếu thông tin" });

    const userExists = await User.findOne({ email });
    if (userExists)
      return res.status(400).json({ message: "Email đã tồn tại" });

    const newUser = await User.create({ username, email, password });
    res.status(201).json({
      message: "Đăng ký thành công",
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: "Thiếu email hoặc mật khẩu" });

    const user = await User.findOne({ email }).select("+password");
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ message: "Sai email hoặc mật khẩu" });
    }

    if (user.status === "blocked")
      return res.status(403).json({ message: "Tài khoản đã bị khóa" });

    res.json({
      token: generateToken(user),
      user: { id: user._id, username: user.username, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ message: "Lỗi hệ thống khi đăng nhập" });
  }
};

// 📧 Quên mật khẩu (Gửi mã OTP 6 số)
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "Email không tồn tại" });

    const resetToken = Math.floor(100000 + Math.random() * 900000).toString();

    user.resetPasswordToken = crypto
      .createHash("sha256")
      .update(resetToken)
      .digest("hex");
    user.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
    await user.save();

    try {
      await sendEmail({
        email: user.email,
        subject: "Mã xác nhận khôi phục mật khẩu Quiz App",
        message: `Mã xác nhận của bạn là: ${resetToken}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e5e7eb; border-radius: 10px; text-align: center;">
            <h2 style="color: #2563eb;">Mã khôi phục mật khẩu 🔒</h2>
            <p style="color: #4b5563; font-size: 16px;">Xin chào <strong>${user.username}</strong>,</p>
            <p style="color: #4b5563; font-size: 16px;">Bạn vừa yêu cầu khôi phục mật khẩu. Dưới đây là mã xác nhận (OTP) của bạn:</p>
            <div style="margin: 30px 0;">
              <span style="background-color: #f3f4f6; color: #1f2937; padding: 15px 30px; border-radius: 8px; font-weight: bold; font-size: 36px; letter-spacing: 8px;">${resetToken}</span>
            </div>
            <p style="color: #6b7280; font-size: 14px;">Mã này sẽ hết hạn sau 10 phút. Vui lòng nhập mã này vào trang web để tiếp tục.</p>
          </div>
        `,
      });
      res.status(200).json({ message: "Mã xác nhận đã được gửi vào email!" });
    } catch (err) {
      console.error("❌ Forgot password email error:", err.message);
      user.resetPasswordToken = undefined;
      user.resetPasswordExpire = undefined;
      await user.save();
      res.status(500).json({ message: "Không thể gửi email" });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔍 Kiểm tra mã OTP xem có hợp lệ không
export const verifyOTP = async (req, res) => {
  try {
    const resetPasswordToken = crypto
      .createHash("sha256")
      .update(req.params.token)
      .digest("hex");
    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user)
      return res
        .status(400)
        .json({ message: "Mã xác nhận không hợp lệ hoặc đã hết hạn" });
    res.status(200).json({ message: "Mã hợp lệ" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔄 Đặt lại mật khẩu mới
export const resetPassword = async (req, res) => {
  try {
    const resetPasswordToken = crypto
      .createHash("sha256")
      .update(req.params.token)
      .digest("hex");
    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user)
      return res
        .status(400)
        .json({ message: "Link khôi phục không hợp lệ hoặc đã hết hạn" });
    if (!req.body.password || req.body.password.length < 6)
      return res
        .status(400)
        .json({ message: "Vui lòng nhập mật khẩu mới ít nhất 6 ký tự" });

    user.password = req.body.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.status(200).json({
      message: "Đặt lại mật khẩu thành công",
      token: generateToken(user),
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
