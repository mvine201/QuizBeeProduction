import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import quizApi from "../../services/quizApi";

const QuizDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [quiz, setQuiz] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);

  // State cho Modal Report
  const [isReportModalOpen, setIsReportModalOpen] = useState(false);
  const [reportData, setReportData] = useState({
    reason: "Nội dung phản cảm",
    description: "",
  });
  const [isSubmittingReport, setIsSubmittingReport] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [quizData, reviewsData] = await Promise.all([
          quizApi.getQuizById(id),
          quizApi.getQuizReviews(id),
        ]);
        setQuiz(quizData);
        setReviews(reviewsData);
      } catch (err) {
        console.error("Lỗi tải dữ liệu", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  const handleReportSubmit = async (e) => {
    e.preventDefault();
    setIsSubmittingReport(true);
    try {
      await quizApi.reportQuiz({
        quizId: id,
        reason: reportData.reason,
        description: reportData.description,
      });
      alert("Cảm ơn bạn đã báo cáo. Chúng tôi sẽ xem xét sớm nhất!");
      setIsReportModalOpen(false);
      setReportData({ reason: "Nội dung phản cảm", description: "" }); // Reset
    } catch (error) {
      alert(error.response?.data?.message || "Lỗi khi gửi báo cáo");
    } finally {
      setIsSubmittingReport(false);
    }
  };

  if (loading) return <div className="text-center mt-10">Đang tải...</div>;
  if (!quiz)
    return (
      <div className="text-center mt-10 text-red-500">
        Không tìm thấy đề thi
      </div>
    );

  return (
    <div className="max-w-4xl mx-auto mt-10 pb-20 relative">
      {/* Nút Report góc phải trên */}
      <div className="absolute top-4 right-4">
        <button
          onClick={() => setIsReportModalOpen(true)}
          className="text-gray-400 hover:text-red-500 text-sm flex items-center gap-1 transition-colors"
          title="Báo cáo đề thi này"
        >
          🚩 <span className="underline">Báo cáo vi phạm</span>
        </button>
      </div>

      {/* THÔNG TIN ĐỀ THI */}
      <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 mb-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-4 pr-24">
          {quiz.title}
        </h1>
        {quiz.description && (
          <p className="text-gray-600 mb-6">{quiz.description}</p>
        )}

        <div className="bg-green-50 rounded-2xl p-6 mb-8 text-green-900">
          <ul className="space-y-3">
            <li className="flex items-center gap-2">
              <span className="text-xl">⏱️</span> Thời gian:{" "}
              <strong>{quiz.timeLimit} phút</strong>
            </li>
            <li className="flex items-center gap-2">
              <span className="text-xl">📝</span> Số câu hỏi:{" "}
              <strong>{quiz.questions?.length || 0} câu</strong>
            </li>
            <li className="flex items-center gap-2">
              <span className="text-xl">🔄</span> Cho phép thử:{" "}
              <strong>
                {quiz.attemptsAllowed > 0
                  ? quiz.attemptsAllowed + " lần"
                  : "Không giới hạn"}
              </strong>
            </li>
          </ul>
        </div>

        <div className="text-center">
          <button
            onClick={() => navigate(`/quizzes/${id}/take`)}
            className="bg-green-600 hover:bg-green-700 text-white font-bold py-4 px-12 rounded-2xl shadow-md transition transform hover:-translate-y-1"
          >
            Bắt Đầu Làm Bài
          </button>
        </div>
      </div>

      {/* MODAL BÁO CÁO */}
      {isReportModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-40 backdrop-blur-sm p-4">
          <div className="bg-white rounded-3xl shadow-xl w-full max-w-md p-8 animate-fadeIn">
            <h2 className="text-2xl font-bold text-gray-800 mb-2">
              Báo cáo vi phạm
            </h2>
            <p className="text-gray-500 text-sm mb-6">
              Hãy cho chúng tôi biết vấn đề của đề thi này để xây dựng cộng đồng
              học tập tốt hơn.
            </p>

            <form onSubmit={handleReportSubmit} className="space-y-5">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Lý do báo cáo
                </label>
                <select
                  value={reportData.reason}
                  onChange={(e) =>
                    setReportData({ ...reportData, reason: e.target.value })
                  }
                  className="w-full border-gray-200 bg-gray-50 text-gray-700 rounded-xl p-3 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition"
                >
                  <option value="Nội dung phản cảm">
                    Nội dung phản cảm / Không phù hợp
                  </option>
                  <option value="Sai kiến thức/đáp án">
                    Sai kiến thức / Sai đáp án nghiêm trọng
                  </option>
                  <option value="Spam/Trùng lặp">Spam / Đề thi rác</option>
                  <option value="Lý do khác">Lý do khác</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Chi tiết thêm
                </label>
                <textarea
                  required
                  rows="3"
                  value={reportData.description}
                  onChange={(e) =>
                    setReportData({
                      ...reportData,
                      description: e.target.value,
                    })
                  }
                  placeholder="Mô tả rõ hơn vấn đề bạn gặp phải (ví dụ: Câu 3 đáp án bị sai)..."
                  className="w-full border-gray-200 bg-gray-50 text-gray-700 rounded-xl p-3 focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none transition resize-none"
                ></textarea>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setIsReportModalOpen(false)}
                  className="flex-1 py-3 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={isSubmittingReport}
                  className="flex-1 py-3 bg-green-600 text-white font-semibold rounded-xl hover:bg-green-700 transition disabled:opacity-50"
                >
                  {isSubmittingReport ? "Đang gửi..." : "Gửi Báo Cáo"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DANH SÁCH BÌNH LUẬN (Giữ nguyên) */}
      <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">
          Đánh giá từ người dùng
        </h2>
        <div className="space-y-4">
          {reviews.length === 0 ? (
            <p className="text-gray-500 italic text-center py-4 bg-gray-50 rounded-2xl">
              Chưa có đánh giá nào. Hãy là người đầu tiên sau khi làm bài!
            </p>
          ) : (
            reviews.map((rev) => (
              <div
                key={rev._id}
                className="border-b border-gray-100 pb-4 last:border-0"
              >
                <div className="flex justify-between items-center mb-1">
                  <span className="font-bold text-gray-800">
                    {rev.user?.username || "Ẩn danh"}
                  </span>
                  <span className="text-xs text-gray-400">
                    {new Date(rev.createdAt).toLocaleDateString("vi-VN")}
                  </span>
                </div>
                <div className="text-yellow-400 text-sm mb-2">
                  {"⭐".repeat(rev.rating)}
                </div>
                <p className="text-gray-600 text-sm">{rev.comment}</p>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default QuizDetail;
