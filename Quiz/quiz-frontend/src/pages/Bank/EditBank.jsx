import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import bankApi from "../../services/bankApi";

const EditBank = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [bankInfo, setBankInfo] = useState({ title: "", description: "" });
  const [questions, setQuestions] = useState([]);

  // State quản lý mảng ID (index) các câu hỏi được tích chọn để xóa
  const [selectedQuestions, setSelectedQuestions] = useState([]);

  useEffect(() => {
    const fetchBank = async () => {
      try {
        const data = await bankApi.getBankById(id);
        setBankInfo({ title: data.title, description: data.description || "" });
        setQuestions(data.questions || []);
      } catch {
        alert("Không tải được ngân hàng câu hỏi!");
        navigate("/banks");
      } finally {
        setLoading(false);
      }
    };
    fetchBank();
  }, [id, navigate]);

  // Handle thay đổi text câu hỏi
  const handleQuestionChange = (index, field, value) => {
    const newQs = [...questions];
    newQs[index] = { ...newQs[index], [field]: value };
    setQuestions(newQs);
  };

  const handleOptionChange = (qIndex, optIndex, value) => {
    const newQs = [...questions];
    const newOpts = [...newQs[qIndex].options];
    newOpts[optIndex] = value;
    newQs[qIndex] = { ...newQs[qIndex], options: newOpts };
    setQuestions(newQs);
  };

  // Tính năng: Tích chọn checkbox
  const toggleSelectQuestion = (index) => {
    if (selectedQuestions.includes(index)) {
      setSelectedQuestions(selectedQuestions.filter((i) => i !== index));
    } else {
      setSelectedQuestions([...selectedQuestions, index]);
    }
  };

  // Tính năng: Xóa các câu hỏi đã chọn (Bulk Delete)
  const handleBulkDelete = () => {
    if (selectedQuestions.length === 0) return;
    if (
      window.confirm(
        `Bạn có chắc muốn xóa ${selectedQuestions.length} câu hỏi đã chọn?`,
      )
    ) {
      // Lọc giữ lại những câu KHÔNG nằm trong mảng selectedQuestions
      const remainingQuestions = questions.filter(
        (_, index) => !selectedQuestions.includes(index),
      );
      setQuestions(remainingQuestions);
      setSelectedQuestions([]); // Reset lại mảng chọn
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await bankApi.updateBank(id, { ...bankInfo, questions });
      alert("Cập nhật ngân hàng thành công!");
      navigate("/banks");
    } catch {
      alert("Lỗi khi lưu ngân hàng");
    } finally {
      setSaving(false);
    }
  };

  if (loading)
    return <div className="text-center mt-10">Đang tải dữ liệu...</div>;

  return (
    <div className="max-w-5xl mx-auto mt-8 pb-20">
      <div className="flex justify-between items-center border-b pb-4 mb-6">
        <h2 className="text-3xl font-bold text-gray-800">
          Chỉnh sửa Ngân Hàng
        </h2>
        {selectedQuestions.length > 0 && (
          <button
            onClick={handleBulkDelete}
            className="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-6 rounded-xl transition shadow-md animate-pulse"
          >
            🗑️ Xóa {selectedQuestions.length} câu đã chọn
          </button>
        )}
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* THÔNG TIN CHUNG */}
        <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
          <div className="mb-4">
            <label className="block text-sm font-bold mb-2 text-gray-700">
              Tên Ngân Hàng
            </label>
            <input
              type="text"
              required
              value={bankInfo.title}
              onChange={(e) =>
                setBankInfo({ ...bankInfo, title: e.target.value })
              }
              className="w-full bg-gray-50 border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none"
            />
          </div>
          <div>
            <label className="block text-sm font-bold mb-2 text-gray-700">
              Mô tả thêm
            </label>
            <textarea
              value={bankInfo.description}
              onChange={(e) =>
                setBankInfo({ ...bankInfo, description: e.target.value })
              }
              className="w-full bg-gray-50 border-gray-200 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none"
              rows="2"
            ></textarea>
          </div>
        </div>

        {/* DANH SÁCH CÂU HỎI */}
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <h3 className="text-xl font-bold text-gray-800">
              Danh sách câu hỏi ({questions.length})
            </h3>
            <button
              type="button"
              onClick={() => {
                if (selectedQuestions.length === questions.length)
                  setSelectedQuestions([]);
                else setSelectedQuestions(questions.map((_, i) => i)); // Chọn tất cả
              }}
              className="text-indigo-600 font-semibold hover:underline text-sm"
            >
              {selectedQuestions.length === questions.length
                ? "Bỏ chọn tất cả"
                : "Chọn tất cả"}
            </button>
          </div>

          {questions.map((q, qIndex) => (
            <div
              key={qIndex}
              className={`bg-white p-6 rounded-3xl shadow-sm border transition-all relative
                ${selectedQuestions.includes(qIndex) ? "border-red-400 bg-red-50" : "border-gray-200 hover:border-indigo-300"}`}
            >
              {/* Checkbox để xóa */}
              <div className="absolute top-6 right-6">
                <input
                  type="checkbox"
                  checked={selectedQuestions.includes(qIndex)}
                  onChange={() => toggleSelectQuestion(qIndex)}
                  className="w-6 h-6 cursor-pointer accent-red-500"
                  title="Tích chọn để xóa"
                />
              </div>

              <div className="mb-4 pr-14">
                <label className="block text-sm font-bold mb-2 text-gray-800">
                  Câu hỏi {qIndex + 1}
                </label>
                <textarea
                  value={q.questionText}
                  onChange={(e) =>
                    handleQuestionChange(qIndex, "questionText", e.target.value)
                  }
                  required
                  className="w-full bg-transparent border border-gray-300 rounded-xl p-3 focus:ring-2 focus:ring-indigo-500 outline-none"
                  rows="2"
                ></textarea>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {q.options.map((opt, optIndex) => (
                  <div
                    key={optIndex}
                    className={`flex items-center gap-3 p-3 rounded-xl border ${q.correctAnswer === optIndex ? "bg-green-100 border-green-400" : "bg-gray-50 border-gray-200"}`}
                  >
                    <input
                      type="radio"
                      name={`bank-correct-${qIndex}`}
                      checked={q.correctAnswer === optIndex}
                      onChange={() =>
                        handleQuestionChange(qIndex, "correctAnswer", optIndex)
                      }
                      className="w-5 h-5 cursor-pointer accent-green-600"
                    />
                    <input
                      type="text"
                      value={opt}
                      onChange={(e) =>
                        handleOptionChange(qIndex, optIndex, e.target.value)
                      }
                      required
                      className="w-full bg-transparent border-none outline-none text-sm font-medium text-gray-700"
                    />
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* NÚT THAO TÁC */}
        <div className="flex justify-between items-center bg-white p-4 rounded-2xl shadow-sm border border-gray-100 sticky bottom-4 z-10">
          <button
            type="button"
            onClick={() => navigate("/banks")}
            className="text-gray-500 hover:text-gray-800 font-bold px-6 py-2 transition"
          >
            Hủy bỏ
          </button>
          <button
            type="submit"
            disabled={saving}
            className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-10 rounded-xl shadow-md transition disabled:opacity-50"
          >
            {saving ? "Đang lưu..." : "Lưu Ngân Hàng"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditBank;
