import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import bankApi from "../../services/bankApi";
import quizApi from "../../services/quizApi";

const GenerateQuizFromBank = () => {
  const navigate = useNavigate();
  const [banks, setBanks] = useState([]);
  const [selectedBank, setSelectedBank] = useState(null);
  const [mode, setMode] = useState("random"); // "random" hoặc "manual"
  const [loading, setLoading] = useState(true);
  const [isGenerating, setIsGenerating] = useState(false);

  // Form cấu hình đề thi - Đã thêm timeLimit, shuffle...
  const [quizConfig, setQuizConfig] = useState({
    title: "",
    description: "",
    timeLimit: 15,
    numQuestions: 10,
    selectedQuestionIds: [],
    isPublic: false,
    shuffleQuestions: false,
    shuffleAnswers: false,
    attemptsAllowed: 1,
  });

  useEffect(() => {
    fetchBanks();
  }, []);

  const fetchBanks = async () => {
    try {
      const data = await bankApi.getMyBanks();
      setBanks(data);
    } catch {
      alert("Lỗi tải ngân hàng câu hỏi");
    } finally {
      setLoading(false);
    }
  };

  const handleBankSelect = async (bankId) => {
    if (!bankId) {
      setSelectedBank(null);
      return;
    }
    try {
      const data = await bankApi.getBankById(bankId);
      setSelectedBank(data);
      setQuizConfig({
        ...quizConfig,
        title: `Đề thi từ: ${data.title}`,
        numQuestions: data.questions.length > 10 ? 10 : data.questions.length,
      });
    } catch {
      alert("Lỗi tải chi tiết ngân hàng");
    }
  };

  const toggleQuestionSelection = (qId) => {
    const current = [...quizConfig.selectedQuestionIds];
    if (current.includes(qId)) {
      setQuizConfig({
        ...quizConfig,
        selectedQuestionIds: current.filter((id) => id !== qId),
      });
    } else {
      setQuizConfig({ ...quizConfig, selectedQuestionIds: [...current, qId] });
    }
  };

  const handleGenerate = async (e) => {
    e.preventDefault();
    if (!selectedBank) return alert("Vui lòng chọn ngân hàng!");

    setIsGenerating(true);
    try {
      const payload = {
        ...quizConfig,
        bankId: selectedBank._id,
        mode: mode,
      };
      await quizApi.generateQuizFromBank(payload);
      alert("Tạo đề thi từ ngân hàng thành công!");
      navigate("/my-quizzes");
    } catch (err) {
      alert(err.response?.data?.message || "Lỗi khi tạo đề thi");
    } finally {
      setIsGenerating(false);
    }
  };

  if (loading)
    return <div className="text-center mt-10">Đang tải dữ liệu...</div>;

  return (
    <div className="max-w-6xl mx-auto mt-8 pb-20 px-4">
      <h2 className="text-3xl font-bold text-gray-800 mb-6">
        🎲 Thiết lập Đề Thi Tự Động
      </h2>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* CỘT TRÁI: CẤU HÌNH CHI TIẾT */}
        <div className="lg:col-span-5">
          <form
            onSubmit={handleGenerate}
            className="bg-white p-6 rounded-lg shadow-md border sticky top-4 space-y-4"
          >
            <h3 className="font-bold text-lg text-blue-700 border-b pb-2">
              1. Cấu hình chung
            </h3>

            <div>
              <label className="block text-sm font-bold mb-1 text-gray-700">
                Chọn Ngân Hàng Nguồn
              </label>
              <select
                className="w-full border p-2 rounded bg-gray-50 focus:ring-2 focus:ring-blue-500"
                onChange={(e) => handleBankSelect(e.target.value)}
              >
                <option value="">-- Click để chọn --</option>
                {banks.map((b) => (
                  <option key={b._id} value={b._id}>
                    {b.title}
                  </option>
                ))}
              </select>
            </div>

            {selectedBank && (
              <>
                <div>
                  <label className="block text-sm font-bold mb-1 text-gray-700">
                    Tiêu đề đề thi
                  </label>
                  <input
                    type="text"
                    required
                    value={quizConfig.title}
                    onChange={(e) =>
                      setQuizConfig({ ...quizConfig, title: e.target.value })
                    }
                    className="w-full border p-2 rounded"
                    placeholder="VD: Kiểm tra cuối kỳ môn..."
                  />
                </div>

                <div className="flex gap-4">
                  <div className="flex-1">
                    <label className="block text-sm font-bold mb-1 text-gray-700">
                      ⏱️ Thời gian (phút)
                    </label>
                    <input
                      type="number"
                      min="1"
                      required
                      value={quizConfig.timeLimit}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          timeLimit: e.target.value,
                        })
                      }
                      className="w-full border p-2 rounded"
                    />
                  </div>
                  <div className="flex-1">
                    <label className="block text-sm font-bold mb-1 text-gray-700">
                      🔄 Số lượt thi
                    </label>
                    <input
                      type="number"
                      min="0"
                      required
                      value={quizConfig.attemptsAllowed}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          attemptsAllowed: e.target.value,
                        })
                      }
                      className="w-full border p-2 rounded"
                    />
                  </div>
                </div>

                <h3 className="font-bold text-lg text-blue-700 border-b pb-2 pt-2">
                  2. Chế độ chọn câu
                </h3>

                <div className="p-3 bg-gray-50 rounded border flex justify-around">
                  <label className="flex items-center gap-2 cursor-pointer font-medium">
                    <input
                      type="radio"
                      checked={mode === "random"}
                      onChange={() => setMode("random")}
                      className="w-4 h-4 text-blue-600"
                    />
                    Bốc ngẫu nhiên
                  </label>
                  <label className="flex items-center gap-2 cursor-pointer font-medium">
                    <input
                      type="radio"
                      checked={mode === "manual"}
                      onChange={() => setMode("manual")}
                      className="w-4 h-4 text-blue-600"
                    />
                    Chọn bằng tay
                  </label>
                </div>

                {mode === "random" && (
                  <div className="animate-fadeIn">
                    <label className="block text-sm font-bold mb-1 text-gray-700">
                      Số lượng câu cần bốc (Kho có:{" "}
                      {selectedBank.questions.length})
                    </label>
                    <input
                      type="number"
                      min="1"
                      max={selectedBank.questions.length}
                      value={quizConfig.numQuestions}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          numQuestions: e.target.value,
                        })
                      }
                      className="w-full border p-2 rounded focus:border-blue-500"
                    />
                  </div>
                )}

                <h3 className="font-bold text-lg text-blue-700 border-b pb-2 pt-2">
                  3. Tùy chọn nâng cao
                </h3>

                <div className="space-y-2">
                  <label className="flex items-center gap-2 cursor-pointer p-2 hover:bg-gray-50 rounded border border-transparent hover:border-gray-200 transition">
                    <input
                      type="checkbox"
                      checked={quizConfig.shuffleQuestions}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          shuffleQuestions: e.target.checked,
                        })
                      }
                      className="w-4 h-4"
                    />
                    <span className="text-sm">
                      Xáo trộn thứ tự <strong>Câu hỏi</strong>
                    </span>
                  </label>

                  <label className="flex items-center gap-2 cursor-pointer p-2 hover:bg-gray-50 rounded border border-transparent hover:border-gray-200 transition">
                    <input
                      type="checkbox"
                      checked={quizConfig.shuffleAnswers}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          shuffleAnswers: e.target.checked,
                        })
                      }
                      className="w-4 h-4"
                    />
                    <span className="text-sm">
                      Xáo trộn thứ tự <strong>Đáp án (A,B,C,D)</strong>
                    </span>
                  </label>

                  <label className="flex items-center gap-2 cursor-pointer p-2 hover:bg-gray-50 rounded border border-transparent hover:border-gray-200 transition">
                    <input
                      type="checkbox"
                      checked={quizConfig.isPublic}
                      onChange={(e) =>
                        setQuizConfig({
                          ...quizConfig,
                          isPublic: e.target.checked,
                        })
                      }
                      className="w-4 h-4"
                    />
                    <span className="text-sm">
                      Công khai đề thi (Cần Admin duyệt)
                    </span>
                  </label>
                </div>

                <button
                  type="submit"
                  disabled={
                    isGenerating ||
                    (mode === "manual" &&
                      quizConfig.selectedQuestionIds.length === 0)
                  }
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-lg shadow-lg transition transform hover:-translate-y-1 disabled:bg-gray-400"
                >
                  {isGenerating ? "Đang xử lý..." : "🚀 Xuất Bản Đề Thi"}
                </button>
              </>
            )}
          </form>
        </div>

        {/* CỘT PHẢI: CHI TIẾT CÂU HỎI */}
        <div className="lg:col-span-7">
          <div className="bg-white p-6 rounded-lg shadow-md border min-h-[500px]">
            {mode === "random" ? (
              <div className="flex flex-col items-center justify-center h-80 text-gray-400">
                <div className="text-6xl mb-4">🎲</div>
                <p className="text-lg font-medium">
                  Chế độ bốc ngẫu nhiên đang bật
                </p>
                <p className="text-sm">
                  Hệ thống sẽ tự động lấy{" "}
                  <strong>{quizConfig.numQuestions}</strong> câu hỏi bất kỳ khi
                  bạn nhấn nút.
                </p>
              </div>
            ) : selectedBank ? (
              <div className="animate-fadeIn">
                <div className="flex justify-between items-center mb-4 border-b pb-2">
                  <h3 className="font-bold text-xl text-gray-800">
                    Chọn câu hỏi cho đề
                  </h3>
                  <span className="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-sm font-bold">
                    Đã chọn: {quizConfig.selectedQuestionIds.length} /{" "}
                    {selectedBank.questions.length}
                  </span>
                </div>

                <div className="space-y-3 max-h-[700px] overflow-y-auto pr-2">
                  {selectedBank.questions.map((q, idx) => (
                    <div
                      key={q._id}
                      onClick={() => toggleQuestionSelection(q._id)}
                      className={`p-4 border rounded-lg cursor-pointer transition-all ${quizConfig.selectedQuestionIds.includes(q._id) ? "border-blue-500 bg-blue-50 shadow-sm" : "border-gray-200 hover:border-blue-300 hover:bg-gray-50"}`}
                    >
                      <div className="flex gap-3">
                        <div
                          className={`w-6 h-6 rounded border flex items-center justify-center flex-shrink-0 ${quizConfig.selectedQuestionIds.includes(q._id) ? "bg-blue-600 border-blue-600 text-white" : "bg-white border-gray-300"}`}
                        >
                          {quizConfig.selectedQuestionIds.includes(q._id) &&
                            "✓"}
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800">
                            Câu {idx + 1}: {q.questionText}
                          </p>
                          <div className="grid grid-cols-2 gap-x-4 gap-y-1 mt-2">
                            {q.options.map((opt, oIdx) => (
                              <p
                                key={oIdx}
                                className={`text-xs ${q.correctAnswer === oIdx ? "text-green-600 font-bold" : "text-gray-500"}`}
                              >
                                {String.fromCharCode(65 + oIdx)}. {opt}
                              </p>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center h-80 text-gray-400">
                <div className="text-6xl mb-4">🏦</div>
                <p className="text-lg font-medium text-center px-10">
                  Chọn một ngân hàng ở bên trái để bắt đầu thiết lập câu hỏi cho
                  đề thi.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default GenerateQuizFromBank;
