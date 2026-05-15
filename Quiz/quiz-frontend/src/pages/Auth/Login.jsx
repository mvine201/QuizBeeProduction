import { useState, useContext } from "react";
import { useNavigate, Link } from "react-router-dom";
import authApi from "../../services/authApi";
import { AuthContext } from "../../contexts/AuthContextCore";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const { loginContext } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      // Gọi API từ Backend
      const response = await authApi.login({ email, password });

      // Lưu vào Context và LocalStorage
      loginContext(response.user, response.token);

      if (response.user.role === "admin") {
        navigate("/admin"); // Admin vào thẳng trang làm việc của Admin
      } else {
        navigate("/"); // User bình thường thì vào Trang chủ
      }
    } catch (err) {
      // Bắt lỗi từ backend (ví dụ: Sai mật khẩu) trả về
      setError(
        err.response?.data?.message || "Đã có lỗi xảy ra khi đăng nhập.",
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow-md border border-gray-100">
      <h2 className="text-2xl font-bold text-center text-gray-800 mb-6">
        Đăng nhập
      </h2>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4">
          {error}
        </div>
      )}

      <form onSubmit={handleLogin}>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2">
            Email
          </label>
          <input
            type="email"
            required
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Nhập email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <div className="mb-6">
          <label className="block text-gray-700 text-sm font-bold mb-2">
            Mật khẩu
          </label>
          <input
            type="password"
            required
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Nhập mật khẩu"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className={`w-full text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline transition duration-200 
            ${isLoading ? "bg-blue-400 cursor-not-allowed" : "bg-blue-600 hover:bg-blue-700"}`}
        >
          {isLoading ? "Đang xử lý..." : "Đăng nhập"}
        </button>
        <div className="mt-4 flex items-center justify-between text-sm">
          <Link
            to="/forgot-password"
            className="text-gray-500 hover:text-blue-600 hover:underline"
          >
            Quên mật khẩu?
          </Link>
          <span>
            Chưa có tài khoản?{" "}
            <Link
              to="/register"
              className="text-blue-600 hover:underline font-semibold"
            >
              Đăng ký
            </Link>
          </span>
        </div>
      </form>
    </div>
  );
};

export default Login;
