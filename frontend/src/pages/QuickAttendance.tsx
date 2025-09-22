import { useState, useEffect } from 'react';
import { CheckCircle, XCircle, Clock, BookOpen } from 'lucide-react';

interface TodaySession {
  id: number;
  title: string;
  uniqueCode: string;
  startTime: string;
  endTime: string;
  course: {
    id: number;
    name: string;
    code: string;
  };
}

interface QuickRegisterDto {
  studentCode: string;
  sessionCode: string;
  isPresent: boolean;
  notes?: string;
}

export default function QuickAttendance() {
  const [todaySessions, setTodaySessions] = useState<TodaySession[]>([]);
  const [selectedSession, setSelectedSession] = useState<string>('');
  const [studentCode, setStudentCode] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    fetchTodaySessions();
  }, []);

  const fetchTodaySessions = async () => {
    try {
      const response = await fetch('/api/sessions/today');
      if (response.ok) {
        const sessions = await response.json();
        setTodaySessions(sessions);
        if (sessions.length > 0) {
          setSelectedSession(sessions[0].uniqueCode);
        }
      }
    } catch (error) {
      console.error('Error fetching today sessions:', error);
      setMessage({ type: 'error', text: 'Error al cargar las sesiones de hoy' });
    }
  };

  const handleRegisterAttendance = async (isPresent: boolean) => {
    if (!studentCode.trim()) {
      setMessage({ type: 'error', text: 'Por favor ingresa el código del estudiante' });
      return;
    }

    if (!selectedSession) {
      setMessage({ type: 'error', text: 'Por favor selecciona una sesión' });
      return;
    }

    setLoading(true);
    setMessage(null);

    try {
      const requestData: QuickRegisterDto = {
        studentCode: studentCode.trim().toUpperCase(),
        sessionCode: selectedSession,
        isPresent,
        notes: notes.trim() || undefined
      };

      const response = await fetch('/api/attendance/quick-register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      });

      const result = await response.json();

      if (response.ok) {
        setMessage({ 
          type: 'success', 
          text: `✅ ${result.message} - ${result.attendance.studentName} (${result.attendance.studentCode})` 
        });
        // Limpiar formulario
        setStudentCode('');
        setNotes('');
      } else {
        setMessage({ type: 'error', text: result.message || 'Error al registrar asistencia' });
      }
    } catch (error) {
      console.error('Error registering attendance:', error);
      setMessage({ type: 'error', text: 'Error de conexión' });
    } finally {
      setLoading(false);
    }
  };

  const selectedSessionData = todaySessions.find(s => s.uniqueCode === selectedSession);

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center gap-3 mb-6">
          <CheckCircle className="h-8 w-8 text-blue-600" />
          <h1 className="text-2xl font-bold text-gray-900">Registro Rápido de Asistencia</h1>
        </div>

        {/* Información de sesiones de hoy */}
        <div className="mb-6 p-4 bg-blue-50 rounded-lg">
          <div className="flex items-center gap-2 mb-3">
            <Clock className="h-5 w-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-blue-900">Sesiones de Hoy</h2>
          </div>
          
          {todaySessions.length === 0 ? (
            <p className="text-gray-600">No hay sesiones programadas para hoy</p>
          ) : (
            <div className="grid gap-3">
              {todaySessions.map((session) => (
                <div
                  key={session.id}
                  className={`p-3 rounded-lg border-2 cursor-pointer transition-colors ${
                    selectedSession === session.uniqueCode
                      ? 'border-blue-500 bg-blue-100'
                      : 'border-gray-200 hover:border-blue-300'
                  }`}
                  onClick={() => setSelectedSession(session.uniqueCode)}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        <BookOpen className="h-4 w-4 text-gray-600" />
                        <span className="font-medium">{session.course.name}</span>
                        <span className="text-sm text-gray-500">({session.course.code})</span>
                      </div>
                      <p className="text-sm text-gray-600 mt-1">{session.title}</p>
                      <p className="text-xs text-gray-500">
                        {session.startTime} - {session.endTime}
                      </p>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-mono bg-gray-100 px-2 py-1 rounded">
                        {session.uniqueCode}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Formulario de registro */}
        {todaySessions.length > 0 && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Código del Estudiante
              </label>
              <input
                type="text"
                value={studentCode}
                onChange={(e) => setStudentCode(e.target.value.toUpperCase())}
                placeholder="Ej: SI001"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg font-mono"
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    handleRegisterAttendance(true);
                  }
                }}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Notas (opcional)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Observaciones adicionales..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                rows={2}
              />
            </div>

            {/* Botones de acción */}
            <div className="flex gap-4">
              <button
                onClick={() => handleRegisterAttendance(true)}
                disabled={loading}
                className="flex-1 bg-green-600 text-white py-3 px-4 rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 font-medium"
              >
                <CheckCircle className="h-5 w-5" />
                {loading ? 'Registrando...' : 'PRESENTE'}
              </button>
              
              <button
                onClick={() => handleRegisterAttendance(false)}
                disabled={loading}
                className="flex-1 bg-red-600 text-white py-3 px-4 rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 font-medium"
              >
                <XCircle className="h-5 w-5" />
                {loading ? 'Registrando...' : 'AUSENTE'}
              </button>
            </div>

            {/* Mensaje de resultado */}
            {message && (
              <div className={`p-4 rounded-lg ${
                message.type === 'success' 
                  ? 'bg-green-100 text-green-800 border border-green-200' 
                  : 'bg-red-100 text-red-800 border border-red-200'
              }`}>
                {message.text}
              </div>
            )}

            {/* Información de la sesión seleccionada */}
            {selectedSessionData && (
              <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                <p className="text-sm text-gray-600">
                  <strong>Sesión seleccionada:</strong> {selectedSessionData.title} 
                  <br />
                  <strong>Curso:</strong> {selectedSessionData.course.name} ({selectedSessionData.course.code})
                  <br />
                  <strong>Código de sesión:</strong> {selectedSessionData.uniqueCode}
                </p>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
