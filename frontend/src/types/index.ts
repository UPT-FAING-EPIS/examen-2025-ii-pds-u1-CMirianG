export interface Student {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  studentCode: string;
  createdAt: string;
}

export interface Course {
  id: number;
  name: string;
  code: string;
  description: string;
  instructorName: string;
  isActive: boolean;
  createdAt: string;
  sessions?: Session[];
}

export interface Session {
  id: number;
  courseId: number;
  title: string;
  date: string;
  startTime: string;
  endTime: string;
  uniqueCode: string;
  isActive: boolean;
  createdAt: string;
  course?: Course;
  attendances?: Attendance[];
}

export interface Attendance {
  id: number;
  studentId: number;
  sessionId: number;
  registeredAt: string;
  isPresent: boolean;
  notes?: string;
  student?: Student;
  session?: Session;
}

export interface AttendanceDto {
  id: number;
  studentId: number;
  studentName: string;
  studentCode: string;
  sessionId: number;
  sessionTitle: string;
  courseCode: string;
  courseName: string;
  registeredAt: string;
  isPresent: boolean;
  notes?: string;
}

export interface RegisterAttendanceDto {
  studentId: number;
  sessionCode: string;
  notes?: string;
}

export interface AttendanceReportDto {
  courseId: number;
  courseName: string;
  courseCode: string;
  totalSessions: number;
  totalStudents: number;
  attendanceRate: number;
  studentSummaries: StudentAttendanceSummary[];
}

export interface StudentAttendanceSummary {
  studentId: number;
  studentName: string;
  studentCode: string;
  attendedSessions: number;
  totalSessions: number;
  attendanceRate: number;
}
