import { useState, useEffect } from 'react';
import { CheckCircle, Clock, AlertCircle } from 'lucide-react';
import { attendanceApi } from '../services/api';
import { RegisterAttendanceDto, Student, AttendanceDto } from '../types';

export default function StudentPortal() {
  const [students, setStudents] = useState<Student[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<number | null>(null);
  const [sessionCode, setSessionCode] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [attendanceHistory, setAttendanceHistory] = useState<AttendanceDto[]>([]);

  useEffect(() => {
    const fetchStudents = async () => {
      try {
        const response = await attendanceApi.getStudents();
        setStudents(response.data);
      } catch (error) {
        console.error('Error fetching students:', error);
      }
    };

    fetchStudents();
  }, []);

  useEffect(() => {
    if (selectedStudent) {
      fetchAttendanceHistory();
    }
  }, [selectedStudent]);

  const fetchAttendanceHistory = async () => {
    if (!selectedStudent) return;
    
    try {
      const response = await attendanceApi.getAll({ studentId: selectedStudent });
      setAttendanceHistory(response.data);
    } catch (error) {
      console.error('Error fetching attendance history:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!selectedStudent || !sessionCode.trim()) {
      setMessage({ type: 'error', text: 'Por favor selecciona un estudiante e ingresa el código de sesión' });
      return;
    }

    setLoading(true);
    setMessage(null);

    try {
      const dto: RegisterAttendanceDto = {
        studentId: selectedStudent,
        sessionCode: sessionCode.trim(),
        notes: notes.trim() || '',
      };

      await attendanceApi.register(dto);
      setMessage({ type: 'success', text: '¡Asistencia registrada exitosamente!' });
      setSessionCode('');
      setNotes('');
      fetchAttendanceHistory();
    } catch (error: any) {
      const errorMessage = error.response?.data || 'Error al registrar la asistencia';
      setMessage({ type: 'error', text: errorMessage });
    } finally {
      setLoading(false);
    }
  };

  const getAttendanceStats = () => {
    if (!attendanceHistory.length) return null;

    const totalSessions = attendanceHistory.length;
    const attendedSessions = attendanceHistory.filter(a => a.isPresent).length;
    const attendanceRate = (attendedSessions / totalSessions) * 100;

    return {
      totalSessions,
      attendedSessions,
      attendanceRate: Math.round(attendanceRate * 100) / 100,
    };
  };

  const stats = getAttendanceStats();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Portal del Estudiante
          </h2>
          <p className="text-gray-600">
            Registra tu asistencia usando el código proporcionado por tu instructor.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Attendance Registration Form */}
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              Registrar Asistencia
            </h3>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label htmlFor="student" className="block text-sm font-medium text-gray-700">
                  Estudiante
                </label>
                <select
                  id="student"
                  value={selectedStudent || ''}
                  onChange={(e) => setSelectedStudent(e.target.value ? parseInt(e.target.value) : null)}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  required
                >
                  <option value="">Selecciona un estudiante</option>
                  {students.map((student) => (
                    <option key={student.id} value={student.id}>
                      {student.firstName} {student.lastName} ({student.studentCode})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="sessionCode" className="block text-sm font-medium text-gray-700">
                  Código de Sesión
                </label>
                <input
                  type="text"
                  id="sessionCode"
                  value={sessionCode}
                  onChange={(e) => setSessionCode(e.target.value)}
                  placeholder="Ingresa el código de 6 dígitos"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label htmlFor="notes" className="block text-sm font-medium text-gray-700">
                  Notas (Opcional)
                </label>
                <textarea
                  id="notes"
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  rows={3}
                  placeholder="Comentarios adicionales..."
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Registrando...
                  </div>
                ) : (
                  'Registrar Asistencia'
                )}
              </button>
            </form>

            {message && (
              <div className={`mt-4 p-4 rounded-md ${
                message.type === 'success' 
                  ? 'bg-green-50 border border-green-200 text-green-700' 
                  : 'bg-red-50 border border-red-200 text-red-700'
              }`}>
                <div className="flex items-center">
                  {message.type === 'success' ? (
                    <CheckCircle className="h-5 w-5 mr-2" />
                  ) : (
                    <AlertCircle className="h-5 w-5 mr-2" />
                  )}
                  {message.text}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Student Stats and History */}
        {selectedStudent && (
          <div className="space-y-6">
            {/* Stats Card */}
            {stats && (
              <div className="bg-white shadow rounded-lg">
                <div className="px-4 py-5 sm:p-6">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">
                    Estadísticas de Asistencia
                  </h3>
                  <div className="grid grid-cols-3 gap-4">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-blue-600">
                        {stats.attendedSessions}
                      </div>
                      <div className="text-sm text-gray-500">Asistidas</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-gray-600">
                        {stats.totalSessions}
                      </div>
                      <div className="text-sm text-gray-500">Total</div>
                    </div>
                    <div className="text-center">
                      <div className={`text-2xl font-bold ${
                        stats.attendanceRate >= 70 ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {stats.attendanceRate}%
                      </div>
                      <div className="text-sm text-gray-500">Porcentaje</div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Attendance History */}
            <div className="bg-white shadow rounded-lg">
              <div className="px-4 py-5 sm:p-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">
                  Historial de Asistencia
                </h3>
                {attendanceHistory.length === 0 ? (
                  <p className="text-gray-500">No hay registros de asistencia.</p>
                ) : (
                  <div className="space-y-3 max-h-64 overflow-y-auto">
                    {attendanceHistory
                      .sort((a, b) => new Date(b.registeredAt).getTime() - new Date(a.registeredAt).getTime())
                      .map((attendance) => (
                        <div
                          key={attendance.id}
                          className="flex items-center justify-between p-3 bg-gray-50 rounded-md"
                        >
                          <div className="flex items-center">
                            {attendance.isPresent ? (
                              <CheckCircle className="h-5 w-5 text-green-500 mr-3" />
                            ) : (
                              <Clock className="h-5 w-5 text-red-500 mr-3" />
                            )}
                            <div>
                              <p className="font-medium text-gray-900">
                                {attendance.courseName}
                              </p>
                              <p className="text-sm text-gray-500">
                                {attendance.sessionTitle}
                              </p>
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="text-sm text-gray-900">
                              {new Date(attendance.registeredAt).toLocaleDateString()}
                            </p>
                            <p className="text-sm text-gray-500">
                              {new Date(attendance.registeredAt).toLocaleTimeString()}
                            </p>
                          </div>
                        </div>
                      ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
