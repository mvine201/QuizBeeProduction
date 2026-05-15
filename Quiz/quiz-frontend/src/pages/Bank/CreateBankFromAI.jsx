import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import aiApi from "../../services/aiApi";
import bankApi from "../../services/bankApi";

const CreateBankFromAI = () => {
  const navigate = useNavigate();

  // State chế độ nhập
  const [activeTab, setActiveTab] = useState("topic");

  // State cho AI
  const [topic, setTopic] = useState("");
  const [file, setFile] = useState(null);
  const [numQuestions, setNumQuestions] = useState(10);
  const [isLoadingAI, setIsLoadingAI] = useState(false);

  // State review và lưu trữ
  const [previewQuestions, setPreviewQuestions] = useState([]);
  const [bankInfo, setBankInfo] = useState({ title: "", description: "" });
  const [isSaving, setIsSaving] = useState(false);

  // 1. GỌI AI
  const handleGenerateAI = async (e) => {
    e.preventDefault();
    setIsLoadingAI(true);
    setPreviewQuestions([]);

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
      // Gợi ý tên Ngân hàng
      setBankInfo({
        title:
          activeTab === "topic"
            ? `Ngân hàng AI: ${topic}`
            : `Ngân hàng AI từ tài liệu`,
        description: `Tạo tự động bởi AI với ${numQuestions} câu hỏi.`,
      });
    } catch (error) {
      alert(error.response?.data?.message || "Lỗi AI. Vui lòng thử lại!");
    } finally {
      setIsLoadingAI(false);
    }
  };

  // 2. CHỈNH SỬA PREVIEW (Đã fix lỗi React Mutation)
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
    if (window.confirm("Xóa câu hỏi này khỏi danh sách?")) {
      setPreviewQuestions(previewQuestions.filter((_, i) => i !== index));
    }
  };

  // 3. LƯU VÀO NGÂN HÀNG CÂU HỎI
  const handleSaveBank = async (e) => {
    e.preventDefault();
    if (previewQuestions.length === 0) return alert("Chưa có câu hỏi nào!");

    setIsSaving(true);
    try {
      await bankApi.createBank({
        ...bankInfo,
        questions: previewQuestions,
      });
      alert("🎉 Lưu Ngân hàng câu hỏi thành công!");
      navigate("/banks"); // Trở về danh sách ngân hàng
    } catch {
      alert("Lỗi khi lưu Ngân hàng");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto mt-8 pb-20 px-4">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
          <span className="text-4xl">🏦</span> Tạo Ngân Hàng Bằng AI
        </h2>
        <Link
          to="/banks"
          className="text-indigo-600 font-semibold hover:underline"
        >
          ⬅️ Quay lại Kho Ngân Hàng
        </Link>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* ================= CỘT TRÁI: GỌI AI & LƯU NGÂN HÀNG ================= */}
        <div className="lg:col-span-4 space-y-6">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-indigo-100">
            <h3 className="font-bold text-lg text-indigo-800 mb-4 border-b pb-2">
              1. Lệnh cho AI
            </h3>

            <div className="flex bg-gray-100 rounded-xl p-1 mb-4">
              <button
                onClick={() => setActiveTab("topic")}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition ${
                  activeTab === "topic"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-indigo-500"
                }`}
              >
                📝 Chủ Đề
              </button>
              <button
                onClick={() => setActiveTab("file")}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition ${
                  activeTab === "file"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-indigo-500"
                }`}
              >
                📄 File (PDF/Doc)
              </button>
            </div>

            <form onSubmit={handleGenerateAI} className="space-y-4">
              {activeTab === "topic" ? (
                <div>
                  <label className="block text-sm font-bold mb-2 text-gray-700">
                    Chủ đề mong muốn
                  </label>
                  <input
                    type="text"
                    required
                    value={topic}
                    onChange={(e) => setTopic(e.target.value)}
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none transition"
                    placeholder="VD: Marketing căn bản..."
                  />
                </div>
              ) : (
                <div>
                  {/* 👇 Đã bổ sung giới hạn 5MB và UI mới 👇 */}
                  <div className="flex justify-between items-center mb-2">
                    <label className="block text-sm font-bold text-gray-700">
                      Tài liệu tham khảo
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
                  Số lượng câu (Max: 100)
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
                {isLoadingAI ? "🤖 Đang phân tích..." : "✨ Tạo Câu Hỏi"}
              </button>
            </form>
          </div>

          {previewQuestions.length > 0 && (
            <form
              onSubmit={handleSaveBank}
              className="bg-white p-6 rounded-2xl shadow-sm border border-green-100 sticky top-4 animate-fadeIn"
            >
              <h3 className="font-bold text-lg text-green-700 mb-4 border-b pb-2">
                2. Lưu Ngân Hàng
              </h3>
              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-sm font-bold mb-1 text-gray-700">
                    Tên Ngân Hàng
                  </label>
                  <input
                    type="text"
                    required
                    value={bankInfo.title}
                    onChange={(e) =>
                      setBankInfo({ ...bankInfo, title: e.target.value })
                    }
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-green-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-sm font-bold mb-1 text-gray-700">
                    Mô tả thêm
                  </label>
                  <textarea
                    value={bankInfo.description}
                    onChange={(e) =>
                      setBankInfo({ ...bankInfo, description: e.target.value })
                    }
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-green-500 outline-none"
                    rows="3"
                  />
                </div>
              </div>
              <button
                type="submit"
                disabled={isSaving}
                className="w-full font-bold py-3 rounded-xl transition shadow-sm bg-green-600 hover:bg-green-700 text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSaving ? "Đang lưu..." : "💾 Lưu Vào Kho"}
              </button>
            </form>
          )}
        </div>

        {/* ================= CỘT PHẢI: REVIEW ================= */}
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
              <div className="text-center py-20 text-indigo-500 animate-pulse font-semibold">
                <span className="text-6xl block mb-4">⚙️</span>
                Đang tổng hợp kiến thức... Xin chờ giây lát!
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
                <div className="bg-yellow-50 text-yellow-800 p-4 rounded-xl text-sm border border-yellow-200 shadow-sm">
                  ⚠️ <strong>Lưu ý:</strong> Hãy kiểm tra lại đáp án và{" "}
                  <strong>trọng số điểm</strong> trước khi lưu vào ngân hàng.
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

                    {/* 👇 Đã bổ sung ô nhập điểm ở đây 👇 */}
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
                          title="Trọng số điểm của câu này"
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
                            name={`bank-ai-correct-${index}`}
                            checked={q.correctAnswer === optIdx}
                            onChange={() =>
                              handleQuestionChange(
                                index,
                                "correctAnswer",
                                optIdx,
                              )
                            }
                            className="w-5 h-5 cursor-pointer accent-green-600 shrink-0"
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

export default CreateBankFromAI;
