// src/pages/User/GenerateQuizFromAI.jsx
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import aiApi from "../../services/aiApi";
import quizApi from "../../services/quizApi";

const GenerateQuizFromAI = () => {
  const navigate = useNavigate();

  // State chế độ nhập: "topic" hoặc "file"
  const [activeTab, setActiveTab] = useState("topic");

  // State cho AI
  const [topic, setTopic] = useState("");
  const [file, setFile] = useState(null);
  const [numQuestions, setNumQuestions] = useState(10);
  const [isLoadingAI, setIsLoadingAI] = useState(false);

  // State quản lý tổng điểm muốn chia
  const [totalScore, setTotalScore] = useState(10);

  // State lưu kết quả AI trả về để review
  const [previewQuestions, setPreviewQuestions] = useState([]);

  // State cấu hình đề thi chuẩn bị lưu
  const [formData, setFormData] = useState({
    title: "",
    timeLimit: 15,
    attemptsAllowed: 1,
    isPublic: false,
    shuffleQuestions: false,
    shuffleAnswers: false,
  });
  const [isSaving, setIsSaving] = useState(false);

  // 1. GỌI AI TẠO CÂU HỎI
  const handleGenerateAI = async (e) => {
    e.preventDefault();
    setIsLoadingAI(true);
    setPreviewQuestions([]); // Reset màn hình review

    try {
      let res;
      if (activeTab === "topic") {
        if (!topic.trim()) return alert("Vui lòng nhập chủ đề!");
        res = await aiApi.generateFromTopic({ topic, numQuestions });
      } else {
        if (!file) return alert("Vui lòng chọn file tài liệu!");
        if (file.size > 5 * 1024 * 1024)
          return alert("File không được vượt quá 5MB!");

        const data = new FormData();
        data.append("file", file);
        data.append("numQuestions", numQuestions);
        res = await aiApi.generateFromFile(data);
      }

      setPreviewQuestions(res.questions);
      // Tự động gán tiêu đề gợi ý
      setFormData((prev) => ({
        ...prev,
        title:
          activeTab === "topic"
            ? `Đề thi AI: ${topic}`
            : `Đề thi AI từ tài liệu`,
      }));
    } catch (error) {
      alert(
        error.response?.data?.message || "Lỗi khi gọi AI. Vui lòng thử lại!",
      );
    } finally {
      setIsLoadingAI(false);
    }
  };

  // 2. CÁC HÀM CHỈNH SỬA PREVIEW
  const handleQuestionChange = (index, field, value) => {
    const newQuestions = [...previewQuestions];
    newQuestions[index] = { ...newQuestions[index], [field]: value };
    setPreviewQuestions(newQuestions);
  };

  const handleOptionChange = (qIndex, optIndex, value) => {
    const newQuestions = [...previewQuestions];
    const newOptions = [...newQuestions[qIndex].options];
    newOptions[optIndex] = value;
    newQuestions[qIndex] = { ...newQuestions[qIndex], options: newOptions };
    setPreviewQuestions(newQuestions);
  };

  const removeQuestion = (index) => {
    if (window.confirm("Xóa câu hỏi này?")) {
      setPreviewQuestions(previewQuestions.filter((_, i) => i !== index));
    }
  };

  // Hàm xử lý chia đều điểm
  const handleDividePoints = () => {
    if (previewQuestions.length === 0) return;

    // Tính toán điểm mỗi câu (Làm tròn 2 chữ số thập phân)
    const pointsPerQuestion = Number(
      (totalScore / previewQuestions.length).toFixed(2),
    );

    const newQuestions = previewQuestions.map((q) => ({
      ...q,
      points: pointsPerQuestion,
    }));

    setPreviewQuestions(newQuestions);
    alert(`✅ Đã chia đều ${pointsPerQuestion} điểm cho mỗi câu!`);
  };

  // 3. LƯU ĐỀ THI
  const handleSaveQuiz = async (e) => {
    e.preventDefault();
    if (previewQuestions.length === 0)
      return alert("Chưa có câu hỏi nào để lưu!");

    setIsSaving(true);
    try {
      await quizApi.createQuizManual({
        ...formData,
        questions: previewQuestions,
      });
      alert("Lưu đề thi AI thành công!");
      navigate("/my-quizzes");
    } catch {
      alert("Lỗi khi lưu đề thi");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto mt-8 pb-20 px-4">
      <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center gap-3">
        <span className="text-4xl">✨</span> Tạo Đề Thi Với Trợ Lý AI
      </h2>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* ================= CỘT TRÁI: ĐIỀU KHIỂN AI & CẤU HÌNH ================= */}
        <div className="lg:col-span-4 space-y-6">
          {/* KHỐI 1: GỌI AI */}
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-indigo-100">
            <h3 className="font-bold text-lg text-indigo-800 mb-4 border-b pb-2">
              1. Cấp dữ liệu cho AI
            </h3>

            {/* Tabs */}
            <div className="flex bg-gray-100 rounded-xl p-1 mb-4">
              <button
                onClick={() => setActiveTab("topic")}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition ${
                  activeTab === "topic"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-indigo-500"
                }`}
              >
                📝 Nhập Chủ Đề
              </button>
              <button
                onClick={() => setActiveTab("file")}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition ${
                  activeTab === "file"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-indigo-500"
                }`}
              >
                📄 Upload Tài Liệu
              </button>
            </div>

            <form onSubmit={handleGenerateAI} className="space-y-4">
              {activeTab === "topic" ? (
                <div>
                  <label className="block text-sm font-bold mb-2 text-gray-700">
                    Chủ đề bài thi
                  </label>
                  <input
                    type="text"
                    required
                    value={topic}
                    onChange={(e) => setTopic(e.target.value)}
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none transition"
                    placeholder="VD: Lịch sử Việt Nam thế kỷ 20..."
                  />
                </div>
              ) : (
                <div>
                  <div className="flex justify-between items-center mb-2">
                    <label className="block text-sm font-bold text-gray-700">
                      File tài liệu (.pdf, .docx)
                    </label>
                    <span className="text-xs font-medium text-red-500 bg-red-50 px-2 py-1 rounded">
                      Tối đa 5MB
                    </span>
                  </div>
                  <input
                    type="file"
                    required
                    accept=".pdf, .docx"
                    onChange={(e) => setFile(e.target.files[0])}
                    className="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100 cursor-pointer border border-gray-200 p-2 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition bg-gray-50"
                  />
                </div>
              )}

              <div>
                <label className="block text-sm font-bold mb-2 text-gray-700">
                  Số lượng câu hỏi (Max: 100)
                </label>
                <input
                  type="number"
                  min="1"
                  max="100"
                  required
                  value={numQuestions}
                  onChange={(e) => setNumQuestions(e.target.value)}
                  className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none transition"
                />
              </div>

              <button
                type="submit"
                disabled={isLoadingAI}
                className={`w-full font-bold py-3 rounded-xl transition shadow-sm ${
                  isLoadingAI
                    ? "bg-indigo-300 cursor-not-allowed text-white"
                    : "bg-indigo-600 hover:bg-indigo-700 text-white transform hover:-translate-y-0.5"
                }`}
              >
                {isLoadingAI
                  ? "🤖 AI đang suy nghĩ..."
                  : "✨ Bắt Đầu Tạo Bằng AI"}
              </button>
            </form>
          </div>

          {/* KHỐI 2: CẤU HÌNH ĐỀ THI (Chỉ hiện khi đã có câu hỏi) */}
          {previewQuestions.length > 0 && (
            <form
              onSubmit={handleSaveQuiz}
              className="bg-white p-6 rounded-2xl shadow-sm border border-green-100 sticky top-4 animate-fadeIn"
            >
              <h3 className="font-bold text-lg text-green-700 mb-4 border-b pb-2">
                2. Cấu hình & Lưu Đề Thi
              </h3>

              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-sm font-bold mb-1 text-gray-700">
                    Tên Đề Thi
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.title}
                    onChange={(e) =>
                      setFormData({ ...formData, title: e.target.value })
                    }
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-green-500 outline-none"
                  />
                </div>

                <div className="flex gap-4">
                  <div className="w-1/2">
                    <label className="block text-sm font-bold mb-1 text-gray-700">
                      Thời gian (phút)
                    </label>
                    <input
                      type="number"
                      required
                      value={formData.timeLimit}
                      onChange={(e) =>
                        setFormData({ ...formData, timeLimit: e.target.value })
                      }
                      className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-green-500 outline-none"
                    />
                  </div>
                  <div className="w-1/2">
                    <label className="block text-sm font-bold mb-1 text-gray-700">
                      Số lần thi
                    </label>
                    <input
                      type="number"
                      required
                      value={formData.attemptsAllowed}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          attemptsAllowed: e.target.value,
                        })
                      }
                      className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-green-500 outline-none"
                    />
                  </div>
                </div>

                <div className="space-y-3 p-4 bg-gray-50 rounded-xl border border-gray-100 text-sm mt-2">
                  <label className="flex items-center cursor-pointer font-semibold text-gray-700">
                    <input
                      type="checkbox"
                      checked={formData.isPublic}
                      onChange={(e) =>
                        setFormData({ ...formData, isPublic: e.target.checked })
                      }
                      className="w-5 h-5 accent-green-600 mr-3 cursor-pointer"
                    />
                    Công khai đề thi
                  </label>
                  <label className="flex items-center cursor-pointer font-semibold text-gray-700">
                    <input
                      type="checkbox"
                      checked={formData.shuffleQuestions}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          shuffleQuestions: e.target.checked,
                        })
                      }
                      className="w-5 h-5 accent-green-600 mr-3 cursor-pointer"
                    />
                    Đảo câu hỏi
                  </label>
                  <label className="flex items-center cursor-pointer font-semibold text-gray-700">
                    <input
                      type="checkbox"
                      checked={formData.shuffleAnswers}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          shuffleAnswers: e.target.checked,
                        })
                      }
                      className="w-5 h-5 accent-green-600 mr-3 cursor-pointer"
                    />
                    Đảo đáp án
                  </label>
                </div>
              </div>

              <button
                type="submit"
                disabled={isSaving}
                className="w-full font-bold py-3 rounded-xl transition shadow-sm bg-green-600 hover:bg-green-700 text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSaving ? "Đang lưu..." : "✅ Lưu & Xuất Bản"}
              </button>
            </form>
          )}
        </div>

        {/* ================= CỘT PHẢI: XEM TRƯỚC VÀ CHỈNH SỬA ================= */}
        <div className="lg:col-span-8">
          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 min-h-[600px]">
            <div className="flex justify-between items-center border-b border-gray-100 pb-4 mb-6">
              <h3 className="text-2xl font-bold text-gray-800">
                Bản Xem Trước Của AI
              </h3>
              {previewQuestions.length > 0 && (
                <span className="bg-indigo-50 text-indigo-700 text-sm font-bold px-4 py-1.5 rounded-full">
                  Tổng: {previewQuestions.length} câu hỏi
                </span>
              )}
            </div>

            {isLoadingAI ? (
              <div className="flex flex-col items-center justify-center h-80 text-indigo-500 animate-pulse">
                <span className="text-6xl mb-4">🔮</span>
                <p className="font-semibold text-xl mb-2">
                  AI đang phân tích và soạn câu hỏi...
                </p>
                <p className="text-gray-500">
                  Việc này có thể mất từ 10 - 30 giây tùy số lượng câu.
                </p>
              </div>
            ) : previewQuestions.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-80 text-gray-400 border-2 border-dashed border-gray-200 rounded-2xl bg-gray-50">
                <span className="text-5xl mb-3">🤖</span>
                <p className="text-lg">
                  Nhập lệnh ở cột trái để AI bắt đầu làm việc
                </p>
              </div>
            ) : (
              <div className="space-y-6 animate-fadeIn">
                {/* 👇 THANH CHIA ĐIỂM XUẤT HIỆN Ở ĐÂY 👇 */}
                <div className="bg-indigo-50 border border-indigo-200 p-4 rounded-2xl flex flex-wrap items-center gap-4 shadow-sm">
                  <span className="text-2xl">🧮</span>
                  <label className="font-bold text-indigo-900">
                    Tổng điểm bài thi:
                  </label>
                  <input
                    type="number"
                    min="1"
                    value={totalScore}
                    onChange={(e) => setTotalScore(Number(e.target.value))}
                    className="w-24 border-gray-300 p-2 rounded-xl text-center font-bold text-indigo-700 focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                  <button
                    type="button"
                    onClick={handleDividePoints}
                    className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2 rounded-xl font-bold transition shadow-sm"
                  >
                    ➗ Chia đều cho {previewQuestions.length} câu
                  </button>
                  <span className="text-sm text-indigo-600 italic ml-auto hidden md:block">
                    (Có thể sửa điểm từng câu ở bên dưới)
                  </span>
                </div>

                {previewQuestions.map((q, index) => (
                  <div
                    key={index}
                    className="p-6 bg-white rounded-2xl border border-gray-200 shadow-sm relative hover:shadow-md transition-shadow"
                  >
                    <button
                      type="button"
                      onClick={() => removeQuestion(index)}
                      className="absolute top-4 right-4 text-red-400 hover:text-red-600 bg-red-50 hover:bg-red-100 px-3 py-1 rounded-lg font-bold text-sm transition-colors"
                    >
                      🗑️ Xóa
                    </button>

                    {/* 👇 BỔ SUNG Ô NHẬP ĐIỂM Ở ĐÂY 👇 */}
                    <div className="mb-5 pr-16 flex flex-col md:flex-row gap-4">
                      <div className="flex-1">
                        <label className="font-bold text-gray-800 mb-2 block">
                          Câu {index + 1}:
                        </label>
                        <textarea
                          value={q.questionText}
                          onChange={(e) =>
                            handleQuestionChange(
                              index,
                              "questionText",
                              e.target.value,
                            )
                          }
                          className="w-full bg-gray-50 border border-gray-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition"
                          rows="2"
                        />
                      </div>

                      <div className="w-full md:w-28 shrink-0">
                        <label className="block text-sm font-bold mb-2 text-gray-800 text-center">
                          Điểm số
                        </label>
                        <input
                          type="number"
                          min="0"
                          step="any"
                          value={q.points !== undefined ? q.points : 10}
                          onChange={(e) =>
                            handleQuestionChange(
                              index,
                              "points",
                              Number(e.target.value) || 0,
                            )
                          }
                          className="w-full bg-indigo-50 border border-indigo-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 text-center font-black text-indigo-700 outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                      {q.options.map((opt, optIdx) => (
                        <div
                          key={optIdx}
                          className={`flex items-center p-3 rounded-xl border transition-colors ${
                            q.correctAnswer === optIdx
                              ? "bg-green-50 border-green-400"
                              : "bg-white border-gray-200 hover:border-indigo-200"
                          }`}
                        >
                          <input
                            type="radio"
                            name={`ai-correct-${index}`}
                            checked={q.correctAnswer === optIdx}
                            onChange={() =>
                              handleQuestionChange(
                                index,
                                "correctAnswer",
                                optIdx,
                              )
                            }
                            className="w-5 h-5 cursor-pointer accent-green-600 shrink-0"
                            title="Đánh dấu là đáp án đúng"
                          />
                          <input
                            type="text"
                            value={opt}
                            onChange={(e) =>
                              handleOptionChange(index, optIdx, e.target.value)
                            }
                            className={`w-full bg-transparent border-none outline-none ml-3 ${
                              q.correctAnswer === optIdx
                                ? "font-bold text-green-900"
                                : "text-gray-700 font-medium"
                            }`}
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default GenerateQuizFromAI;
