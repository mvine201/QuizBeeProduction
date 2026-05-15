import axiosClient from "./axiosClient";

const authApi = {
  login: (credentials) => {
    return axiosClient.post("/auth/login", credentials);
  },
  register: (userData) => {
    // Sửa "/register" thành "/auth/register"
    return axiosClient.post("/auth/register", userData);
  },
  // Gửi email chứa mã OTP
  forgotPassword: (email) => {
    return axiosClient.post("/auth/forgot-password", { email });
  },
  // Xác thực mã OTP (Backend của bạn cấu hình OTP truyền qua params :token)
  verifyOTP: (otp) => {
    return axiosClient.get(`/auth/verify-otp/${otp}`);
  },

  // Đặt lại mật khẩu mới với mã OTP (Backend của bạn cấu hình OTP truyền qua params :token)
  resetPassword: (otp, newPassword) => {
    return axiosClient.put(`/auth/reset-password/${otp}`, {
      password: newPassword,
    });
  },
};

export default authApi;
