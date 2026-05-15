import { useState, useEffect } from "react";
import adminApi from "../../services/adminApi";

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await adminApi.getDashboardStats(); // Bạn nhớ thêm hàm này vào adminApi.js nhé
        setStats(data);
      } catch {
        console.error("Lỗi tải thống kê");
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) return <div>Đang tính toán số liệu...</div>;

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-8">Bảng Điều Khiển Quản Trị</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Thẻ Người Dùng */}
        <div className="bg-white p-6 rounded-lg shadow border-l-4 border-blue-500">
          <h3 className="text-gray-500 text-sm font-bold uppercase">
            Người dùng
          </h3>
          <p className="text-3xl font-bold">{stats.users.total}</p>
          <div className="mt-2 text-sm">
            <span className="text-green-600 font-bold">
              {stats.users.active} Hoạt động
            </span>
            <span className="mx-2 text-gray-300">|</span>
            <span className="text-red-600 font-bold">
              {stats.users.blocked} Bị khóa
            </span>
          </div>
        </div>

        {/* Thẻ Đề Thi */}
        <div className="bg-white p-6 rounded-lg shadow border-l-4 border-purple-500">
          <h3 className="text-gray-500 text-sm font-bold uppercase">Đề thi</h3>
          <p className="text-3xl font-bold">{stats.quizzes.total}</p>
          <div className="mt-2 text-sm">
            <span className="text-green-600 font-bold">
              {stats.quizzes.approved} Đã duyệt
            </span>
            <span className="mx-2 text-gray-300">|</span>
            <span className="text-yellow-600 font-bold">
              {stats.quizzes.pending} Chờ duyệt
            </span>
          </div>
        </div>

        {/* Thẻ Lượt Thi */}
        <div className="bg-white p-6 rounded-lg shadow border-l-4 border-green-500">
          <h3 className="text-gray-500 text-sm font-bold uppercase">
            Tổng lượt thi
          </h3>
          <p className="text-3xl font-bold">{stats.results.total}</p>
          <p className="text-sm text-gray-400 mt-2 italic">
            Dữ liệu được cập nhật thời gian thực
          </p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
