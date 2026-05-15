import axiosClient from "./axiosClient";

const quizApi = {
  getPublicQuizzes: (params = {}) => {
    // Chuyển object params thành chuỗi query trên URL (VD: ?keyword=toán&page=1)
    const queryString = new URLSearchParams(params).toString();
    return axiosClient.get(`/quizzes/public?${queryString}`);
  },

  // Lấy chi tiết đề thi (để xem thể lệ)
  getQuizById: (id) => {
    return axiosClient.get(`/quizzes/${id}`);
  },

  // Lấy đề thi để làm (có xáo trộn, ẩn đáp án đúng)
  getQuizForTake: (id) => {
    return axiosClient.get(`/quizzes/${id}/take`);
  },

  // Nộp bài thi
  submitQuiz: (id, answers) => {
    return axiosClient.post(`/quizzes/${id}/submit`, { answers });
  },
  //
  // Lấy danh sách đề thi CỦA TÔI
  getMyQuizzes: () => {
    return axiosClient.get("/quizzes");
  },

  // Xóa đề thi
  deleteQuiz: (id) => {
    return axiosClient.delete(`/quizzes/${id}`);
  },

  // Import đề thi từ File (Excel, Word, Text)
  importQuiz: (formData) => {
    // Lưu ý: Upload file cần Header multipart/form-data
    return axiosClient.post("/quizzes/import", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  },
  // Lấy danh sách đánh giá của 1 đề thi
  getQuizReviews: (quizId) => {
    return axiosClient.get(`/quizzes/${quizId}/reviews`);
  },

  // Thêm đánh giá mới
  addReview: (reviewData) => {
    // reviewData bao gồm: { quizId, rating, comment }
    return axiosClient.post("/quizzes/reviews", reviewData);
  },
  // Cập nhật thông tin đề thi
  updateQuiz: (id, data) => {
    return axiosClient.put(`/quizzes/${id}`, data);
  },
  // Tạo đề thi thủ công (gửi JSON)
  createQuizManual: (quizData) => {
    return axiosClient.post("/quizzes", quizData);
  },

  // Lấy lịch sử làm bài của người dùng (Giả định bạn thêm route /history ở backend)
  // Nếu chưa có backend, bạn có thể lấy từ kết quả các bài thi đã làm
  getMyHistory: () => {
    return axiosClient.get("/quizzes/results/my-history");
  },
  // Đọc file để xem trước (Không lưu)
  parseFile: (formData) => {
    return axiosClient.post("/quizzes/parse-file", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
  // Lấy lịch sử thi của user
  getHistory: () => {
    return axiosClient.get("/quizzes/user/history");
  },
  // Tạo đề thi từ ngân hàng câu hỏi
  generateQuizFromBank: (data) => {
    return axiosClient.post("/quizzes/generate-from-bank", data);
  },
  reportQuiz: (data) => {
    // data gồm: { quizId, reason, description }
    return axiosClient.post("/reports", data);
  },
};

export default quizApi;
