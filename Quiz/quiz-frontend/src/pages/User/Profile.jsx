import { useState, useEffect, useContext } from "react";
import userApi from "../../services/userApi";
import { AuthContext } from "../../contexts/AuthContextCore";

const Profile = () => {
  const { loginContext } = useContext(AuthContext); // Dùng để update lại info trên Header nếu đổi tên
  const [activeTab, setActiveTab] = useState("info");

  // States cho cập nhật thông tin
  const [profile, setProfile] = useState({ username: "", email: "" });
  const [infoLoading, setInfoLoading] = useState(false);
  const [infoMessage, setInfoMessage] = useState({ type: "", text: "" });

  // States cho đổi mật khẩu
  const [passwords, setPasswords] = useState({
    oldPassword: "",
    newPassword: "",
    confirmPassword: "",
  });
  const [passLoading, setPassLoading] = useState(false);
  const [passMessage, setPassMessage] = useState({ type: "", text: "" });

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const data = await userApi.getProfile();
        setProfile({ username: data.username, email: data.email });
      } catch {
        setInfoMessage({
          type: "error",
          text: "Không thể tải thông tin cá nhân.",
        });
      }
    };
    fetchProfile();
  }, []);

  const handleUpdateInfo = async (e) => {
    e.preventDefault();
    setInfoLoading(true);
    setInfoMessage({ type: "", text: "" });
    try {
      const updatedUser = await userApi.updateProfile(profile);
      setInfoMessage({
        type: "success",
        text: "Cập nhật thông tin thành công!",
      });

      // Cập nhật lại Context (chỉ update user data, giữ nguyên token trong localStorage)
      const currentToken = localStorage.getItem("token");
      loginContext(updatedUser, currentToken);
    } catch (error) {
      setInfoMessage({
        type: "error",
        text: error.response?.data?.message || "Lỗi khi cập nhật!",
      });
    } finally {
      setInfoLoading(false);
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    setPassMessage({ type: "", text: "" });

    if (passwords.newPassword !== passwords.confirmPassword) {
      return setPassMessage({
        type: "error",
        text: "Mật khẩu xác nhận không khớp!",
      });
    }

    setPassLoading(true);
    try {
      await userApi.changePassword({
        oldPassword: passwords.oldPassword,
        newPassword: passwords.newPassword,
      });
      setPassMessage({ type: "success", text: "Đổi mật khẩu thành công!" });
      setPasswords({ oldPassword: "", newPassword: "", confirmPassword: "" }); // Xóa form
    } catch (error) {
      setPassMessage({
        type: "error",
        text: error.response?.data?.message || "Lỗi khi đổi mật khẩu!",
      });
    } finally {
      setPassLoading(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto mt-10 pb-20">
      <h2 className="text-3xl font-bold text-gray-800 mb-8 text-center">
        Hồ Sơ Cá Nhân
      </h2>

      <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
        {/* Navigation Tabs */}
        <div className="flex bg-green-50 p-2 m-4 rounded-2xl">
          <button
            onClick={() => setActiveTab("info")}
            className={`flex-1 py-3 text-sm font-bold rounded-xl transition ${
              activeTab === "info"
                ? "bg-white text-green-700 shadow"
                : "text-gray-500 hover:text-green-600"
            }`}
          >
            👤 Thông tin chung
          </button>
          <button
            onClick={() => setActiveTab("password")}
            className={`flex-1 py-3 text-sm font-bold rounded-xl transition ${
              activeTab === "password"
                ? "bg-white text-green-700 shadow"
                : "text-gray-500 hover:text-green-600"
            }`}
          >
            🔒 Đổi mật khẩu
          </button>
        </div>

        <div className="p-8">
          {/* TAB 1: THÔNG TIN */}
          {activeTab === "info" && (
            <form
              onSubmit={handleUpdateInfo}
              className="space-y-6 animate-fadeIn"
            >
              {infoMessage.text && (
                <div
                  className={`p-4 rounded-2xl font-medium ${infoMessage.type === "success" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}
                >
                  {infoMessage.text}
                </div>
              )}

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Tên hiển thị
                </label>
                <input
                  type="text"
                  required
                  value={profile.username}
                  onChange={(e) =>
                    setProfile({ ...profile, username: e.target.value })
                  }
                  className="w-full bg-gray-50 border-gray-200 text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Email
                </label>
                <input
                  type="email"
                  required
                  value={profile.email}
                  onChange={(e) =>
                    setProfile({ ...profile, email: e.target.value })
                  }
                  className="w-full bg-gray-50 border-gray-200 text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                />
              </div>

              <button
                type="submit"
                disabled={infoLoading}
                className="w-full py-4 bg-green-600 text-white font-bold rounded-2xl hover:bg-green-700 transition disabled:opacity-50"
              >
                {infoLoading ? "Đang lưu..." : "Lưu Thay Đổi"}
              </button>
            </form>
          )}

          {/* TAB 2: ĐỔI MẬT KHẨU */}
          {activeTab === "password" && (
            <form
              onSubmit={handleChangePassword}
              className="space-y-6 animate-fadeIn"
            >
              {passMessage.text && (
                <div
                  className={`p-4 rounded-2xl font-medium ${passMessage.type === "success" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}
                >
                  {passMessage.text}
                </div>
              )}

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Mật khẩu hiện tại
                </label>
                <input
                  type="password"
                  required
                  value={passwords.oldPassword}
                  onChange={(e) =>
                    setPasswords({ ...passwords, oldPassword: e.target.value })
                  }
                  className="w-full bg-gray-50 border-gray-200 text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Mật khẩu mới
                </label>
                <input
                  type="password"
                  required
                  minLength="6"
                  value={passwords.newPassword}
                  onChange={(e) =>
                    setPasswords({ ...passwords, newPassword: e.target.value })
                  }
                  className="w-full bg-gray-50 border-gray-200 text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Xác nhận mật khẩu mới
                </label>
                <input
                  type="password"
                  required
                  minLength="6"
                  value={passwords.confirmPassword}
                  onChange={(e) =>
                    setPasswords({
                      ...passwords,
                      confirmPassword: e.target.value,
                    })
                  }
                  className="w-full bg-gray-50 border-gray-200 text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                />
              </div>

              <button
                type="submit"
                disabled={passLoading}
                className="w-full py-4 bg-gray-800 text-white font-bold rounded-2xl hover:bg-gray-900 transition disabled:opacity-50"
              >
                {passLoading ? "Đang xử lý..." : "Cập Nhật Mật Khẩu"}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};

export default Profile;
