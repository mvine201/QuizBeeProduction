import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import authApi from "../../services/authApi";

const ForgotPassword = () => {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setIsLoading(true);

    try {
      await authApi.forgotPassword(email);
      setMessage(
        "Mã xác nhận (OTP) đã được gửi đến email của bạn! Vui lòng kiểm tra hộp thư.",
      );

      // Đợi 2 giây rồi tự động chuyển sang trang nhập mã OTP
      setTimeout(() => {
        navigate("/reset-password");
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message || "Không thể gửi email. Vui lòng thử lại.",
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow border border-gray-100">
      <h2 className="text-2xl font-bold text-center text-gray-800 mb-2">
        Quên Mật Khẩu
      </h2>
      <p className="text-center text-gray-500 mb-6 text-sm">
        Nhập email của bạn, chúng tôi sẽ gửi mã OTP gồm 6 chữ số để khôi phục.
      </p>

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

      <form onSubmit={handleSubmit}>
        <div className="mb-6">
          <label className="block text-gray-700 text-sm font-bold mb-2">
            Email đã đăng ký
          </label>
          <input
            type="email"
            required
            className="shadow border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Ví dụ: conankudo@gmail.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className={`w-full text-white font-bold py-2 px-4 rounded transition 
            ${isLoading ? "bg-blue-400" : "bg-blue-600 hover:bg-blue-700"}`}
        >
          {isLoading ? "Đang gửi email..." : "Nhận mã xác nhận"}
        </button>

        <div className="mt-4 text-center text-sm">
          Nhớ lại mật khẩu?{" "}
          <Link to="/login" className="text-blue-600 hover:underline">
            Quay lại đăng nhập
          </Link>
        </div>
      </form>
    </div>
  );
};

export default ForgotPassword;
