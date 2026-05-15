import { useState } from "react";
import { useNavigate } from "react-router-dom";
import quizApi from "../../services/quizApi";

const CreateQuiz = () => {
  const navigate = useNavigate();

  // STATE: Đầy đủ các thuộc tính của đề thi
  const [formData, setFormData] = useState({
    title: "",
    timeLimit: 15,
    attemptsAllowed: 1,
    isPublic: false,
    shuffleQuestions: false,
    shuffleOptions: false,
  });

  const [previewQuestions, setPreviewQuestions] = useState([]);

  const [isLoadingPreview, setIsLoadingPreview] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  // 1. Xử lý tự động parse file khi vừa chọn xong
  const handleFileChange = async (e) => {
    const selectedFile = e.target.files[0];
    if (!selectedFile) return;

    setPreviewQuestions([]);
    setIsLoadingPreview(true);

    try {
      const form = new FormData();
      form.append("file", selectedFile);

      const res = await quizApi.parseFile(form);
      setPreviewQuestions(res.questions);
    } catch (error) {
      alert(
        error.response?.data?.message ||
          "Lỗi khi đọc file. Vui lòng kiểm tra lại định dạng.",
      );
      e.target.value = null;
    } finally {
      setIsLoadingPreview(false);
    }
  };

  // 2. CÁC HÀM CHỈNH SỬA TRỰC TIẾP TRÊN BẢN PREVIEW
  const handleQuestionChange = (index, field, value) => {
    const newQuestions = [...previewQuestions];
    newQuestions[index][field] = value;
    setPreviewQuestions(newQuestions);
  };

  const handleOptionChange = (qIndex, optIndex, value) => {
    const newQuestions = [...previewQuestions];
    newQuestions[qIndex].options[optIndex] = value;
    setPreviewQuestions(newQuestions);
  };

  const removeQuestion = (index) => {
    if (window.confirm("Bạn có chắc chắn muốn xóa câu hỏi này khỏi đề thi?")) {
      setPreviewQuestions(previewQuestions.filter((_, i) => i !== index));
    }
  };

  // 3. Xử lý LƯU ĐỀ THI
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (previewQuestions.length === 0) {
      return alert("File trống hoặc chưa có câu hỏi nào!");
    }

    setIsSaving(true);
    try {
      await quizApi.createQuizManual({
        ...formData,
        questions: previewQuestions,
      });
      alert("Tạo đề thi thành công!");
      navigate("/my-quizzes");
    } catch {
      alert("Lỗi khi lưu đề thi");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto mt-8 pb-20 px-4">
      <h2 className="text-3xl font-bold text-gray-800 mb-6">
        Tạo Đề Thi Bằng File
      </h2>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* ================= CỘT TRÁI: FORM NHẬP LIỆU ================= */}
        <div className="lg:col-span-4 space-y-6">
          <div className="bg-blue-50 p-4 rounded border border-blue-200 text-sm text-blue-800 shadow-sm">
            <strong>💡 Hướng dẫn Import file:</strong>
            <ul className="list-disc ml-5 mt-2 space-y-1">
              <li>Hỗ trợ: .xlsx, .xls, .docx, .txt</li>
              <li>Excel: Cột A-D là đáp án, cột "Đáp án" ghi A, B, C, D.</li>
              <li>
                Word/Txt: Câu hỏi bắt đầu bằng "Câu 1:", đáp án đúng đánh dấu *
                ở đầu.
              </li>
            </ul>
          </div>

          <form
            onSubmit={handleSubmit}
            className="bg-white p-6 rounded-lg shadow-md border border-gray-100 sticky top-4"
          >
            {/* Tên đề thi */}
            <div className="mb-4">
              <label className="block text-sm font-bold mb-2 text-gray-700">
                Tên Đề Thi
              </label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
                className="w-full border p-2 rounded focus:ring-2 focus:ring-blue-500"
                placeholder="VD: Kiểm tra giữa kỳ..."
              />
            </div>

            {/* Thời gian & Số lần làm */}
            <div className="flex gap-4 mb-4">
              <div className="w-1/2">
                <label className="block text-sm font-bold mb-2 text-gray-700">
                  Thời gian (phút)
                </label>
                <input
                  type="number"
                  required
                  value={formData.timeLimit}
                  onChange={(e) =>
                    setFormData({ ...formData, timeLimit: e.target.value })
                  }
                  className="w-full border p-2 rounded focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="w-1/2">
                <label className="block text-sm font-bold mb-2 text-gray-700">
                  Số lần làm (0 = vô hạn)
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
                  className="w-full border p-2 rounded focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            {/* CỤM CHECKBOX: Công khai, Đảo câu, Đảo đáp án */}
            <div className="mb-6 space-y-3 p-4 bg-gray-50 rounded-lg border border-gray-200">
              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.isPublic}
                  onChange={(e) =>
                    setFormData({ ...formData, isPublic: e.target.checked })
                  }
                  className="w-5 h-5 text-blue-600 rounded mr-3 cursor-pointer"
                />
                <span className="font-semibold text-gray-800 text-sm">
                  Công khai đề thi (Mọi người có thể làm)
                </span>
              </label>

              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.shuffleQuestions}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      shuffleQuestions: e.target.checked,
                    })
                  }
                  className="w-5 h-5 text-blue-600 rounded mr-3 cursor-pointer"
                />
                <span className="font-semibold text-gray-800 text-sm">
                  Đảo vị trí câu hỏi khi thi
                </span>
              </label>

              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.shuffleOptions}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      shuffleOptions: e.target.checked,
                    })
                  }
                  className="w-5 h-5 text-blue-600 rounded mr-3 cursor-pointer"
                />
                <span className="font-semibold text-gray-800 text-sm">
                  Đảo vị trí các đáp án (A, B, C, D)
                </span>
              </label>
            </div>

            {/* Tải file */}
            <div className="mb-8">
              <label className="block text-sm font-bold mb-2 text-gray-700">
                Tải lên File Đề Thi
              </label>
              <input
                type="file"
                onChange={handleFileChange}
                accept=".xlsx, .xls, .docx, .txt"
                className="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 cursor-pointer border p-2 rounded"
              />
            </div>

            {/* Nút Submit */}
            <button
              type="submit"
              disabled={
                isSaving || previewQuestions.length === 0 || isLoadingPreview
              }
              className={`w-full font-bold py-3 rounded transition shadow-md ${isSaving || previewQuestions.length === 0 || isLoadingPreview ? "bg-gray-300 text-gray-500 cursor-not-allowed" : "bg-green-600 hover:bg-green-700 text-white transform hover:-translate-y-1"}`}
            >
              {isSaving ? "Đang lưu..." : "✅ Lưu & Xuất Bản Đề Thi"}
            </button>
          </form>
        </div>

        {/* ================= CỘT PHẢI: XEM TRƯỚC VÀ CHỈNH SỬA ================= */}
        <div className="lg:col-span-8">
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-100 min-h-[600px]">
            <div className="flex justify-between items-center border-b pb-4 mb-6">
              <h3 className="text-2xl font-bold text-gray-800">
                Bản xem trước & Chỉnh sửa
              </h3>
              {previewQuestions.length > 0 && (
                <span className="bg-blue-100 text-blue-800 text-sm font-bold px-3 py-1 rounded-full">
                  Tổng: {previewQuestions.length} câu hỏi
                </span>
              )}
            </div>

            {isLoadingPreview ? (
              <div className="flex flex-col items-center justify-center h-64 text-blue-500 animate-pulse">
                <span className="text-5xl mb-4">⚙️</span>
                <p className="font-semibold text-lg">
                  Đang đọc và phân tích file...
                </p>
              </div>
            ) : previewQuestions.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-64 text-gray-400 border-2 border-dashed border-gray-200 rounded-lg bg-gray-50">
                <span className="text-5xl mb-3">📄</span>
                <p className="text-lg">
                  Tải file lên để xem và chỉnh sửa câu hỏi tại đây
                </p>
              </div>
            ) : (
              <div className="space-y-6">
                {previewQuestions.map((q, index) => (
                  <div
                    key={index}
                    className="p-5 bg-gray-50 rounded-lg border border-gray-200 shadow-sm relative hover:shadow-md transition"
                  >
                    {/* Nút xóa câu hỏi */}
                    <button
                      type="button"
                      onClick={() => removeQuestion(index)}
                      className="absolute top-4 right-4 text-red-400 hover:text-red-600 hover:bg-red-50 p-1 rounded transition"
                      title="Xóa câu này"
                    >
                      ❌ Xóa
                    </button>

                    {/* Sửa text câu hỏi */}
                    <div className="mb-4 pr-12">
                      <label className="font-bold text-gray-800 mb-1 block">
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
                        className="w-full border border-gray-300 p-2 rounded focus:ring-2 focus:ring-blue-500 focus:outline-none bg-white"
                        rows="2"
                      />
                    </div>

                    {/* Sửa text đáp án & chọn lại đáp án đúng */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                      {q.options.map((opt, optIdx) => (
                        <div
                          key={optIdx}
                          className={`flex items-center p-2 rounded border transition-colors ${q.correctAnswer === optIdx ? "bg-green-100 border-green-400" : "bg-white border-gray-300 hover:border-gray-400"}`}
                        >
                          {/* Nút chọn đáp án đúng */}
                          <input
                            type="radio"
                            name={`correct-${index}`}
                            checked={q.correctAnswer === optIdx}
                            onChange={() =>
                              handleQuestionChange(
                                index,
                                "correctAnswer",
                                optIdx,
                              )
                            }
                            className="w-5 h-5 cursor-pointer text-green-600 focus:ring-green-500"
                            title="Đánh dấu là đáp án đúng"
                          />
                          {/* Sửa chữ của đáp án */}
                          <input
                            type="text"
                            value={opt}
                            onChange={(e) =>
                              handleOptionChange(index, optIdx, e.target.value)
                            }
                            className={`w-full bg-transparent border-none focus:ring-0 ml-2 p-1 ${q.correctAnswer === optIdx ? "font-bold text-green-900" : "text-gray-700"}`}
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

export default CreateQuiz;
