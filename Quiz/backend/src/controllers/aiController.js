import { GoogleGenerativeAI } from "@google/generative-ai";
import mammoth from "mammoth";
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const pdfParse = require("pdf-parse");
// 1. Cấu hình Prompt chuẩn để ép AI trả về JSON
const getPrompt = (numQuestions, context) => `
Bạn là một chuyên gia giáo dục. Hãy tạo ${numQuestions} câu hỏi trắc nghiệm bằng tiếng Việt dựa trên nội dung sau:
"${context}"

Yêu cầu bắt buộc:
- Trả về danh sách câu hỏi dưới định dạng mảng JSON thuần túy. Không kèm giải thích, không kèm markdown code block (như \`\`\`json).
- Độ khó đa dạng.
Cấu trúc mỗi object:
{
  "questionText": "Nội dung câu hỏi",
  "options": ["Đáp án A", "Đáp án B", "Đáp án C", "Đáp án D"],
  "correctAnswer": 0, // Chỉ số của đáp án đúng (từ 0 đến 3)
  "points": 10
}
`;

// Hàm gọi Gemini API
const fetchQuizFromGemini = async (numQuestions, contextText) => {
  if (!process.env.GEMINI_API_KEY)
    throw new Error("Chưa cấu hình GEMINI_API_KEY");

  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" }); // Dùng bản flash cho tốc độ nhanh

  const prompt = getPrompt(numQuestions, contextText);

  // Ép AI trả về JSON
  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: prompt }] }],
    generationConfig: { responseMimeType: "application/json" },
  });

  const responseText = result.response.text();
  return JSON.parse(responseText);
};

// ==========================================
// 🤖 1. TẠO TỪ CHỦ ĐỀ (TOPIC)
// ==========================================
export const generateQuizFromTopic = async (req, res) => {
  try {
    const { topic, numQuestions = 10 } = req.body;

    if (!topic)
      return res.status(400).json({ message: "Vui lòng nhập chủ đề!" });
    if (numQuestions > 100)
      return res.status(400).json({ message: "Chỉ được tạo tối đa 100 câu!" });

    const questions = await fetchQuizFromGemini(
      numQuestions,
      `Chủ đề: ${topic}`,
    );
    res.status(200).json({ message: "Tạo thành công", questions });
  } catch (error) {
    res.status(500).json({ message: "Lỗi AI: " + error.message });
  }
};

// ==========================================
// 📄 2. TẠO TỪ FILE TÀI LIỆU
// ==========================================
export const generateQuizFromFile = async (req, res) => {
  try {
    const { numQuestions = 10 } = req.body;
    if (!req.file)
      return res
        .status(400)
        .json({ message: "Vui lòng upload file tài liệu!" });
    if (numQuestions > 100)
      return res.status(400).json({ message: "Chỉ được tạo tối đa 100 câu!" });

    let rawText = "";
    const fileName = req.file.originalname.toLowerCase();

    // Đọc nội dung file
    if (fileName.endsWith(".pdf")) {
      const pdfData = await pdfParse(req.file.buffer);
      rawText = pdfData.text;
    } else if (fileName.endsWith(".docx")) {
      const docxData = await mammoth.extractRawText({
        buffer: req.file.buffer,
      });
      rawText = docxData.value;
    } else {
      return res.status(400).json({ message: "Chỉ hỗ trợ file .pdf và .docx" });
    }

    // Giới hạn text truyền cho AI (khoảng 30.000 ký tự để tránh vượt token limit)
    const limitedText = rawText.slice(0, 30000);

    const questions = await fetchQuizFromGemini(numQuestions, limitedText);
    res.status(200).json({ message: "Tạo thành công", questions });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Lỗi xử lý file hoặc AI: " + error.message });
  }
};
