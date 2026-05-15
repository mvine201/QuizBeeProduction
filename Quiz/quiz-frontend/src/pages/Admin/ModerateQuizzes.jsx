import { useState, useEffect } from "react";
import adminApi from "../../services/adminApi";
import quizApi from "../../services/quizApi"; // Import thêm quizApi để lấy chi tiết

const ModerateQuizzes = () => {
  const [quizzes, setQuizzes] = useState([]);
  const [loading, setLoading] = useState(true);

  // State cho Modal Xem Chi Tiết
  const [selectedQuiz, setSelectedQuiz] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loadingDetails, setLoadingDetails] = useState(false);

  useEffect(() => {
    fetchPendingQuizzes();
  }, []);

  const fetchPendingQuizzes = async () => {
    try {
      const data = await adminApi.getPendingQuizzes();
      setQuizzes(data);
    } catch {
      alert("Lỗi tải danh sách đề thi");
    } finally {
      setLoading(false);
    }
  };

  // Hàm mở Modal và tải chi tiết đề thi
  const handleViewDetails = async (id) => {
    setLoadingDetails(true);
    setIsModalOpen(true);
    try {
      const data = await quizApi.getQuizById(id);
      setSelectedQuiz(data);
    } catch {
      alert("Lỗi khi tải chi tiết đề thi");
      setIsModalOpen(false);
    } finally {
      setLoadingDetails(false);
    }
  };

  const handleModerate = async (id, action) => {
    const actionText = action === "approve" ? "DUYỆT" : "TỪ CHỐI";
    if (!window.confirm(`Bạn có chắc muốn ${actionText} đề thi này?`)) return;

    try {
      await adminApi.moderateQuiz(id, action);
      // Xóa đề thi vừa xử lý khỏi danh sách
      setQuizzes(quizzes.filter((q) => q._id !== id));
      // Đóng modal nếu đang mở
      setIsModalOpen(false);
    } catch {
      alert("Lỗi khi kiểm duyệt");
    }
  };

  if (loading)
    return (
      <div className="mt-10 font-medium text-gray-500">
        Đang tải danh sách chờ duyệt...
      </div>
    );

  return (
    <div className="relative">
      <h1 className="text-3xl font-bold text-gray-800 mb-6">
        Kiểm Duyệt Đề Thi
      </h1>

      {quizzes.length === 0 ? (
        <div className="bg-green-50 text-green-700 p-6 rounded-lg border border-green-200 text-center font-medium">
          🎉 Hiện tại không có đề thi nào đang chờ duyệt. Tuyệt vời!
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {quizzes.map((quiz) => (
            <div
              key={quiz._id}
              className="bg-white p-6 rounded-lg shadow border border-gray-200 flex flex-col"
            >
              <h3
                className="text-xl font-bold mb-2 truncate"
                title={quiz.title}
              >
                {quiz.title}
              </h3>
              <div className="text-sm text-gray-600 mb-4 space-y-1 flex-grow">
                <p>
                  👤 Tác giả:{" "}
                  <strong>{quiz.author?.username || "Không rõ"}</strong>
                </p>
                <p>🕒 Thời gian: {quiz.timeLimit} phút</p>
                <p>
                  📅 Ngày tạo:{" "}
                  {new Date(quiz.createdAt).toLocaleDateString("vi-VN")}
                </p>
              </div>

              <div className="space-y-3 mt-auto">
                {/* NÚT XEM CHI TIẾT */}
                <button
                  onClick={() => handleViewDetails(quiz._id)}
                  className="w-full bg-blue-50 text-blue-600 border border-blue-200 font-bold py-2 rounded hover:bg-blue-600 hover:text-white transition"
                >
                  🔍 Xem Nội Dung
                </button>

                <div className="flex gap-3">
                  <button
                    onClick={() => handleModerate(quiz._id, "approve")}
                    className="flex-1 bg-green-600 text-white font-bold py-2 rounded hover:bg-green-700 transition"
                  >
                    ✅ Duyệt
                  </button>
                  <button
                    onClick={() => handleModerate(quiz._id, "reject")}
                    className="flex-1 bg-red-100 text-red-600 font-bold py-2 rounded hover:bg-red-200 transition"
                  >
                    ❌ Từ chối
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ================= MODAL XEM CHI TIẾT ================= */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
          <div className="bg-white rounded-lg shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden animate-fadeIn">
            {/* Header Modal */}
            <div className="px-6 py-4 border-b flex justify-between items-center bg-gray-50">
              <h2 className="text-xl font-bold text-gray-800">
                Chi tiết đề thi
              </h2>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-gray-500 hover:text-red-500 text-2xl font-bold"
              >
                &times;
              </button>
            </div>

            {/* Body Modal (Cuộn được) */}
            <div className="p-6 overflow-y-auto flex-grow">
              {loadingDetails ? (
                <div className="text-center py-10 text-gray-500 animate-pulse">
                  Đang tải nội dung câu hỏi...
                </div>
              ) : selectedQuiz ? (
                <div>
                  <div className="mb-6 pb-4 border-b">
                    <h3 className="text-2xl font-bold text-blue-800 mb-2">
                      {selectedQuiz.title}
                    </h3>
                    <p className="text-gray-600 italic">
                      {selectedQuiz.description || "Không có mô tả"}
                    </p>
                    <div className="mt-2 flex gap-4 text-sm font-semibold text-gray-700">
                      <span className="bg-gray-100 px-3 py-1 rounded">
                        ⏱️ {selectedQuiz.timeLimit} phút
                      </span>
                      <span className="bg-gray-100 px-3 py-1 rounded">
                        📝 {selectedQuiz.questions.length} câu hỏi
                      </span>
                    </div>
                  </div>

                  <div className="space-y-6">
                    {selectedQuiz.questions.map((q, index) => (
                      <div
                        key={q._id}
                        className="bg-gray-50 p-4 rounded-lg border border-gray-200"
                      >
                        <p className="font-bold text-gray-800 mb-3">
                          Câu {index + 1}: {q.questionText}
                        </p>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
                          {q.options.map((opt, optIndex) => (
                            <div
                              key={optIndex}
                              className={`p-2 rounded border ${q.correctAnswer === optIndex ? "bg-green-200 border-green-500 font-bold text-green-900" : "bg-white border-gray-300"}`}
                            >
                              {String.fromCharCode(65 + optIndex)}. {opt}
                              {q.correctAnswer === optIndex && (
                                <span className="ml-2">✅</span>
                              )}
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="text-center text-red-500">
                  Không tải được dữ liệu.
                </div>
              )}
            </div>

            {/* Footer Modal (Chứa nút thao tác nhanh) */}
            <div className="px-6 py-4 border-t bg-gray-50 flex justify-end gap-4">
              <button
                onClick={() => setIsModalOpen(false)}
                className="px-6 py-2 bg-gray-300 text-gray-800 font-bold rounded hover:bg-gray-400 transition"
              >
                Đóng
              </button>
              {selectedQuiz && (
                <>
                  <button
                    onClick={() => handleModerate(selectedQuiz._id, "reject")}
                    className="px-6 py-2 bg-red-100 text-red-600 font-bold rounded hover:bg-red-200 transition"
                  >
                    ❌ Từ Chối
                  </button>
                  <button
                    onClick={() => handleModerate(selectedQuiz._id, "approve")}
                    className="px-6 py-2 bg-green-600 text-white font-bold rounded hover:bg-green-700 transition"
                  >
                    ✅ Duyệt Đề Này
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ModerateQuizzes;
