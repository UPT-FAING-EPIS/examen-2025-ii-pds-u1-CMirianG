import { useState, useEffect } from 'react';
import { CheckCircle, Clock, AlertCircle, BookOpen, Calendar, User, Search } from 'lucide-react';

interface Student {
  id: number;
  firstName: string;
  lastName: string;
  studentCode: string;
  email: string;
}

interface Session {
  id: number;
  title: string;
  uniqueCode: string;
  date: string;
  startTime: string;
  endTime: string;
  isToday: boolean;
  isActive: boolean;
  attendanceStatus?: {
    isPresent: boolean;
    registeredAt: string;
    notes?: string;
  };
}

interface Course {
  id: number;
  name: string;
  code: string;
  description: string;
  instructorName: string;
  sessions: Session[];
}

interface StudentCoursesData {
  student: Student;
  courses: Course[];
}

export default function StudentPortal() {
  const [students, setStudents] = useState<Student[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<number | null>(null);
  const [studentData, setStudentData] = useState<StudentCoursesData | null>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchStudents();
  }, []);

  useEffect(() => {
    if (selectedStudent) {
      fetchStudentCourses();
    }
  }, [selectedStudent]);

  const fetchStudents = async () => {
    try {
      const response = await fetch('/api/students');
      if (response.ok) {
        const students = await response.json();
        setStudents(students);
      }
    } catch (error) {
      console.error('Error fetching students:', error);
      setMessage({ type: 'error', text: 'Error al cargar estudiantes' });
    }
  };

  const fetchStudentCourses = async () => {
    if (!selectedStudent) return;

    try {
      setLoading(true);
      const response = await fetch(`/api/students/${selectedStudent}/courses-with-sessions`);
      if (response.ok) {
        const data = await response.json();
        setStudentData(data);
      } else {
        setMessage({ type: 'error', text: 'Error al cargar cursos del estudiante' });
      }
    } catch (error) {
      console.error('Error fetching student courses:', error);
      setMessage({ type: 'error', text: 'Error de conexión' });
    } finally {
      setLoading(false);
    }
  };

  const filteredStudents = students.filter(student =>
    student.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    student.lastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    student.studentCode.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getAttendanceStatusIcon = (session: Session) => {
    if (session.attendanceStatus) {
      return session.attendanceStatus.isPresent ? (
        <CheckCircle className="h-5 w-5 text-green-600" />
      ) : (
        <AlertCircle className="h-5 w-5 text-red-600" />
      );
    }
    return <Clock className="h-5 w-5 text-gray-400" />;
  };

  const getAttendanceStatusText = (session: Session) => {
    if (session.attendanceStatus) {
      return session.attendanceStatus.isPresent ? 'Presente' : 'Ausente';
    }
    return 'Sin registrar';
  };

  const getAttendanceStatusColor = (session: Session) => {
    if (session.attendanceStatus) {
      return session.attendanceStatus.isPresent ? 'text-green-600' : 'text-red-600';
    }
    return 'text-gray-500';
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const formatTime = (timeString: string) => {
    const time = new Date(`2000-01-01T${timeString}`);
    return time.toLocaleTimeString('es-ES', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const isSessionActive = (session: Session) => {
    if (!session.isToday) return false;
    
    const now = new Date();
    const currentTime = now.getHours() * 60 + now.getMinutes();
    const startTime = new Date(`2000-01-01T${session.startTime}`).getHours() * 60 + 
                     new Date(`2000-01-01T${session.startTime}`).getMinutes();
    const endTime = new Date(`2000-01-01T${session.endTime}`).getHours() * 60 + 
                   new Date(`2000-01-01T${session.endTime}`).getMinutes();
    
    return currentTime >= startTime && currentTime <= endTime;
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center gap-3 mb-6">
          <User className="h-8 w-8 text-blue-600" />
          <h1 className="text-2xl font-bold text-gray-900">Portal del Estudiante</h1>
        </div>

        {/* Buscador de estudiantes */}
        <div className="mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar estudiante por nombre o código..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        {/* Lista de estudiantes */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Seleccionar Estudiante</h2>
          <div className="grid gap-2 max-h-48 overflow-y-auto">
            {filteredStudents.map((student) => (
              <div
                key={student.id}
                className={`p-3 rounded-lg border-2 cursor-pointer transition-colors ${
                  selectedStudent === student.id
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-200 hover:border-blue-300'
                }`}
                onClick={() => setSelectedStudent(student.id)}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-gray-900">
                      {student.firstName} {student.lastName}
                    </p>
                    <p className="text-sm text-gray-600">
                      Código: {student.studentCode} | Email: {student.email}
                    </p>
                  </div>
                  {selectedStudent === student.id && (
                    <CheckCircle className="h-5 w-5 text-blue-600" />
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Información del estudiante seleccionado */}
        {selectedStudent && studentData && (
          <div className="space-y-6">
            {/* Información del estudiante */}
            <div className="bg-blue-50 rounded-lg p-4">
              <h3 className="text-lg font-semibold text-blue-900 mb-2">
                {studentData.student.firstName} {studentData.student.lastName}
              </h3>
              <p className="text-blue-700">
                <strong>Código:</strong> {studentData.student.studentCode} | 
                <strong> Email:</strong> {studentData.student.email}
              </p>
            </div>

            {/* Cursos y sesiones */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Cursos y Sesiones</h3>
              
              {loading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-2 text-gray-600">Cargando cursos...</p>
                </div>
              ) : studentData.courses.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <BookOpen className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                  <p>No hay cursos activos para este estudiante</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {studentData.courses.map((course) => (
                    <div key={course.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <h4 className="text-lg font-semibold text-gray-900">
                            {course.name}
                          </h4>
                          <p className="text-sm text-gray-600">
                            {course.code} | Profesor: {course.instructorName}
                          </p>
                          <p className="text-xs text-gray-500 mt-1">{course.description}</p>
                        </div>
                        <div className="text-right">
                          <span className="text-sm text-gray-500">
                            {course.sessions.length} sesión{course.sessions.length !== 1 ? 'es' : ''}
                          </span>
                        </div>
                      </div>

                      {/* Sesiones del curso */}
                      <div className="space-y-2">
                        {course.sessions.map((session) => (
                          <div
                            key={session.id}
                            className={`p-3 rounded-lg border ${
                              session.isToday
                                ? 'border-blue-300 bg-blue-50'
                                : 'border-gray-200 bg-gray-50'
                            }`}
                          >
                            <div className="flex items-center justify-between">
                              <div className="flex-1">
                                <div className="flex items-center gap-2 mb-1">
                                  <Calendar className="h-4 w-4 text-gray-600" />
                                  <span className="font-medium text-gray-900">{session.title}</span>
                                  {session.isToday && (
                                    <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full">
                                      HOY
                                    </span>
                                  )}
                                  {isSessionActive(session) && (
                                    <span className="px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full">
                                      ACTIVA
                                    </span>
                                  )}
                                </div>
                                
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-sm text-gray-600">
                                  <div>
                                    <strong>Fecha:</strong> {formatDate(session.date)}
                                  </div>
                                  <div>
                                    <strong>Horario:</strong> {formatTime(session.startTime)} - {formatTime(session.endTime)}
                                  </div>
                                  <div>
                                    <strong>Código:</strong> 
                                    <span className="font-mono bg-gray-100 px-2 py-1 rounded ml-1">
                                      {session.uniqueCode}
                                    </span>
                                  </div>
                                </div>
                              </div>

                              <div className="ml-4 text-right">
                                <div className="flex items-center gap-2 mb-1">
                                  {getAttendanceStatusIcon(session)}
                                  <span className={`text-sm font-medium ${getAttendanceStatusColor(session)}`}>
                                    {getAttendanceStatusText(session)}
                                  </span>
                                </div>
                                {session.attendanceStatus && (
                                  <p className="text-xs text-gray-500">
                                    {new Date(session.attendanceStatus.registeredAt).toLocaleString('es-ES')}
                                  </p>
                                )}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Mensaje de resultado */}
        {message && (
          <div className={`mt-4 p-4 rounded-lg ${
            message.type === 'success' 
              ? 'bg-green-100 text-green-800 border border-green-200' 
              : 'bg-red-100 text-red-800 border border-red-200'
          }`}>
            {message.text}
          </div>
        )}
      </div>
    </div>
  );
}