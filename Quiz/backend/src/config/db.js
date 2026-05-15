import mongoose from "mongoose";

const connectDB = async () => {
  try {
    if (!process.env.MONGO_URI) {
      throw new Error("MONGO_URI chưa được cấu hình trong .env");
    }

    const conn = await mongoose.connect(process.env.MONGO_URI, {
      // Bạn có thể thêm các option như maxPoolSize: 10 nếu cần
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);

    // Lắng nghe các sự kiện lỗi sau khi đã kết nối thành công
    mongoose.connection.on("error", (err) => {
      console.error(`❌ MongoDB runtime error: ${err}`);
    });

    mongoose.connection.on("disconnected", () => {
      console.warn("⚠️ MongoDB disconnected. Attempting to reconnect...");
    });
  } catch (err) {
    console.error("❌ Connection Error:", err.message);
    process.exit(1);
  }
};

export default connectDB;
