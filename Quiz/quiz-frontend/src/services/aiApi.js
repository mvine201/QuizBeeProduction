// src/services/aiApi.js
import axiosClient from "./axiosClient";

const aiApi = {
  // Gửi dạng JSON thông thường
  generateFromTopic: (data) => {
    return axiosClient.post("/ai/generate-topic", data);
  },

  // Gửi dạng FormData để đính kèm File
  generateFromFile: (formData) => {
    return axiosClient.post("/ai/generate-file", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  },
};

export default aiApi;
