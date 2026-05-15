import { useState, useEffect, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import quizApi from "../../services/quizApi";

const TakeQuiz = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const [quiz, setQuiz] = useState(null);
  // SỬA: Lưu thành Object { index, text } thay vì chỉ số
  const [answers, setAnswers] = useState({});
  const [timeLeft, setTimeLeft] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const fetchQuizForTake = async () => {
      try {
        const data = await quizApi.getQuizForTake(id);
        setQuiz(data);
        setTimeLeft(data.timeLimit * 60);
      } catch (err) {
        alert(err.response?.data?.message || "Không thể lấy đề thi");
        navigate("/");
      }
    };
    fetchQuizForTake();
  }, [id, navigate]);

  const handleSubmit = useCallback(async () => {
    if (isSubmitting) return;
    setIsSubmitting(true);

    // SỬA: Gửi kèm selectedText về Backend
    const formattedAnswers = Object.keys(answers).map((qId) => ({
      questionId: qId,
      selectedOption: answers[qId].index,
      selectedText: answers[qId].text,
    }));

    try {
      const response = await quizApi.submitQuiz(id, formattedAnswers);
      navigate(`/quizzes/${id}/result`, {
        state: { result: response.result, quiz: quiz },
      });
    } catch {
      alert("Lỗi khi nộp bài!");
      setIsSubmitting(false);
    }
  }, [answers, id, isSubmitting, navigate, quiz]);

  useEffect(() => {
    if (timeLeft === null || timeLeft <= 0 || isSubmitting) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          handleSubmit();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, isSubmitting, handleSubmit]);

  const formatTime = (seconds) => {
    const m = Math.floor(seconds / 60)
      .toString()
      .padStart(2, "0");
    const s = (seconds % 60).toString().padStart(2, "0");
    return `${m}:${s}`;
  };

  // SỬA: Nhận thêm optionText
  const handleOptionSelect = (questionId, optionIndex, optionText) => {
    setAnswers((prev) => ({
      ...prev,
      [questionId]: { index: optionIndex, text: optionText },
    }));
  };

  if (!quiz)
    return <div className="text-center mt-10">Đang chuẩn bị đề thi...</div>;

  return (
    <div className="max-w-4xl mx-auto mt-6">
      <div className="sticky top-0 bg-white p-4 rounded-lg shadow-md mb-6 flex justify-between items-center z-10 border-b-4 border-blue-600">
        <h2 className="text-xl font-bold truncate w-2/3">{quiz.title}</h2>
        <div
          className={`text-2xl font-mono font-bold ${timeLeft < 60 ? "text-red-600 animate-pulse" : "text-green-600"}`}
        >
          ⏱️ {formatTime(timeLeft)}
        </div>
      </div>

      <div className="space-y-6">
        {quiz.questions.map((q, index) => (
          <div
            key={q._id}
            className="bg-white p-6 rounded-lg shadow-sm border border-gray-200"
          >
            <h3 className="font-semibold text-lg mb-4 text-gray-800">
              Câu {index + 1}: {q.questionText}
              <span className="text-sm font-normal text-gray-500 ml-2">
                ({q.points} điểm)
              </span>
            </h3>

            <div className="space-y-3">
              {q.options.map((opt, optIndex) => (
                <label
                  key={optIndex}
                  className={`flex items-center p-3 rounded cursor-pointer border transition-colors
                    ${answers[q._id]?.index === optIndex ? "bg-blue-50 border-blue-400" : "hover:bg-gray-50 border-gray-200"}`}
                >
                  <input
                    type="radio"
                    name={`question-${q._id}`}
                    value={optIndex}
                    checked={answers[q._id]?.index === optIndex}
                    onChange={() => handleOptionSelect(q._id, optIndex, opt)}
                    className="w-5 h-5 text-blue-600"
                  />
                  <span className="ml-3 text-gray-700">{opt}</span>
                </label>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div className="mt-8 mb-16 text-center">
        <button
          onClick={() => {
            if (window.confirm("Bạn có chắc chắn muốn nộp bài?"))
              handleSubmit();
          }}
          disabled={isSubmitting}
          className="bg-blue-600 hover:bg-blue-700 text-white text-xl font-bold py-3 px-10 rounded-full shadow-lg disabled:bg-gray-400"
        >
          {isSubmitting ? "Đang nộp bài..." : "Nộp Bài Ngay"}
        </button>
      </div>
    </div>
  );
};

export default TakeQuiz;
