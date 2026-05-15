import { Outlet, Link } from "react-router-dom";
import { useContext } from "react";
import { AuthContext } from "../contexts/AuthContextCore";

const MainLayout = () => {
  const { user, logoutContext } = useContext(AuthContext);

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <header className="bg-blue-600 text-white p-4 shadow-md">
        <div className="container mx-auto flex justify-between items-center">
          <Link to="/" className="text-xl font-bold">
            Quiz App
          </Link>
          <nav className="space-x-4">
            {user ? (
              <div className="flex items-center space-x-4">
                <span className="font-medium">Chào, {user.username}</span>
                {/* 👉 CHỈ HIỂN THỊ MENU NÀY VỚI USER BÌNH THƯỜNG */}
                {user.role !== "admin" && (
                  <>
                    <Link to="/" className="hover:underline">
                      Trang chủ
                    </Link>
                    <Link
                      to="/banks"
                      className="hover:underline text-indigo-200 font-semibold"
                    >
                      Ngân Hàng Câu Hỏi
                    </Link>
                    <Link to="/my-quizzes" className="hover:underline">
                      Quản lý Đề Thi
                    </Link>
                    <Link to="/history" className="hover:underline">
                      Lịch sử thi
                    </Link>
                    <Link
                      to="/profile"
                      className="font-medium hover:text-green-300 transition"
                    >
                      Chào, {user.username}
                    </Link>
                  </>
                )}

                {/* 👉 CHỈ HIỂN THỊ NÚT NÀY VỚI ADMIN */}
                {user.role === "admin" && (
                  <Link
                    to="/admin"
                    className="text-yellow-300 font-bold hover:underline"
                  >
                    ⚡ Vào Trang Quản Trị
                  </Link>
                )}
                <button
                  onClick={logoutContext}
                  className="bg-red-500 hover:bg-red-600 px-3 py-1 rounded text-sm"
                >
                  Đăng xuất
                </button>
              </div>
            ) : (
              <>
                <Link to="/login" className="hover:underline">
                  Đăng nhập
                </Link>
                <Link to="/register" className="hover:underline">
                  Đăng ký
                </Link>
              </>
            )}
          </nav>
        </div>
      </header>

      <main className="flex-grow container mx-auto p-4">
        <Outlet />
      </main>

      <footer className="bg-gray-800 text-white text-center p-4 mt-auto">
        &copy; 2026 Quiz App. All rights reserved.
      </footer>
    </div>
  );
};

export default MainLayout;
