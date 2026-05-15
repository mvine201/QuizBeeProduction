import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import bankApi from "../../services/bankApi";

const QuestionBankList = () => {
  const [banks, setBanks] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchBanks();
  }, []);

  const fetchBanks = async () => {
    try {
      const data = await bankApi.getMyBanks();
      setBanks(data);
    } catch {
      alert("Lỗi khi tải danh sách ngân hàng câu hỏi");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (
      !window.confirm(
        "Bạn có chắc chắn muốn xóa ngân hàng này không? Tất cả câu hỏi bên trong sẽ bị xóa vĩnh viễn!",
      )
    )
      return;
    try {
      await bankApi.deleteBank(id);
      setBanks(banks.filter((b) => b._id !== id));
    } catch {
      alert("Lỗi khi xóa ngân hàng");
    }
  };

  if (loading)
    return (
      <div className="text-center mt-10 text-gray-500 animate-pulse">
        Đang tải dữ liệu...
      </div>
    );

  return (
    <div className="max-w-6xl mx-auto mt-8">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-bold text-gray-800 border-l-4 border-indigo-600 pl-3">
          Ngân Hàng Câu Hỏi
        </h2>
        <div className="flex gap-3">
          <Link
            to="/banks/create-ai"
            className="bg-gradient-to-r from-indigo-500 to-purple-600 hover:from-indigo-600 hover:to-purple-700 text-white font-bold py-2 px-6 rounded-xl transition flex items-center gap-2 shadow-sm animate-pulse"
          >
            ✨ Dùng AI Tạo Ngân Hàng
          </Link>
          <Link
            to="/banks/create"
            className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-6 rounded-xl transition flex items-center gap-2 shadow-sm"
          >
            ➕ Tạo Ngân Hàng Mới
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {banks.length === 0 ? (
          <div className="col-span-full text-center py-10 bg-white rounded-2xl shadow text-gray-500 border border-gray-100">
            Bạn chưa có ngân hàng câu hỏi nào. Hãy tạo một cái mới!
          </div>
        ) : (
          banks.map((bank) => (
            <div
              key={bank._id}
              className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 hover:shadow-md transition flex flex-col"
            >
              <h3
                className="text-xl font-bold text-gray-800 mb-2 truncate"
                title={bank.title}
              >
                {bank.title}
              </h3>
              <p className="text-gray-600 text-sm mb-4 line-clamp-2 h-10">
                {bank.description || "Không có mô tả"}
              </p>

              <div className="flex justify-between items-center mt-auto pt-4 border-t border-gray-100">
                <span className="bg-indigo-50 text-indigo-700 text-sm font-bold px-3 py-1 rounded-full">
                  {/* SỬA LỖI ĐẾM CÂU HỎI TẠI ĐÂY: Sử dụng questionCount từ Aggregate */}
                  {bank.questionCount || 0} câu hỏi
                </span>
                <div className="flex gap-4">
                  <Link
                    to={`/banks/edit/${bank._id}`}
                    className="text-blue-600 hover:text-blue-800 text-sm font-bold transition-colors"
                  >
                    ✏️ Sửa
                  </Link>
                  <button
                    onClick={() => handleDelete(bank._id)}
                    className="text-red-500 hover:text-red-700 text-sm font-bold transition-colors"
                  >
                    🗑️ Xóa
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default QuestionBankList;
