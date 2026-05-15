import { useState, useEffect } from "react";
import quizApi from "../../services/quizApi";

const History = () => {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHistory = async () => {
      try {
        const data = await quizApi.getHistory();
        setHistory(data);
      } catch {
        alert("Không thể tải lịch sử làm bài.");
      } finally {
        setLoading(false);
      }
    };
    fetchHistory();
  }, []);

  if (loading)
    return (
      <div className="text-center mt-10 text-xl font-semibold text-gray-600">
        Đang tải lịch sử...
      </div>
    );

  return (
    <div className="max-w-5xl mx-auto mt-8 pb-10">
      <h2 className="text-3xl font-bold text-gray-800 mb-6 border-b pb-4">
        Lịch Sử Làm Bài Của Tôi
      </h2>

      {history.length === 0 ? (
        <div className="bg-white p-10 rounded-lg shadow text-center border">
          <span className="text-6xl">📭</span>
          <p className="mt-4 text-xl text-gray-500">
            Bạn chưa làm bài thi nào cả.
          </p>
        </div>
      ) : (
        <div className="bg-white shadow-md rounded-lg overflow-hidden border border-gray-200">
          <table className="min-w-full leading-normal">
            <thead>
              <tr className="bg-gray-100 text-gray-700 uppercase text-sm font-bold">
                <th className="px-5 py-4 border-b-2 text-left">Tên Đề Thi</th>
                <th className="px-5 py-4 border-b-2 text-center">
                  Thời Gian Nộp Bài
                </th>
                <th className="px-5 py-4 border-b-2 text-center">
                  Số Câu Đúng
                </th>
                <th className="px-5 py-4 border-b-2 text-center">
                  Điểm Số (Hệ 10)
                </th>
                <th className="px-5 py-4 border-b-2 text-center">Xếp Loại</th>
              </tr>
            </thead>
            <tbody>
              {history.map((item) => (
                <tr key={item._id} className="hover:bg-gray-50 transition">
                  <td className="px-5 py-4 border-b border-gray-200 bg-white text-sm font-semibold text-blue-700">
                    {/* Kiểm tra xem quiz có bị admin xóa mất không */}
                    {item.quiz ? item.quiz.title : "Đề thi đã bị xóa"}
                  </td>
                  <td className="px-5 py-4 border-b border-gray-200 bg-white text-sm text-center text-gray-600">
                    {new Date(item.createdAt).toLocaleString("vi-VN")}
                  </td>
                  <td className="px-5 py-4 border-b border-gray-200 bg-white text-sm text-center font-medium">
                    {item.correctCount} / {item.totalQuestions}
                  </td>
                  <td className="px-5 py-4 border-b border-gray-200 bg-white text-sm text-center">
                    <span
                      className={`font-bold text-lg ${item.score >= 8 ? "text-green-600" : item.score >= 5 ? "text-yellow-600" : "text-red-600"}`}
                    >
                      {item.score}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default History;
