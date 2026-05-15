import { useState } from "react";
import { AuthContext } from "./AuthContextCore";

// Tạo Provider để bọc quanh App
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    const storedUser = localStorage.getItem("user");
    return storedUser ? JSON.parse(storedUser) : null;
  });
  const loading = false;

  // Hàm xử lý khi login thành công
  const loginContext = (userData, token) => {
    setUser(userData);
    localStorage.setItem("user", JSON.stringify(userData));
    localStorage.setItem("token", token);
  };

  // Hàm xử lý đăng xuất
  const logoutContext = () => {
    setUser(null);
    localStorage.removeItem("user");
    localStorage.removeItem("token");
    window.location.hash = "/login";
  };

  return (
    <AuthContext.Provider
      value={{ user, loginContext, logoutContext, loading }}
    >
      {children}
    </AuthContext.Provider>
  );
};
