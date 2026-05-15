import { useState, useEffect } from "react";
import adminApi from "../../services/adminApi";

const ManageUsers = () => {
  const [users, setUsers] = useState([]);
  const [keyword, setKeyword] = useState("");
  const [loading, setLoading] = useState(true);

  const fetchUsers = async (searchParams = "") => {
    setLoading(true);
    try {
      const data = await adminApi.getAllUsers(searchParams);
      setUsers(data);
    } catch {
      alert("Lỗi tải danh sách người dùng");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    fetchUsers(keyword);
  };

  const handleToggleStatus = async (id, currentStatus, role) => {
    if (role === "admin") {
      alert("Không thể khóa tài khoản Admin!");
      return;
    }

    const actionText = currentStatus === "active" ? "KHÓA" : "MỞ KHÓA";
    if (!window.confirm(`Bạn có chắc chắn muốn ${actionText} người dùng này?`))
      return;

    try {
      const res = await adminApi.toggleUserStatus(id);
      // Cập nhật lại state mà không cần gọi lại API
      setUsers(
        users.map((u) =>
          u._id === id ? { ...u, status: res.user.status } : u,
        ),
      );
    } catch (error) {
      alert(error.response?.data?.message || "Lỗi khi cập nhật trạng thái");
    }
  };

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-800 mb-6">
        Quản lý Người Dùng
      </h1>

      {/* Thanh tìm kiếm */}
      <form onSubmit={handleSearch} className="mb-6 flex gap-2">
        <input
          type="text"
          placeholder="Tìm theo username hoặc email..."
          className="border border-gray-300 rounded px-4 py-2 w-1/3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
        <button
          type="submit"
          className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
        >
          Tìm kiếm
        </button>
      </form>

      {/* Bảng danh sách user */}
      <div className="bg-white rounded shadow overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-gray-100 border-b">
            <tr>
              <th className="p-4 font-semibold text-gray-600">Tên Đăng Nhập</th>
              <th className="p-4 font-semibold text-gray-600">Email</th>
              <th className="p-4 font-semibold text-gray-600 text-center">
                Vai trò
              </th>
              <th className="p-4 font-semibold text-gray-600 text-center">
                Trạng thái
              </th>
              <th className="p-4 font-semibold text-gray-600 text-center">
                Hành động
              </th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="5" className="p-4 text-center">
                  Đang tải...
                </td>
              </tr>
            ) : (
              users.map((u) => (
                <tr key={u._id} className="border-b hover:bg-gray-50">
                  <td className="p-4 font-medium">{u.username}</td>
                  <td className="p-4 text-gray-600">{u.email}</td>
                  <td className="p-4 text-center">
                    <span
                      className={`px-2 py-1 rounded text-xs font-bold ${u.role === "admin" ? "bg-purple-100 text-purple-700" : "bg-gray-100 text-gray-700"}`}
                    >
                      {u.role.toUpperCase()}
                    </span>
                  </td>
                  <td className="p-4 text-center">
                    <span
                      className={`px-2 py-1 rounded text-xs font-bold ${u.status === "active" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}
                    >
                      {u.status === "active" ? "Hoạt động" : "Bị Khóa"}
                    </span>
                  </td>
                  <td className="p-4 text-center">
                    {u.role !== "admin" && (
                      <button
                        onClick={() =>
                          handleToggleStatus(u._id, u.status, u.role)
                        }
                        className={`text-sm font-semibold hover:underline ${u.status === "active" ? "text-red-600" : "text-green-600"}`}
                      >
                        {u.status === "active" ? "Khóa TK" : "Mở Khóa"}
                      </button>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ManageUsers;
