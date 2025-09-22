import { useState, useEffect } from 'react';
import { 
  CheckCircle, 
  Clock, 
  AlertCircle, 
  BookOpen, 
  Calendar, 
  User, 
  Search, 
  Plus,
  BarChart3,
  TrendingUp,
  TrendingDown,
  Zap,
  Bell,
  Target,
  Award,
  RefreshCw,
  Copy,
  Check,
  X
} from 'lucide-react';

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

interface AttendanceStats {
  totalSessions: number;
  attendedSessions: number;
  attendanceRate: number;
  recentAttendance: number; // Last 5 sessions
  attendanceTrend: 'up' | 'down' | 'stable';
}

interface QuickAction {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  action: () => void;
  color: string;
}

export default function StudentPortal() {
  const [students, setStudents] = useState<Student[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<number | null>(null);
  const [studentData, setStudentData] = useState<StudentCoursesData | null>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [attendanceStats, setAttendanceStats] = useState<AttendanceStats | null>(null);
  const [showRegistrationModal, setShowRegistrationModal] = useState(false);
  const [registrationCode, setRegistrationCode] = useState('');
  const [registering, setRegistering] = useState(false);
  const [notifications, setNotifications] = useState<{ id: string; type: 'info' | 'success' | 'warning'; message: string; timestamp: Date }[]>([]);
  const [activeTab, setActiveTab] = useState<'overview' | 'courses' | 'stats'>('overview');

  useEffect(() => {
    fetchStudents();
  }, []);

  useEffect(() => {
    if (selectedStudent) {
      fetchStudentCourses();
      calculateAttendanceStats();
    }
  }, [selectedStudent, studentData]);

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

  const calculateAttendanceStats = () => {
    if (!studentData) return;

    const allSessions = studentData.courses.flatMap(course => course.sessions);
    const attendedSessions = allSessions.filter(session => 
      session.attendanceStatus?.isPresent === true
    );
    
    const totalSessions = allSessions.length;
    const attendanceRate = totalSessions > 0 ? (attendedSessions.length / totalSessions) * 100 : 0;
    
    // Calculate recent attendance (last 5 sessions)
    const recentSessions = allSessions
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .slice(0, 5);
    const recentAttended = recentSessions.filter(session => 
      session.attendanceStatus?.isPresent === true
    ).length;
    
    // Simple trend calculation
    let attendanceTrend: 'up' | 'down' | 'stable' = 'stable';
    if (recentSessions.length >= 2) {
      const firstHalf = recentSessions.slice(0, Math.ceil(recentSessions.length / 2));
      const secondHalf = recentSessions.slice(Math.ceil(recentSessions.length / 2));
      
      const firstHalfRate = firstHalf.filter(s => s.attendanceStatus?.isPresent).length / firstHalf.length;
      const secondHalfRate = secondHalf.filter(s => s.attendanceStatus?.isPresent).length / secondHalf.length;
      
      if (secondHalfRate > firstHalfRate + 0.1) attendanceTrend = 'up';
      else if (secondHalfRate < firstHalfRate - 0.1) attendanceTrend = 'down';
    }

    setAttendanceStats({
      totalSessions,
      attendedSessions: attendedSessions.length,
      attendanceRate,
      recentAttendance: recentAttended,
      attendanceTrend
    });
  };

  const registerAttendance = async () => {
    if (!selectedStudent || !registrationCode.trim()) {
      addNotification('warning', 'Por favor ingresa un código de sesión válido');
      return;
    }

    try {
      setRegistering(true);
      const response = await fetch('/api/attendance', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          studentId: selectedStudent,
          sessionCode: registrationCode.trim(),
          notes: ''
        }),
      });

      if (response.ok) {
        addNotification('success', '¡Asistencia registrada exitosamente!');
        setRegistrationCode('');
        setShowRegistrationModal(false);
        fetchStudentCourses(); // Refresh data
      } else {
        const errorData = await response.json();
        addNotification('error', errorData.message || 'Error al registrar asistencia');
      }
    } catch (error) {
      console.error('Error registering attendance:', error);
      addNotification('error', 'Error de conexión al registrar asistencia');
    } finally {
      setRegistering(false);
    }
  };

  const addNotification = (type: 'info' | 'success' | 'warning' | 'error', message: string) => {
    const notification = {
      id: Date.now().toString(),
      type: type === 'error' ? 'warning' : type,
      message,
      timestamp: new Date()
    };
    setNotifications(prev => [notification, ...prev.slice(0, 4)]); // Keep only 5 notifications
    
    // Auto remove after 5 seconds
    setTimeout(() => {
      setNotifications(prev => prev.filter(n => n.id !== notification.id));
    }, 5000);
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    addNotification('success', 'Copiado al portapapeles');
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

  const getQuickActions = (): QuickAction[] => {
    if (!selectedStudent || !studentData) return [];

    const activeSessions = studentData.courses
      .flatMap(course => course.sessions)
      .filter(session => isSessionActive(session) && !session.attendanceStatus?.isPresent);

    return [
      {
        id: 'register-attendance',
        title: 'Registrar Asistencia',
        description: activeSessions.length > 0 ? `${activeSessions.length} sesión(es) activa(s)` : 'No hay sesiones activas',
        icon: <Plus className="h-5 w-5" />,
        action: () => setShowRegistrationModal(true),
        color: activeSessions.length > 0 ? 'bg-blue-500 hover:bg-blue-600' : 'bg-gray-400'
      },
      {
        id: 'view-stats',
        title: 'Ver Estadísticas',
        description: `${attendanceStats?.attendanceRate.toFixed(1) || 0}% de asistencia`,
        icon: <BarChart3 className="h-5 w-5" />,
        action: () => setActiveTab('stats'),
        color: 'bg-green-500 hover:bg-green-600'
      },
      {
        id: 'refresh-data',
        title: 'Actualizar Datos',
        description: 'Sincronizar información',
        icon: <RefreshCw className="h-5 w-5" />,
        action: () => {
          fetchStudentCourses();
          addNotification('info', 'Datos actualizados');
        },
        color: 'bg-purple-500 hover:bg-purple-600'
      }
    ];
  };

  const getAttendanceTrendIcon = () => {
    if (!attendanceStats) return <TrendingUp className="h-4 w-4 text-gray-400" />;
    
    switch (attendanceStats.attendanceTrend) {
      case 'up':
        return <TrendingUp className="h-4 w-4 text-green-500" />;
      case 'down':
        return <TrendingDown className="h-4 w-4 text-red-500" />;
      default:
        return <Target className="h-4 w-4 text-blue-500" />;
    }
  };

  const getAttendanceRateColor = (rate: number) => {
    if (rate >= 80) return 'text-green-600';
    if (rate >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getAttendanceRateBgColor = (rate: number) => {
    if (rate >= 80) return 'bg-green-100';
    if (rate >= 60) return 'bg-yellow-100';
    return 'bg-red-100';
  };

  return (
    <div className="max-w-7xl mx-auto p-6 min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Notifications */}
      <div className="fixed top-4 right-4 z-50 space-y-2">
        {notifications.map((notification) => (
          <div
            key={notification.id}
            className={`p-4 rounded-lg shadow-lg border-l-4 animate-in slide-in-from-right-5 duration-300 ${
              notification.type === 'success' 
                ? 'bg-green-50 border-green-400 text-green-800' 
                : notification.type === 'warning'
                ? 'bg-yellow-50 border-yellow-400 text-yellow-800'
                : 'bg-blue-50 border-blue-400 text-blue-800'
            }`}
          >
            <div className="flex items-center gap-2">
              {notification.type === 'success' && <CheckCircle className="h-4 w-4" />}
              {notification.type === 'warning' && <AlertCircle className="h-4 w-4" />}
              {notification.type === 'info' && <Bell className="h-4 w-4" />}
              <span className="text-sm font-medium">{notification.message}</span>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-xl p-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-xl">
              <User className="h-8 w-8 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Portal del Estudiante</h1>
              <p className="text-gray-600">Gestiona tu asistencia de manera inteligente</p>
            </div>
          </div>
          
          {selectedStudent && studentData && (
            <div className="flex items-center gap-3">
              <div className="text-right">
                <p className="text-sm text-gray-500">Estudiante seleccionado</p>
                <p className="font-semibold text-gray-900">
                  {studentData.student.firstName} {studentData.student.lastName}
                </p>
              </div>
              <div className="w-12 h-12 bg-gradient-to-r from-green-400 to-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white font-bold text-lg">
                  {studentData.student.firstName[0]}{studentData.student.lastName[0]}
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Student Search */}
        <div className="mb-8">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar estudiante por nombre o código..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-12 pr-4 py-4 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 text-lg"
            />
          </div>
        </div>

        {/* Student List */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Seleccionar Estudiante</h2>
          <div className="grid gap-3 max-h-64 overflow-y-auto pr-2">
            {filteredStudents.map((student) => (
              <div
                key={student.id}
                className={`p-4 rounded-xl border-2 cursor-pointer transition-all duration-200 hover:shadow-md ${
                  selectedStudent === student.id
                    ? 'border-blue-500 bg-gradient-to-r from-blue-50 to-indigo-50 shadow-md'
                    : 'border-gray-200 hover:border-blue-300 bg-white'
                }`}
                onClick={() => setSelectedStudent(student.id)}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
                      <span className="text-white font-bold">
                        {student.firstName[0]}{student.lastName[0]}
                      </span>
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900 text-lg">
                        {student.firstName} {student.lastName}
                      </p>
                      <p className="text-sm text-gray-600">
                        Código: {student.studentCode} • Email: {student.email}
                      </p>
                    </div>
                  </div>
                  {selectedStudent === student.id && (
                    <div className="flex items-center gap-2">
                      <CheckCircle className="h-6 w-6 text-blue-600" />
                      <span className="text-sm font-medium text-blue-600">Seleccionado</span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Selected Student Content */}
        {selectedStudent && studentData && (
          <div className="space-y-8">
            {/* Quick Actions */}
            <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-2xl p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Zap className="h-6 w-6 text-blue-600" />
                Acciones Rápidas
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {getQuickActions().map((action) => (
                  <button
                    key={action.id}
                    onClick={action.action}
                    disabled={action.color.includes('gray-400')}
                    className={`${action.color} text-white p-4 rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed`}
                  >
                    <div className="flex items-center gap-3">
                      {action.icon}
                      <div className="text-left">
                        <p className="font-semibold">{action.title}</p>
                        <p className="text-sm opacity-90">{action.description}</p>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Tab Navigation */}
            <div className="border-b border-gray-200">
              <nav className="flex space-x-8">
                {[
                  { id: 'overview', label: 'Resumen', icon: <BookOpen className="h-5 w-5" /> },
                  { id: 'courses', label: 'Cursos', icon: <Calendar className="h-5 w-5" /> },
                  { id: 'stats', label: 'Estadísticas', icon: <BarChart3 className="h-5 w-5" /> }
                ].map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as any)}
                    className={`flex items-center gap-2 py-2 px-1 border-b-2 font-medium text-sm transition-colors ${
                      activeTab === tab.id
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }`}
                  >
                    {tab.icon}
                    {tab.label}
                  </button>
                ))}
              </nav>
            </div>

            {/* Tab Content */}
            {activeTab === 'overview' && (
              <div className="space-y-6">
                {/* Student Info Card */}
                <div className="bg-gradient-to-r from-green-50 to-blue-50 rounded-2xl p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="text-2xl font-bold text-gray-900 mb-2">
                        {studentData.student.firstName} {studentData.student.lastName}
                      </h3>
                      <div className="space-y-1 text-gray-700">
                        <p><strong>Código:</strong> {studentData.student.studentCode}</p>
                        <p><strong>Email:</strong> {studentData.student.email}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      {attendanceStats && (
                        <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-full ${getAttendanceRateBgColor(attendanceStats.attendanceRate)}`}>
                          {getAttendanceTrendIcon()}
                          <span className={`font-bold text-lg ${getAttendanceRateColor(attendanceStats.attendanceRate)}`}>
                            {attendanceStats.attendanceRate.toFixed(1)}%
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Stats Overview */}
                {attendanceStats && (
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <div className="flex items-center gap-3">
                        <div className="p-3 bg-blue-100 rounded-lg">
                          <Target className="h-6 w-6 text-blue-600" />
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">Sesiones Totales</p>
                          <p className="text-2xl font-bold text-gray-900">{attendanceStats.totalSessions}</p>
                        </div>
                      </div>
                    </div>

                    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <div className="flex items-center gap-3">
                        <div className="p-3 bg-green-100 rounded-lg">
                          <CheckCircle className="h-6 w-6 text-green-600" />
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">Sesiones Asistidas</p>
                          <p className="text-2xl font-bold text-gray-900">{attendanceStats.attendedSessions}</p>
                        </div>
                      </div>
                    </div>

                    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <div className="flex items-center gap-3">
                        <div className="p-3 bg-purple-100 rounded-lg">
                          <Award className="h-6 w-6 text-purple-600" />
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">Asistencia Reciente</p>
                          <p className="text-2xl font-bold text-gray-900">
                            {attendanceStats.recentAttendance}/5
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            )}

            {activeTab === 'stats' && attendanceStats && (
              <div className="space-y-6">
                <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
                  <h3 className="text-xl font-semibold text-gray-900 mb-4">Análisis de Asistencia</h3>
                  
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    {/* Attendance Rate Chart */}
                    <div>
                      <h4 className="font-medium text-gray-900 mb-4">Tasa de Asistencia</h4>
                      <div className="relative">
                        <div className="w-full bg-gray-200 rounded-full h-8">
                          <div 
                            className={`h-8 rounded-full transition-all duration-1000 ${
                              attendanceStats.attendanceRate >= 80 ? 'bg-gradient-to-r from-green-400 to-green-600' :
                              attendanceStats.attendanceRate >= 60 ? 'bg-gradient-to-r from-yellow-400 to-yellow-600' :
                              'bg-gradient-to-r from-red-400 to-red-600'
                            }`}
                            style={{ width: `${Math.min(attendanceStats.attendanceRate, 100)}%` }}
                          ></div>
                        </div>
                        <div className="absolute inset-0 flex items-center justify-center">
                          <span className={`font-bold text-sm ${getAttendanceRateColor(attendanceStats.attendanceRate)}`}>
                            {attendanceStats.attendanceRate.toFixed(1)}%
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Trend Analysis */}
                    <div>
                      <h4 className="font-medium text-gray-900 mb-4">Tendencia</h4>
                      <div className="flex items-center gap-3">
                        {getAttendanceTrendIcon()}
                        <span className="text-lg font-medium text-gray-900">
                          {attendanceStats.attendanceTrend === 'up' && 'Tendencia al alza'}
                          {attendanceStats.attendanceTrend === 'down' && 'Tendencia a la baja'}
                          {attendanceStats.attendanceTrend === 'stable' && 'Tendencia estable'}
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mt-2">
                        Basado en las últimas 5 sesiones
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'courses' && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-6 flex items-center gap-2">
                    <BookOpen className="h-6 w-6 text-blue-600" />
                    Cursos y Sesiones
                  </h3>
                  
                  {loading ? (
                    <div className="text-center py-12">
                      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                      <p className="mt-4 text-gray-600 text-lg">Cargando cursos...</p>
                    </div>
                  ) : studentData.courses.length === 0 ? (
                    <div className="text-center py-12 text-gray-500">
                      <BookOpen className="h-16 w-16 mx-auto mb-4 text-gray-300" />
                      <p className="text-lg">No hay cursos activos para este estudiante</p>
                    </div>
                  ) : (
                    <div className="space-y-6">
                      {studentData.courses.map((course) => (
                        <div key={course.id} className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-6">
                            <div className="flex items-start justify-between">
                              <div>
                                <h4 className="text-xl font-bold text-gray-900 mb-2">
                                  {course.name}
                                </h4>
                                <div className="space-y-1">
                                  <p className="text-sm text-gray-600">
                                    <strong>Código:</strong> {course.code}
                                  </p>
                                  <p className="text-sm text-gray-600">
                                    <strong>Profesor:</strong> {course.instructorName}
                                  </p>
                                  <p className="text-sm text-gray-500 mt-2">{course.description}</p>
                                </div>
                              </div>
                              <div className="text-right">
                                <div className="bg-white rounded-lg px-3 py-2 shadow-sm">
                                  <span className="text-sm font-medium text-gray-700">
                                    {course.sessions.length} sesión{course.sessions.length !== 1 ? 'es' : ''}
                                  </span>
                                </div>
                              </div>
                            </div>
                          </div>

                          {/* Sessions */}
                          <div className="p-6">
                            <div className="space-y-4">
                              {course.sessions.map((session) => (
                                <div
                                  key={session.id}
                                  className={`p-4 rounded-xl border-2 transition-all duration-200 ${
                                    session.isToday
                                      ? 'border-blue-300 bg-gradient-to-r from-blue-50 to-indigo-50 shadow-md'
                                      : 'border-gray-200 bg-gray-50 hover:bg-gray-100'
                                  }`}
                                >
                                  <div className="flex items-center justify-between">
                                    <div className="flex-1">
                                      <div className="flex items-center gap-3 mb-3">
                                        <Calendar className="h-5 w-5 text-gray-600" />
                                        <span className="font-semibold text-gray-900 text-lg">{session.title}</span>
                                        {session.isToday && (
                                          <span className="px-3 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                                            HOY
                                          </span>
                                        )}
                                        {isSessionActive(session) && (
                                          <span className="px-3 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
                                            ACTIVA
                                          </span>
                                        )}
                                      </div>
                                      
                                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                                        <div className="flex items-center gap-2">
                                          <Clock className="h-4 w-4 text-gray-500" />
                                          <span className="text-gray-700">{formatDate(session.date)}</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                          <Clock className="h-4 w-4 text-gray-500" />
                                          <span className="text-gray-700">
                                            {formatTime(session.startTime)} - {formatTime(session.endTime)}
                                          </span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                          <span className="text-gray-700 font-medium">Código:</span>
                                          <button
                                            onClick={() => copyToClipboard(session.uniqueCode)}
                                            className="font-mono bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded-lg transition-colors duration-200 flex items-center gap-2"
                                          >
                                            {session.uniqueCode}
                                            <Copy className="h-3 w-3" />
                                          </button>
                                        </div>
                                      </div>
                                    </div>

                                    <div className="ml-6 text-right">
                                      <div className="flex items-center gap-2 mb-2">
                                        {getAttendanceStatusIcon(session)}
                                        <span className={`text-sm font-semibold ${getAttendanceStatusColor(session)}`}>
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
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Legacy Message */}
        {message && (
          <div className={`mt-4 p-4 rounded-lg ${
            message.type === 'success' 
              ? 'bg-green-100 text-green-800 border border-green-200' 
              : 'bg-red-100 text-red-800 border border-red-200'
          }`}>
            {message.text}
          </div>
        )}

        {/* Registration Modal */}
        {showRegistrationModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl p-8 max-w-md w-full mx-4">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-bold text-gray-900">Registrar Asistencia</h3>
                <button
                  onClick={() => setShowRegistrationModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Código de Sesión
                  </label>
                  <input
                    type="text"
                    value={registrationCode}
                    onChange={(e) => setRegistrationCode(e.target.value.toUpperCase())}
                    placeholder="Ingresa el código de 6 dígitos"
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 text-lg font-mono text-center"
                    maxLength={6}
                  />
                </div>
                
                <div className="flex gap-3 pt-4">
                  <button
                    onClick={() => setShowRegistrationModal(false)}
                    className="flex-1 px-4 py-3 border-2 border-gray-200 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors duration-200"
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={registerAttendance}
                    disabled={registering || !registrationCode.trim()}
                    className="flex-1 px-4 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200 flex items-center justify-center gap-2"
                  >
                    {registering ? (
                      <>
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                        Registrando...
                      </>
                    ) : (
                      <>
                        <Check className="h-4 w-4" />
                        Registrar
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}