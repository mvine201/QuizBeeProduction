import { useState } from "react";
import { useNavigate } from "react-router-dom";
import bankApi from "../../services/bankApi";
import quizApi from "../../services/quizApi";

const CreateQuestionBank = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ title: "", description: "" });
  const [previewQuestions, setPreviewQuestions] = useState([]);
  const [isLoadingPreview, setIsLoadingPreview] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  // State quản lý tổng điểm muốn chia
  const [totalScore, setTotalScore] = useState(10);

  const handleFileChange = async (e) => {
    const selectedFile = e.target.files[0];
    if (!selectedFile) return;

    // Chặn file lớn hơn 5MB
    if (selectedFile.size > 5 * 1024 * 1024) {
      alert("File không được vượt quá 5MB!");
      e.target.value = null; // Reset ô input
      return;
    }

    setPreviewQuestions([]);
    setIsLoadingPreview(true);

    try {
      const form = new FormData();
      form.append("file", selectedFile);
      const res = await quizApi.parseFile(form);
      setPreviewQuestions(res.questions);
    } catch {
      alert("Lỗi khi đọc file. Vui lòng kiểm tra lại định dạng.");
      e.target.value = null;
    } finally {
      setIsLoadingPreview(false);
    }
  };

  const removeQuestion = (index) => {
    if (window.confirm("Xóa câu này khỏi danh sách import?")) {
      setPreviewQuestions(previewQuestions.filter((_, i) => i !== index));
    }
  };

  // Sửa lỗi State Mutation và cho phép chỉnh sửa nội dung sau khi import
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

  // Hàm xử lý chia đều điểm
  const handleDividePoints = () => {
    if (previewQuestions.length === 0) return;

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

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (previewQuestions.length === 0) {
      return alert("Ngân hàng phải có ít nhất 1 câu hỏi!");
    }

    setIsSaving(true);
    try {
      await bankApi.createBank({
        ...formData,
        questions: previewQuestions,
      });
      alert("Tạo Ngân hàng câu hỏi thành công!");
      navigate("/banks");
    } catch {
      alert("Lỗi khi lưu Ngân hàng");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto mt-8 pb-20 px-4">
      <h2 className="text-3xl font-bold text-gray-800 mb-6">
        Tạo Ngân Hàng Câu Hỏi Mới
      </h2>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Form nhập liệu (Cột trái) */}
        <div className="lg:col-span-4 space-y-6">
          <form
            onSubmit={handleSubmit}
            className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 sticky top-4"
          >
            <div className="mb-4">
              <label className="block text-sm font-bold mb-2 text-gray-700">
                Tên Ngân Hàng
              </label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
                className="w-full bg-gray-50 border border-gray-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition"
                placeholder="VD: Ngân hàng Toán Đại Số"
              />
            </div>

            <div className="mb-4">
              <label className="block text-sm font-bold mb-2 text-gray-700">
                Mô tả
              </label>
              <textarea
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                className="w-full bg-gray-50 border border-gray-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition"
                rows="3"
                placeholder="Ghi chú về ngân hàng này..."
              ></textarea>
            </div>

            <div className="mb-6 p-4 bg-indigo-50 rounded-xl border border-indigo-100">
              <div className="flex justify-between items-center mb-3">
                <label className="block text-sm font-bold text-indigo-900">
                  Import File (Excel/Word/Txt)
                </label>
                <span className="text-xs font-medium text-red-500 bg-red-100 px-2 py-1 rounded">
                  Tối đa 5MB
                </span>
              </div>
              <input
                type="file"
                onChange={handleFileChange}
                accept=".xlsx, .xls, .docx, .txt"
                className="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-indigo-100 file:text-indigo-700 hover:file:bg-indigo-200 cursor-pointer bg-white border border-indigo-100 p-2 rounded-xl"
              />
            </div>

            <button
              type="submit"
              disabled={
                isSaving || previewQuestions.length === 0 || isLoadingPreview
              }
              className="w-full font-bold py-3 rounded-xl transition shadow-sm bg-indigo-600 hover:bg-indigo-700 text-white disabled:bg-gray-300 disabled:text-gray-500 disabled:cursor-not-allowed"
            >
              {isSaving ? "Đang lưu..." : "✅ Lưu Ngân Hàng"}
            </button>
          </form>
        </div>

        {/* Cột phải: Xem trước câu hỏi */}
        <div className="lg:col-span-8">
          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 min-h-[500px]">
            <h3 className="text-2xl font-bold text-gray-800 border-b pb-4 mb-6 flex justify-between items-center">
              <span>Danh sách câu hỏi</span>
              {previewQuestions.length > 0 && (
                <span className="bg-indigo-100 text-indigo-800 text-sm px-4 py-1 rounded-full">
                  {previewQuestions.length} câu
                </span>
              )}
            </h3>

            {isLoadingPreview && (
              <div className="text-center py-20 text-indigo-500 animate-pulse font-semibold">
                <span className="text-5xl block mb-4">⚙️</span>
                Đang đọc và phân tích file...
              </div>
            )}

            {!isLoadingPreview && previewQuestions.length === 0 && (
              <div className="text-center py-20 text-gray-400 border-2 border-dashed border-gray-200 rounded-2xl bg-gray-50">
                <span className="text-5xl block mb-4">📄</span>
                Vui lòng tải file lên để import câu hỏi vào ngân hàng.
              </div>
            )}

            {!isLoadingPreview && previewQuestions.length > 0 && (
              <div className="space-y-6 animate-fadeIn">
                {/* THANH CHIA ĐIỂM */}
                <div className="bg-indigo-50 border border-indigo-200 p-4 rounded-2xl flex flex-wrap items-center gap-4 shadow-sm">
                  <span className="text-2xl">🧮</span>
                  <label className="font-bold text-indigo-900">
                    Tổng điểm:
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
                    ➗ Chia đều điểm
                  </button>
                </div>

                {/* DANH SÁCH CÂU HỎI */}
                {previewQuestions.map((q, idx) => (
                  <div
                    key={idx}
                    className="p-6 bg-white rounded-2xl border border-gray-200 shadow-sm relative hover:shadow-md transition-shadow"
                  >
                    <button
                      type="button"
                      onClick={() => removeQuestion(idx)}
                      className="absolute top-4 right-4 text-red-400 hover:text-red-600 font-bold bg-red-50 hover:bg-red-100 px-3 py-1 rounded-lg text-sm transition-colors"
                    >
                      🗑️ Xóa
                    </button>

                    <div className="mb-5 pr-16 flex flex-col md:flex-row gap-4">
                      <div className="flex-1">
                        <label className="font-bold text-gray-800 mb-2 block">
                          Câu {idx + 1}:
                        </label>
                        <textarea
                          value={q.questionText}
                          onChange={(e) =>
                            handleQuestionChange(
                              idx,
                              "questionText",
                              e.target.value,
                            )
                          }
                          className="w-full bg-gray-50 border border-gray-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition"
                          rows="2"
                        />
                      </div>

                      {/* Ô nhập điểm cá nhân */}
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
                              idx,
                              "points",
                              Number(e.target.value) || 0,
                            )
                          }
                          className="w-full bg-indigo-50 border border-indigo-200 p-3 rounded-xl focus:ring-2 focus:ring-indigo-500 text-center font-black text-indigo-700 outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                      {q.options.map((opt, oIdx) => (
                        <div
                          key={oIdx}
                          className={`flex items-center p-3 rounded-xl border transition-colors ${
                            q.correctAnswer === oIdx
                              ? "bg-green-50 border-green-400"
                              : "bg-white border-gray-200 hover:border-indigo-200"
                          }`}
                        >
                          <input
                            type="radio"
                            name={`import-correct-${idx}`}
                            checked={q.correctAnswer === oIdx}
                            onChange={() =>
                              handleQuestionChange(idx, "correctAnswer", oIdx)
                            }
                            className="w-5 h-5 cursor-pointer accent-green-600 shrink-0"
                          />
                          <input
                            type="text"
                            value={opt}
                            onChange={(e) =>
                              handleOptionChange(idx, oIdx, e.target.value)
                            }
                            className={`w-full bg-transparent border-none outline-none ml-3 ${
                              q.correctAnswer === oIdx
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

export default CreateQuestionBank;
