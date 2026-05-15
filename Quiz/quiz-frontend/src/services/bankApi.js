import axiosClient from "./axiosClient";

const bankApi = {
  getMyBanks: () => {
    return axiosClient.get("/banks");
  },
  getBankById: (id) => {
    return axiosClient.get(`/banks/${id}`);
  },
  createBank: (data) => {
    return axiosClient.post("/banks", data);
  },
  updateBank: (id, data) => {
    return axiosClient.put(`/banks/${id}`, data);
  },
  deleteBank: (id) => {
    return axiosClient.delete(`/banks/${id}`);
  },
};

export default bankApi;
