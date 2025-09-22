import axios from 'axios';
import { 
  Course, 
  Session, 
  Student, 
  AttendanceDto, 
  RegisterAttendanceDto, 
  AttendanceReportDto 
} from '../types';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Courses API
export const coursesApi = {
  getAll: () => api.get<Course[]>('/courses'),
  getById: (id: number) => api.get<Course>(`/courses/${id}`),
  create: (course: Partial<Course>) => api.post<Course>('/courses', course),
  update: (id: number, course: Partial<Course>) => api.put(`/courses/${id}`, course),
  delete: (id: number) => api.delete(`/courses/${id}`),
};

// Sessions API
export const sessionsApi = {
  getAll: (courseId?: number) => api.get<Session[]>('/sessions', { params: { courseId } }),
  getById: (id: number) => api.get<Session>(`/sessions/${id}`),
  getByCode: (code: string) => api.get<Session>(`/sessions/by-code/${code}`),
  create: (session: Partial<Session>) => api.post<Session>('/sessions', session),
  update: (id: number, session: Partial<Session>) => api.put(`/sessions/${id}`, session),
  delete: (id: number) => api.delete(`/sessions/${id}`),
};

// Attendance API
export const attendanceApi = {
  register: (dto: RegisterAttendanceDto) => api.post<AttendanceDto>('/attendance', dto),
  getById: (id: number) => api.get<AttendanceDto>(`/attendance/${id}`),
  getAll: (params?: { courseId?: number; studentId?: number; sessionId?: number }) => 
    api.get<AttendanceDto[]>('/attendance', { params }),
  getStudents: () => api.get<Student[]>('/attendance/students'),
};

// Reports API
export const reportsApi = {
  getAttendanceReports: (courseId?: number) => 
    api.get<AttendanceReportDto[]>('/reports/attendance', { params: { courseId } }),
  getStudentHistory: (studentId: number) => 
    api.get<AttendanceDto[]>(`/reports/attendance/student/${studentId}`),
  getAttendanceAlerts: (threshold?: number) => 
    api.get('/reports/attendance/alerts', { params: { threshold } }),
};

export default api;
