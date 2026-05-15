import { useEffect, useState, useContext } from "react";
import { Link, Navigate } from "react-router-dom";
import { AuthContext } from "../contexts/AuthContextCore";
import quizApi from "../services/quizApi";

const Home = () => {
  const { user } = useContext(AuthContext);
  const [quizzes, setQuizzes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // States cho Tìm kiếm và Phân trang
  const [keyword, setKeyword] = useState("");
  const [searchInput, setSearchInput] = useState(""); // Giữ giá trị ô input
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    const fetchQuizzes = async () => {
      if (!user) return;

      setLoading(true);
      try {
        const data = await quizApi.getPublicQuizzes({
          keyword: keyword,
          page: currentPage,
          limit: 6, // Hiển thị 6 đề mỗi trang cho đẹp lưới
        });

        setQuizzes(data.quizzes || []);
        setTotalPages(data.totalPages || 1);
      } catch {
        setError("Không thể tải danh sách đề thi.");
      } finally {
        setLoading(false);
      }
    };

    fetchQuizzes();
  }, [user, keyword, currentPage]);

  if (user && user.role === "admin") {
    return <Navigate to="/admin" replace />;
  }

  // Khi bấm nút Kính lúp hoặc Enter
  const handleSearch = (e) => {
    e.preventDefault();
    setKeyword(searchInput);
    setCurrentPage(1); // Bắt đầu tìm kiếm thì quay về trang 1
  };

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= totalPages) {
      setCurrentPage(newPage);
    }
  };

  return (
    <div className="mt-8 mb-20 max-w-7xl mx-auto px-4">
      <div className="text-center mb-10">
        <h1 className="text-4xl font-bold text-gray-800 mb-4">
          Hệ Thống Thi Trắc Nghiệm
        </h1>
        <p className="text-gray-600">
          Ôn tập và kiểm tra kiến thức của bạn mọi lúc, mọi nơi.
        </p>
      </div>

      {!user ? (
        <div className="bg-white p-8 rounded-3xl shadow-sm text-center max-w-2xl mx-auto border border-gray-100">
          <h2 className="text-2xl font-semibold mb-4">Bạn chưa đăng nhập</h2>
          <p className="text-gray-600 mb-6">
            Vui lòng đăng nhập hoặc đăng ký tài khoản để xem các đề thi đang có
            sẵn trên hệ thống.
          </p>
          <div className="space-x-4">
            <Link
              to="/login"
              className="bg-green-600 text-white px-8 py-3 rounded-2xl hover:bg-green-700 transition font-semibold shadow-sm"
            >
              Đăng nhập
            </Link>
            <Link
              to="/register"
              className="bg-gray-100 text-gray-800 px-8 py-3 rounded-2xl hover:bg-gray-200 transition font-semibold"
            >
              Đăng ký
            </Link>
          </div>
        </div>
      ) : (
        <div>
          {/* THANH TÌM KIẾM */}
          <div className="mb-10 max-w-2xl mx-auto">
            <form onSubmit={handleSearch} className="flex gap-2">
              <input
                type="text"
                value={searchInput}
                onChange={(e) => setSearchInput(e.target.value)}
                placeholder="Tìm kiếm đề thi..."
                className="w-full border-gray-200 bg-white text-gray-700 rounded-2xl p-4 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition shadow-sm"
              />
              <button
                type="submit"
                className="bg-green-600 hover:bg-green-700 text-white font-bold py-4 px-8 rounded-2xl shadow-sm transition"
              >
                🔍
              </button>
            </form>
          </div>

          <h2 className="text-2xl font-bold border-l-4 border-green-600 pl-3 mb-6 text-gray-800">
            {keyword ? `Kết quả tìm kiếm cho: "${keyword}"` : "Đề thi mới nhất"}
          </h2>

          {loading && (
            <p className="text-center text-gray-500 my-10 animate-pulse">
              Đang tải đề thi...
            </p>
          )}
          {error && <p className="text-center text-red-500 my-10">{error}</p>}

          {!loading && !error && quizzes.length === 0 && (
            <div className="text-center py-12 bg-gray-50 rounded-3xl border border-dashed border-gray-200">
              <span className="text-4xl">📭</span>
              <p className="text-gray-500 mt-4 font-medium">
                Không tìm thấy đề thi nào phù hợp.
              </p>
            </div>
          )}

          {/* LƯỚI ĐỀ THI */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {quizzes.map((quiz) => (
              <div
                key={quiz._id}
                className="bg-white rounded-3xl shadow-sm hover:shadow-md transition-shadow border border-gray-100 overflow-hidden flex flex-col"
              >
                <div className="p-6 flex-grow">
                  <h3
                    className="text-xl font-bold text-gray-800 mb-3 line-clamp-2"
                    title={quiz.title}
                  >
                    {quiz.title}
                  </h3>
                  <div className="text-sm text-gray-600 space-y-2">
                    <p className="flex items-center gap-2">
                      <span className="text-lg">⏱️</span> {quiz.timeLimit} phút
                    </p>
                    <p className="flex items-center gap-2">
                      <span className="text-lg">✍️</span>{" "}
                      {quiz.author?.username || "Ẩn danh"}
                    </p>
                    <p className="flex items-center gap-2">
                      <span className="text-lg">🔄</span>{" "}
                      {quiz.attemptsAllowed > 0
                        ? `${quiz.attemptsAllowed} lần thử`
                        : "Vô hạn lần thử"}
                    </p>
                  </div>
                </div>
                <div className="px-6 pb-6 mt-auto">
                  <Link
                    to={`/quizzes/${quiz._id}`}
                    className="block w-full text-center bg-green-50 text-green-700 font-bold py-3 rounded-2xl hover:bg-green-600 hover:text-white transition-colors"
                  >
                    Xem chi tiết
                  </Link>
                </div>
              </div>
            ))}
          </div>

          {/* CỤM NÚT PHÂN TRANG */}
          {!loading && totalPages > 1 && (
            <div className="flex justify-center items-center gap-2 mt-12">
              <button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className="p-3 rounded-xl font-bold transition-colors disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 text-gray-600"
              >
                &lt; Trước
              </button>

              {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                (page) => (
                  <button
                    key={page}
                    onClick={() => handlePageChange(page)}
                    className={`w-10 h-10 rounded-xl font-bold transition-colors ${
                      currentPage === page
                        ? "bg-green-600 text-white shadow-md"
                        : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"
                    }`}
                  >
                    {page}
                  </button>
                ),
              )}

              <button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                className="p-3 rounded-xl font-bold transition-colors disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 text-gray-600"
              >
                Sau &gt;
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Home;
