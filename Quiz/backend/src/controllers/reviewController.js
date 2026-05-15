import Review from "../models/Review.js";
import Quiz from "../models/Quiz.js";
import mongoose from "mongoose";

//Thêm đánh giá cho quiz
export const addReview = async (req, res) => {
  try {
    const { quizId, rating, comment } = req.body;
    if (!mongoose.Types.ObjectId.isValid(quizId)) {
      return res.status(400).json({ message: "Mã đề thi không hợp lệ" });
    }

    const normalizedRating = Number(rating);
    if (
      !Number.isInteger(normalizedRating) ||
      normalizedRating < 1 ||
      normalizedRating > 5
    ) {
      return res.status(400).json({ message: "Điểm đánh giá phải từ 1 đến 5" });
    }

    if (!comment || !comment.trim()) {
      return res.status(400).json({ message: "Vui lòng nhập nội dung đánh giá" });
    }

    const quiz = await Quiz.findById(quizId).select("_id");
    if (!quiz) {
      return res.status(404).json({ message: "Không tìm thấy đề thi" });
    }

    const review = await Review.create({
      quiz: quizId,
      user: req.user._id,
      rating: normalizedRating,
      comment: comment.trim(),
    });

    const populatedReview = await Review.findById(review._id).populate(
      "user",
      "username",
    );
    res.status(201).json(populatedReview);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
//Lấy tất cả đánh giá của một quiz
export const getQuizReviews = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.quizId)) {
      return res.status(400).json({ message: "Mã đề thi không hợp lệ" });
    }

    const reviews = await Review.find({ quiz: req.params.quizId })
      .populate("user", "username")
      .sort({ createdAt: -1 });
    res.status(200).json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
