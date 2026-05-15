import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import authApi from "../../services/authApi";

const ResetPassword = () => {
  const [step, setStep] = useState(1); // Mặc định ở Bước 1
  const [otp, setOtp] = useState("");
  const [password, setPassword] = useState("");

  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();

  // Xử lý BƯỚC 1: Kiểm tra mã OTP
  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setIsLoading(true);

    try {
      await authApi.verifyOTP(otp);
      // Nếu không lỗi tức là mã hợp lệ -> Chuyển sang Bước 2
      setMessage("Mã xác nhận hợp lệ! Mời bạn tạo mật khẩu mới.");
      setStep(2);
    } catch (err) {
      setError(
        err.response?.data?.message || "Mã OTP không hợp lệ hoặc đã hết hạn.",
      );
    } finally {
      setIsLoading(false);
    }
  };

  // Xử lý BƯỚC 2: Cập nhật mật khẩu mới
  const handleResetPassword = async (e) => {
    e.preventDefault();
    setError("");
    setMessage("");

    if (password.length < 6) {
      return setError("Mật khẩu mới phải có ít nhất 6 ký tự.");
    }

    setIsLoading(true);

    try {
      await authApi.resetPassword(otp, password);
      setMessage("Đổi mật khẩu thành công! Đang chuyển hướng...");

      setTimeout(() => {
        navigate("/login");
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message || "Có lỗi xảy ra, vui lòng thử lại.",
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow border border-gray-100">
      <h2 className="text-2xl font-bold text-center text-gray-800 mb-6">
        {step === 1 ? "Xác minh mã OTP" : "Tạo Mật Khẩu Mới"}
      </h2>

      {error && (
        <div className="bg-red-100 text-red-700 px-4 py-3 rounded mb-4 text-sm">
          {error}
        </div>
      )}
      {message && (
        <div className="bg-green-100 text-green-700 px-4 py-3 rounded mb-4 text-sm">
          {message}
        </div>
      )}

      {/* HIỂN THỊ BƯỚC 1 */}
      {step === 1 && (
        <form onSubmit={handleVerifyOTP}>
          <div className="mb-6">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Mã OTP (6 chữ số từ Email)
            </label>
            <input
              type="text"
              required
              maxLength="6"
              className="shadow border rounded w-full py-3 px-3 text-gray-700 font-mono text-center tracking-widest text-2xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="------"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
            />
          </div>

          <button
            type="submit"
            disabled={isLoading || otp.length !== 6}
            className={`w-full text-white font-bold py-3 px-4 rounded transition 
              ${isLoading || otp.length !== 6 ? "bg-blue-400 cursor-not-allowed" : "bg-blue-600 hover:bg-blue-700"}`}
          >
            {isLoading ? "Đang kiểm tra..." : "Kiểm tra mã"}
          </button>
        </form>
      )}

      {step === 2 && (
        <form onSubmit={handleResetPassword}>
          <div className="mb-6">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Nhập mật khẩu mới
            </label>
            <input
              type="password"
              required
              className="shadow border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="Ít nhất 6 ký tự"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className={`w-full text-white font-bold py-3 px-4 rounded transition 
              ${isLoading ? "bg-green-400" : "bg-green-600 hover:bg-green-700"}`}
          >
            {isLoading ? "Đang lưu..." : "Xác nhận đổi mật khẩu"}
          </button>
        </form>
      )}

      <div className="mt-6 text-center text-sm">
        <Link
          to="/login"
          className="text-gray-500 hover:text-blue-600 hover:underline"
        >
          Quay lại đăng nhập
        </Link>
      </div>
    </div>
  );
};

export default ResetPassword;
