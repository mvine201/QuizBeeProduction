import { useState } from "react";
import { useNavigate } from "react-router-dom";
import quizApi from "../../services/quizApi";

const CreateQuizManual = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [quizInfo, setQuizInfo] = useState({
    title: "",
    description: "",
    timeLimit: 15,
    attemptsAllowed: 0,
    isPublic: false,
    shuffleQuestions: false,
    shuffleAnswers: false,
  });

  const [questions, setQuestions] = useState([
    {
      questionText: "",
      options: ["", "", "", ""],
      correctAnswer: 0,
      points: 10, // Mặc định 10 điểm
    },
  ]);

  // State quản lý tổng điểm muốn chia
  const [totalScore, setTotalScore] = useState(10);

  // Thêm câu hỏi mới
  const addQuestion = () => {
    setQuestions([
      ...questions,
      {
        questionText: "",
        options: ["", "", "", ""],
        correctAnswer: 0,
        points: 10,
      },
    ]);
  };

  // Xóa câu hỏi
  const removeQuestion = (index) => {
    if (questions.length === 1) {
      alert("Đề thi phải có ít nhất 1 câu hỏi!");
      return;
    }
    setQuestions(questions.filter((_, i) => i !== index));
  };

  // Các hàm thay đổi dữ liệu
  const handleQuizChange = (e) => {
    const value =
      e.target.type === "checkbox" ? e.target.checked : e.target.value;
    setQuizInfo({ ...quizInfo, [e.target.name]: value });
  };

  const handleQuestionChange = (index, field, value) => {
    const newQuestions = [...questions];
    newQuestions[index] = { ...newQuestions[index], [field]: value };
    setQuestions(newQuestions);
  };

  const handleOptionChange = (qIndex, optIndex, value) => {
    const newQuestions = [...questions];
    const newOptions = [...newQuestions[qIndex].options];
    newOptions[optIndex] = value;
    newQuestions[qIndex] = { ...newQuestions[qIndex], options: newOptions };
    setQuestions(newQuestions);
  };

  // Hàm xử lý chia đều điểm
  const handleDividePoints = () => {
    if (questions.length === 0) return;

    // Tính toán điểm mỗi câu (Làm tròn 2 chữ số thập phân, VD: 0.25)
    const pointsPerQuestion = Number(
      (totalScore / questions.length).toFixed(2),
    );

    // Cập nhật lại toàn bộ mảng câu hỏi
    const newQuestions = questions.map((q) => ({
      ...q,
      points: pointsPerQuestion,
    }));

    setQuestions(newQuestions);
    alert(`✅ Đã chia đều ${pointsPerQuestion} điểm cho mỗi câu!`);
  };

  // Gửi dữ liệu tạo đề thi
  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await quizApi.createQuizManual({ ...quizInfo, questions });
      alert("Tạo đề thi thành công!");
      navigate("/my-quizzes");
    } catch (error) {
      alert(error.response?.data?.message || "Lỗi khi tạo đề thi");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-5xl mx-auto mt-8 pb-20">
      <h2 className="text-3xl font-bold text-gray-800 mb-8 border-b pb-4">
        Tạo Đề Thi Thủ Công
      </h2>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* KHỐI 1: THÔNG TIN CHUNG */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
          <h3 className="text-xl font-bold mb-4 text-blue-800">
            1. Thông tin chung
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-bold mb-1 text-gray-700">
                Tiêu đề đề thi
              </label>
              <input
                type="text"
                name="title"
                required
                value={quizInfo.title}
                onChange={handleQuizChange}
                className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-blue-500 outline-none"
                placeholder="VD: Kiểm tra 15 phút Toán Đại Số..."
              />
            </div>
            <div>
              <label className="block text-sm font-bold mb-1 text-gray-700">
                Thời gian (phút)
              </label>
              <input
                type="number"
                name="timeLimit"
                min="1"
                required
                value={quizInfo.timeLimit}
                onChange={handleQuizChange}
                className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-blue-500 outline-none"
              />
            </div>
            <div>
              <label className="block text-sm font-bold mb-1 text-gray-700">
                Số lần thi (0 = không giới hạn)
              </label>
              <input
                type="number"
                name="attemptsAllowed"
                min="0"
                required
                value={quizInfo.attemptsAllowed}
                onChange={handleQuizChange}
                className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-blue-500 outline-none"
              />
            </div>
          </div>

          {/* Cụm Checkbox */}
          <div className="mt-6 flex flex-wrap gap-4 p-4 bg-gray-50 rounded-xl border border-gray-100">
            <label className="flex items-center gap-2 cursor-pointer font-medium text-gray-700">
              <input
                type="checkbox"
                name="isPublic"
                checked={quizInfo.isPublic}
                onChange={handleQuizChange}
                className="w-5 h-5 accent-blue-600 cursor-pointer"
              />
              Công khai đề thi
            </label>
            <label className="flex items-center gap-2 cursor-pointer font-medium text-gray-700">
              <input
                type="checkbox"
                name="shuffleQuestions"
                checked={quizInfo.shuffleQuestions}
                onChange={handleQuizChange}
                className="w-5 h-5 accent-blue-600 cursor-pointer"
              />
              Đảo thứ tự câu hỏi
            </label>
            <label className="flex items-center gap-2 cursor-pointer font-medium text-gray-700">
              <input
                type="checkbox"
                name="shuffleAnswers"
                checked={quizInfo.shuffleAnswers}
                onChange={handleQuizChange}
                className="w-5 h-5 accent-blue-600 cursor-pointer"
              />
              Đảo vị trí đáp án (A,B,C,D)
            </label>
          </div>
        </div>

        {/* KHỐI 2: DANH SÁCH CÂU HỎI */}
        <div className="space-y-6">
          <h3 className="text-xl font-bold text-gray-800">
            2. Danh sách câu hỏi
          </h3>

          {/* THANH CÔNG CỤ CHIA ĐIỂM NHANH */}
          <div className="bg-blue-50 border border-blue-200 p-4 rounded-2xl flex flex-wrap items-center gap-4 mb-6 shadow-sm">
            <span className="text-2xl">🧮</span>
            <label className="font-bold text-blue-900">
              Tổng điểm bài thi:
            </label>
            <input
              type="number"
              min="1"
              value={totalScore}
              onChange={(e) => setTotalScore(Number(e.target.value))}
              className="w-24 border-gray-300 p-2 rounded-xl text-center font-bold text-blue-700 focus:ring-2 focus:ring-blue-500 outline-none"
            />
            <button
              type="button"
              onClick={handleDividePoints}
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-xl font-bold transition shadow-sm"
            >
              ➗ Chia đều cho {questions.length} câu
            </button>
            <span className="text-sm text-blue-600 italic ml-auto hidden md:block">
              (Có thể sửa điểm từng câu ở bên dưới)
            </span>
          </div>

          {/* VÒNG LẶP CÂU HỎI */}
          {questions.map((q, qIndex) => (
            <div
              key={qIndex}
              className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 relative hover:shadow-md transition-shadow"
            >
              <button
                type="button"
                onClick={() => removeQuestion(qIndex)}
                className="absolute top-4 right-4 text-red-500 hover:text-red-700 font-bold bg-red-50 hover:bg-red-100 px-3 py-1 rounded-lg transition-colors text-sm"
              >
                🗑️ Xóa câu
              </button>

              {/* HEADER TỪNG CÂU HỎI: Có ô nhập điểm */}
              <div className="mb-4 pr-24 flex flex-col md:flex-row gap-4">
                <div className="flex-1">
                  <label className="block text-sm font-bold mb-2 text-gray-800">
                    Câu hỏi {qIndex + 1}
                  </label>
                  <textarea
                    value={q.questionText}
                    onChange={(e) =>
                      handleQuestionChange(
                        qIndex,
                        "questionText",
                        e.target.value,
                      )
                    }
                    required
                    className="w-full bg-gray-50 border border-gray-200 p-3 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
                    rows="2"
                    placeholder="Nhập nội dung câu hỏi..."
                  ></textarea>
                </div>

                {/* Ô NHẬP ĐIỂM TỪNG CÂU */}
                <div className="w-full md:w-28 shrink-0">
                  <label className="block text-sm font-bold mb-2 text-gray-800 text-center">
                    Điểm số
                  </label>
                  <input
                    type="number"
                    min="0"
                    step="any" // Cho phép số thập phân
                    value={q.points !== undefined ? q.points : 10}
                    onChange={(e) =>
                      handleQuestionChange(
                        qIndex,
                        "points",
                        Number(e.target.value) || 0,
                      )
                    }
                    className="w-full bg-blue-50 border border-blue-200 p-3 rounded-xl focus:ring-2 focus:ring-blue-500 text-center font-black text-blue-700 outline-none"
                    title="Trọng số điểm của câu này"
                  />
                </div>
              </div>

              {/* KHỐI ĐÁP ÁN */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {q.options.map((opt, optIndex) => (
                  <div
                    key={optIndex}
                    className={`flex items-center gap-3 p-3 rounded-xl border transition-colors ${q.correctAnswer === optIndex ? "bg-green-50 border-green-400" : "bg-gray-50 border-gray-200"}`}
                  >
                    <input
                      type="radio"
                      name={`correct-${qIndex}`}
                      checked={q.correctAnswer === optIndex}
                      onChange={() =>
                        handleQuestionChange(qIndex, "correctAnswer", optIndex)
                      }
                      className="w-5 h-5 cursor-pointer accent-green-600 shrink-0"
                      title="Đánh dấu là đáp án đúng"
                    />
                    <input
                      type="text"
                      value={opt}
                      onChange={(e) =>
                        handleOptionChange(qIndex, optIndex, e.target.value)
                      }
                      required
                      className={`w-full bg-transparent border-none outline-none text-sm ${q.correctAnswer === optIndex ? "font-bold text-green-900" : "text-gray-700 font-medium"}`}
                      placeholder={`Đáp án ${String.fromCharCode(65 + optIndex)}`}
                    />
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* NÚT THAO TÁC CUỐI TRANG */}
        <div className="flex flex-col md:flex-row justify-between items-center bg-white p-5 rounded-2xl shadow-sm border border-gray-100 gap-4 sticky bottom-4 z-10">
          <button
            type="button"
            onClick={addQuestion}
            className="w-full md:w-auto bg-gray-100 text-gray-800 font-bold px-6 py-3 rounded-xl hover:bg-gray-200 transition-colors flex items-center justify-center gap-2"
          >
            <span>➕</span> Thêm câu hỏi
          </button>

          <button
            type="submit"
            disabled={loading}
            className="w-full md:w-auto bg-blue-600 text-white px-10 py-3 rounded-xl font-bold text-lg hover:bg-blue-700 transition shadow-md disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Đang xử lý..." : "Lưu & Xuất Bản Đề Thi"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateQuizManual;
