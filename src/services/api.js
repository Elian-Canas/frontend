import axios from "axios";

const api = axios.create({
  baseURL:
    "http://spacex-app-alb-1144963660.us-east-1.elb.amazonaws.com/api/v1",
});

export const getLaunches = () => api.get("/launches");
export const getLaunchById = (id) => api.get(`/launches/${id}`);
export const getStats = () => api.get("/launches/stats/summary");

export default api;
