import { useState } from "react";
import { useLocation, Link } from "react-router-dom";
import quizApi from "../../services/quizApi";

const QuizResult = () => {
  const location = useLocation();
  const result = location.state?.result;
  const quiz = location.state?.quiz;

  // --- STATE CHO ĐÁNH GIÁ ---
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState("");
  const [submittingReview, setSubmittingReview] = useState(false);
  const [isReviewed, setIsReviewed] = useState(false); // Check xem đã gửi đánh giá chưa

  if (!result || !quiz) {
    return (
      <div className="text-center mt-10">
        <p>Không tìm thấy dữ liệu kết quả.</p>
        <Link to="/" className="text-blue-500 underline">
          Về trang chủ
        </Link>
      </div>
    );
  }

  // --- HÀM GỬI ĐÁNH GIÁ ---
  const handleSubmitReview = async (e) => {
    e.preventDefault();
    if (!comment.trim()) return;

    const quizId = quiz._id || quiz.id;
    if (!quizId) {
      alert("Không tìm thấy mã đề thi để gửi đánh giá");
      return;
    }

    setSubmittingReview(true);
    try {
      await quizApi.addReview({
        quizId,
        rating,
        comment: comment.trim(),
      });
      setIsReviewed(true); // Đổi trạng thái để ẩn form đi
    } catch (err) {
      alert(err.response?.data?.message || "Lỗi khi gửi đánh giá");
    } finally {
      setSubmittingReview(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto mt-10 pb-20">
      {/* 1. KHỐI TỔNG ĐIỂM (Giữ nguyên của bạn) */}
      <div className="bg-white p-8 rounded-lg shadow-lg text-center border-t-8 border-green-500 mb-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">
          Hoàn thành bài thi!
        </h1>
        <p className="text-gray-500 mb-8">
          Kết quả của bạn đã được hệ thống ghi nhận.
        </p>

        <div className="flex justify-center items-center space-x-12 mb-8">
          <div className="text-center">
            <p className="text-sm text-gray-500 uppercase tracking-wide">
              Tổng Điểm
            </p>
            <p className="text-6xl font-black text-blue-600">
              {result.score}
              <span className="text-2xl text-gray-400">/10</span>
            </p>
          </div>
          <div className="h-16 w-px bg-gray-200"></div>
          <div className="text-center">
            <p className="text-sm text-gray-500 uppercase tracking-wide">
              Số Câu Đúng
            </p>
            <p className="text-4xl font-bold text-green-500">
              {result.correctCount}
              <span className="text-xl text-gray-400">
                /{result.totalQuestions}
              </span>
            </p>
          </div>
        </div>
        <Link
          to="/"
          className="inline-block bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-6 rounded transition"
        >
          Về Trang Chủ
        </Link>
      </div>

      {/* ========================================== */}
      {/* 2. KHỐI ĐÁNH GIÁ (MỚI THÊM VÀO ĐÂY) */}
      {/* ========================================== */}
      <div className="bg-white p-8 rounded-lg shadow border border-yellow-100 mb-8">
        <h2 className="text-2xl font-bold mb-4 border-b pb-2 text-gray-800">
          Bạn thấy đề thi này thế nào?
        </h2>

        {isReviewed ? (
          <div className="bg-green-50 text-green-700 p-4 rounded text-center font-semibold">
            🎉 Cảm ơn bạn đã để lại đánh giá!
          </div>
        ) : (
          <form onSubmit={handleSubmitReview}>
            <div className="mb-4 flex items-center gap-4">
              <label className="font-semibold text-gray-700">Chấm điểm:</label>
              <select
                value={rating}
                onChange={(e) => setRating(Number(e.target.value))}
                className="border p-2 rounded focus:ring-2 focus:ring-blue-500 bg-gray-50"
              >
                <option value="5">⭐⭐⭐⭐⭐ (Tuyệt vời)</option>
                <option value="4">⭐⭐⭐⭐ (Rất tốt)</option>
                <option value="3">⭐⭐⭐ (Bình thường)</option>
                <option value="2">⭐⭐ (Hơi tệ)</option>
                <option value="1">⭐ (Quá tệ)</option>
              </select>
            </div>
            <textarea
              required
              placeholder="Chia sẻ trải nghiệm của bạn sau khi làm bài (đề khó, dễ, hay bị lỗi gì không?)..."
              className="w-full border rounded p-3 mb-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows="3"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
            ></textarea>
            <button
              type="submit"
              disabled={submittingReview}
              className={`px-6 py-2 rounded text-white font-semibold transition ${submittingReview ? "bg-gray-400" : "bg-blue-600 hover:bg-blue-700"}`}
            >
              {submittingReview ? "Đang gửi..." : "Gửi đánh giá"}
            </button>
          </form>
        )}
      </div>

      {/* 3. KHỐI CHI TIẾT ĐÁP ÁN (Giữ nguyên của bạn) */}
      <div className="bg-white p-8 rounded-lg shadow border border-gray-100">
        <h2 className="text-2xl font-bold mb-6 border-b pb-2">
          Chi tiết bài làm
        </h2>
        <div className="space-y-6">
          {quiz.questions.map((q, index) => {
            const answerDetail = result.userAnswers.find(
              (a) => a.questionId === q._id,
            );
            const selectedOpt = answerDetail
              ? answerDetail.selectedOption
              : null;
            const isCorrect = answerDetail ? answerDetail.isCorrect : false;

            return (
              <div
                key={q._id}
                className={`p-4 rounded-lg border ${isCorrect ? "bg-green-50 border-green-200" : "bg-red-50 border-red-200"}`}
              >
                <h3 className="font-semibold text-gray-800 mb-3">
                  Câu {index + 1}: {q.questionText}
                  <span
                    className={`ml-2 text-sm font-bold ${isCorrect ? "text-green-600" : "text-red-600"}`}
                  >
                    {isCorrect ? "✓ Đúng" : "✗ Sai"}
                  </span>
                </h3>
                <div className="space-y-2">
                  {q.options.map((opt, optIndex) => {
                    let optClass = "p-2 rounded border text-gray-700 bg-white";
                    if (selectedOpt === optIndex) {
                      optClass = isCorrect
                        ? "p-2 rounded border bg-green-500 text-white font-semibold border-green-600"
                        : "p-2 rounded border bg-red-500 text-white font-semibold border-red-600";
                    }
                    return (
                      <div key={optIndex} className={optClass}>
                        {String.fromCharCode(65 + optIndex)}. {opt}
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default QuizResult;
