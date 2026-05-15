import { Navigate, Outlet } from "react-router-dom";
import { useContext } from "react";
import { AuthContext } from "../contexts/AuthContextCore";

const ProtectedRoute = () => {
  const { user, loading } = useContext(AuthContext);

  // Đợi Context load xong user từ localStorage
  if (loading) {
    return (
      <div className="text-center mt-20">Đang kiểm tra quyền truy cập...</div>
    );
  }

  // Nếu đã đăng nhập thì cho đi tiếp (Outlet), chưa thì đá về /login
  return user ? <Outlet /> : <Navigate to="/login" replace />;
};

export default ProtectedRoute;
