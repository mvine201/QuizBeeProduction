import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import quizApi from "../../services/quizApi";

const EditQuiz = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // State cho thông tin chung
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    timeLimit: 15,
    attemptsAllowed: 0,
    isPublic: false,
  });

  // State cho danh sách câu hỏi
  const [questions, setQuestions] = useState([]);

  useEffect(() => {
    const fetchQuiz = async () => {
      try {
        const data = await quizApi.getQuizById(id);

        // Đổ dữ liệu chung
        setFormData({
          title: data.title || "",
          description: data.description || "",
          timeLimit: data.timeLimit || 15,
          attemptsAllowed: data.attemptsAllowed || 0,
          isPublic: data.isPublic || false,
        });

        // Đổ dữ liệu câu hỏi (nếu đề thi rỗng thì tạo sẵn 1 câu trống)
        if (data.questions && data.questions.length > 0) {
          setQuestions(data.questions);
        } else {
          setQuestions([
            {
              questionText: "",
              options: ["", "", "", ""],
              correctAnswer: 0,
              points: 10,
            },
          ]);
        }
      } catch {
        alert("Không tìm thấy đề thi hoặc bạn không có quyền sửa!");
        navigate("/my-quizzes");
      } finally {
        setLoading(false);
      }
    };
    fetchQuiz();
  }, [id, navigate]);

  // Các hàm xử lý thay đổi dữ liệu
  const handleChange = (e) => {
    const value =
      e.target.type === "checkbox" ? e.target.checked : e.target.value;
    setFormData({ ...formData, [e.target.name]: value });
  };

  const handleQuestionChange = (index, field, value) => {
    const newQuestions = [...questions];
    newQuestions[index][field] = value;
    setQuestions(newQuestions);
  };

  const handleOptionChange = (qIndex, optIndex, value) => {
    const newQuestions = [...questions];
    newQuestions[qIndex].options[optIndex] = value;
    setQuestions(newQuestions);
  };

  // Thêm / Xóa câu hỏi
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

  const removeQuestion = (index) => {
    if (questions.length === 1) {
      alert("Đề thi phải có ít nhất 1 câu hỏi!");
      return;
    }
    setQuestions(questions.filter((_, i) => i !== index));
  };

  // Nộp dữ liệu lên API
  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      // Gửi cả formData và mảng questions lên backend
      await quizApi.updateQuiz(id, { ...formData, questions });
      alert("Cập nhật đề thi thành công!");
      navigate("/my-quizzes");
    } catch {
      alert("Lỗi khi cập nhật");
    } finally {
      setSaving(false);
    }
  };

  if (loading)
    return <div className="text-center mt-10">Đang tải dữ liệu đề thi...</div>;

  return (
    <div className="max-w-5xl mx-auto mt-8 pb-20">
      <h2 className="text-3xl font-bold text-gray-800 mb-8 border-b pb-4">
        Chỉnh sửa Toàn Diện Đề Thi
      </h2>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* KHỐI 1: THÔNG TIN CHUNG */}
        <div className="bg-white p-6 rounded-lg shadow border-l-4 border-blue-600">
          <h3 className="text-xl font-bold mb-4 text-blue-800">
            1. Thông tin chung
          </h3>

          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Tên Đề Thi
            </label>
            <input
              type="text"
              name="title"
              required
              value={formData.title}
              onChange={handleChange}
              className="shadow border rounded w-full py-2 px-3 focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Mô tả thêm
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="2"
              className="shadow border rounded w-full py-2 px-3 focus:ring-2 focus:ring-blue-500"
            ></textarea>
          </div>

          <div className="flex gap-4 mb-4">
            <div className="w-1/2">
              <label className="block text-gray-700 text-sm font-bold mb-2">
                Thời gian (Phút)
              </label>
              <input
                type="number"
                name="timeLimit"
                min="1"
                required
                value={formData.timeLimit}
                onChange={handleChange}
                className="shadow border rounded w-full py-2 px-3 focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="w-1/2">
              <label className="block text-gray-700 text-sm font-bold mb-2">
                Số lần làm lại (0 = Vô hạn)
              </label>
              <input
                type="number"
                name="attemptsAllowed"
                min="0"
                value={formData.attemptsAllowed}
                onChange={handleChange}
                className="shadow border rounded w-full py-2 px-3 focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="p-3 bg-yellow-50 rounded border border-yellow-200 inline-flex items-center">
            <input
              type="checkbox"
              name="isPublic"
              id="isPublic"
              checked={formData.isPublic}
              onChange={handleChange}
              className="w-5 h-5 text-blue-600 rounded mr-3 cursor-pointer"
            />
            <label
              htmlFor="isPublic"
              className="font-semibold text-gray-800 cursor-pointer"
            >
              Công khai đề thi này (Mọi người đều có thể làm)
            </label>
          </div>
        </div>

        {/* KHỐI 2: DANH SÁCH CÂU HỎI */}
        <div className="space-y-6">
          <h3 className="text-xl font-bold text-gray-800">
            2. Chỉnh sửa Câu hỏi
          </h3>

          {questions.map((q, qIndex) => (
            <div
              key={qIndex}
              className="bg-white p-6 rounded-lg shadow border border-gray-200 relative"
            >
              <button
                type="button"
                onClick={() => removeQuestion(qIndex)}
                className="absolute top-4 right-4 text-red-500 hover:text-red-700 font-bold bg-red-50 px-3 py-1 rounded"
              >
                Xóa câu này
              </button>

              <div className="mb-4 pr-20">
                <label className="block text-sm font-bold mb-2 text-gray-700">
                  Câu hỏi {qIndex + 1}
                </label>
                <textarea
                  value={q.questionText}
                  onChange={(e) =>
                    handleQuestionChange(qIndex, "questionText", e.target.value)
                  }
                  required
                  className="w-full border p-3 rounded focus:ring-2 focus:ring-blue-500"
                  rows="2"
                  placeholder="Nhập nội dung câu hỏi..."
                ></textarea>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {q.options.map((opt, optIndex) => (
                  <div
                    key={optIndex}
                    className={`flex items-center gap-2 p-2 rounded border ${q.correctAnswer === optIndex ? "bg-green-50 border-green-300" : "bg-gray-50"}`}
                  >
                    <input
                      type="radio"
                      name={`correct-${qIndex}`}
                      checked={q.correctAnswer === optIndex}
                      onChange={() =>
                        handleQuestionChange(qIndex, "correctAnswer", optIndex)
                      }
                      className="w-5 h-5 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={opt}
                      onChange={(e) =>
                        handleOptionChange(qIndex, optIndex, e.target.value)
                      }
                      required
                      className="w-full border-none bg-transparent p-1 focus:outline-none focus:border-b-2 focus:border-blue-500"
                      placeholder={`Đáp án ${String.fromCharCode(65 + optIndex)}`}
                    />
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* KHỐI 3: NÚT ĐIỀU KHIỂN */}
        <div className="flex justify-between items-center bg-white p-4 rounded-lg shadow border">
          <button
            type="button"
            onClick={addQuestion}
            className="bg-gray-800 text-white px-6 py-2 rounded font-semibold hover:bg-gray-700 transition"
          >
            + Thêm câu hỏi
          </button>

          <div className="flex gap-4">
            <button
              type="button"
              onClick={() => navigate("/my-quizzes")}
              className="bg-gray-400 hover:bg-gray-500 text-white px-6 py-3 rounded font-bold transition"
            >
              Hủy
            </button>
            <button
              type="submit"
              disabled={saving}
              className={`text-white px-10 py-3 rounded font-bold text-lg transition ${saving ? "bg-blue-400" : "bg-blue-600 hover:bg-blue-700"}`}
            >
              {saving ? "Đang lưu..." : "Lưu Thay Đổi"}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default EditQuiz;
