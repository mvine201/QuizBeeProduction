import axios from "axios";

// Đặt base URL trỏ về Backend của bạn
// Tốt nhất sau này nên đưa vào file .env (VITE_API_URL)
const axiosClient = axios.create({
  baseURL: "https://quiz-bee-4vqz.onrender.com/api", // Thay đổi port nếu backend của bạn chạy port khác
  headers: {
    "Content-Type": "application/json",
  },
});

// Interceptor cho Request: Tự động đính kèm Token
axiosClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Interceptor cho Response: Xử lý lỗi chung (đặc biệt là 401 Unauthorized)
axiosClient.interceptors.response.use(
  (response) => {
    return response.data; // Chỉ lấy data, bỏ qua các wrapper của axios
  },
  (error) => {
    const { response, config } = error;

    // Nếu lỗi 401 (Token hết hạn hoặc không hợp lệ)
    if (response && response.status === 401 && !config.url.includes("/login")) {
      console.warn("Token hết hạn hoặc không hợp lệ. Đang đăng xuất...");
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      // Ép chuyển hướng về trang login bằng window.location (cách nhanh nhất bên ngoài React component)
      window.location.href = "/Quiz-Bee/#/login";
    }

    return Promise.reject(error);
  },
);

export default axiosClient;
