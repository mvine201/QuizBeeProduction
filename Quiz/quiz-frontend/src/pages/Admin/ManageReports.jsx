import { useState, useEffect } from "react";
import adminApi from "../../services/adminApi";

const ManageReports = () => {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchReports();
  }, []);

  const fetchReports = async () => {
    try {
      const data = await adminApi.getPendingReports();
      setReports(data);
    } catch {
      alert("Lỗi tải danh sách báo cáo");
    } finally {
      setLoading(false);
    }
  };

  const handleProcess = async (id, action) => {
    const actionText =
      action === "delete_quiz" ? "XÓA ĐỀ THI này" : "BỎ QUA báo cáo này";
    if (!window.confirm(`Bạn có chắc chắn muốn ${actionText}?`)) return;

    try {
      await adminApi.processReport(id, action);
      // Lọc bỏ những báo cáo đã xử lý (hoặc báo cáo cùng chung đề thi nếu chọn xóa)
      if (action === "delete_quiz") {
        const processedReport = reports.find((r) => r._id === id);
        setReports(
          reports.filter((r) => r.quiz?._id !== processedReport.quiz?._id),
        );
      } else {
        setReports(reports.filter((r) => r._id !== id));
      }
    } catch {
      alert("Lỗi khi xử lý báo cáo");
    }
  };

  if (loading)
    return (
      <div className="mt-10 font-medium text-gray-500">
        Đang tải danh sách vi phạm...
      </div>
    );

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-800 mb-6">
        Quản Lý Báo Cáo Vi Phạm
      </h1>

      {reports.length === 0 ? (
        <div className="bg-green-50 text-green-700 p-8 rounded-3xl border border-green-100 text-center font-medium">
          🎉 Hiện tại không có báo cáo vi phạm nào. Cộng đồng đang rất sạch!
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-6">
          {reports.map((report) => (
            <div
              key={report._id}
              className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 flex flex-col md:flex-row gap-6 items-start md:items-center"
            >
              <div className="flex-1 space-y-2">
                <div className="flex items-center gap-3">
                  <span className="bg-red-100 text-red-700 px-3 py-1 rounded-full text-xs font-bold uppercase">
                    {report.reason}
                  </span>
                  <span className="text-xs text-gray-400">
                    Ngày gửi:{" "}
                    {new Date(report.createdAt).toLocaleDateString("vi-VN")}
                  </span>
                </div>

                <p className="text-gray-700 text-sm bg-gray-50 p-4 rounded-2xl italic border border-gray-100">
                  "{report.description}"
                </p>

                <div className="text-sm text-gray-600 pt-2 flex flex-col gap-1">
                  <p>
                    👤 Người báo cáo:{" "}
                    <strong className="text-gray-800">
                      {report.reporter?.username}
                    </strong>{" "}
                    ({report.reporter?.email})
                  </p>
                  <p>
                    📄 Đề thi bị report:{" "}
                    <strong className="text-blue-600">
                      {report.quiz?.title || "Đề thi đã bị xóa"}
                    </strong>
                  </p>
                  <p>
                    ✍️ Tác giả đề:{" "}
                    <strong className="text-gray-800">
                      {report.quiz?.author?.username || "Không rõ"}
                    </strong>
                  </p>
                </div>
              </div>

              <div className="flex flex-row md:flex-col gap-3 w-full md:w-48 shrink-0">
                <button
                  onClick={() => handleProcess(report._id, "delete_quiz")}
                  className="flex-1 bg-red-50 text-red-600 font-bold py-3 rounded-2xl hover:bg-red-600 hover:text-white transition"
                >
                  🗑️ Xóa Đề Thi
                </button>
                <button
                  onClick={() => handleProcess(report._id, "dismiss")}
                  className="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-2xl hover:bg-gray-200 transition"
                >
                  ✅ Bỏ Qua
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ManageReports;
