import { useState, useEffect } from 'react';
import { BookOpen, Calendar, Users, TrendingUp, AlertTriangle } from 'lucide-react';
import { coursesApi, sessionsApi, attendanceApi, reportsApi } from '../services/api';
import { Session } from '../types';

interface DashboardStats {
  totalCourses: number;
  totalSessions: number;
  totalStudents: number;
  todaySessions: number;
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalCourses: 0,
    totalSessions: 0,
    totalStudents: 0,
    todaySessions: 0,
  });
  const [recentSessions, setRecentSessions] = useState<Session[]>([]);
  const [alerts, setAlerts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        
        // Fetch basic stats
        const [coursesRes, sessionsRes, studentsRes, alertsRes] = await Promise.all([
          coursesApi.getAll(),
          sessionsApi.getAll(),
          attendanceApi.getStudents(),
          reportsApi.getAttendanceAlerts(70),
        ]);

        const courses = coursesRes.data;
        const sessions = sessionsRes.data;
        const students = studentsRes.data;
        const alertsData = alertsRes.data;

        // Calculate today's sessions
        const today = new Date().toISOString().split('T')[0];
        const todaySessions = sessions.filter(session => 
          session.date.split('T')[0] === today
        ).length;

        setStats({
          totalCourses: courses.length,
          totalSessions: sessions.length,
          totalStudents: students.length,
          todaySessions,
        });

        // Get recent sessions (last 5)
        const sortedSessions = sessions
          .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
          .slice(0, 5);
        setRecentSessions(sortedSessions);

        setAlerts(Array.isArray(alertsData) ? alertsData.slice(0, 5) : []);
      } catch (error) {
        console.error('Error fetching dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const statCards = [
    {
      name: 'Total Cursos',
      value: stats.totalCourses,
      icon: BookOpen,
      color: 'bg-blue-500',
    },
    {
      name: 'Total Sesiones',
      value: stats.totalSessions,
      icon: Calendar,
      color: 'bg-green-500',
    },
    {
      name: 'Total Estudiantes',
      value: stats.totalStudents,
      icon: Users,
      color: 'bg-purple-500',
    },
    {
      name: 'Sesiones Hoy',
      value: stats.todaySessions,
      icon: TrendingUp,
      color: 'bg-orange-500',
    },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-white overflow-hidden shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Bienvenido al Sistema de Asistencia
          </h2>
          <p className="text-gray-600">
            Gestiona la asistencia de estudiantes de manera eficiente y moderna.
          </p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((item) => {
          const Icon = item.icon;
          return (
            <div key={item.name} className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className={`${item.color} p-3 rounded-md`}>
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        {item.name}
                      </dt>
                      <dd className="text-2xl font-semibold text-gray-900">
                        {item.value}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Recent Sessions */}
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Sesiones Recientes
            </h3>
            {recentSessions.length === 0 ? (
              <p className="text-gray-500">No hay sesiones registradas.</p>
            ) : (
              <div className="space-y-3">
                {recentSessions.map((session) => (
                  <div
                    key={session.id}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-md"
                  >
                    <div>
                      <p className="font-medium text-gray-900">{session.title}</p>
                      <p className="text-sm text-gray-500">
                        Código: {session.uniqueCode}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm text-gray-900">
                        {new Date(session.date).toLocaleDateString()}
                      </p>
                      <p className="text-sm text-gray-500">
                        {session.startTime} - {session.endTime}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Attendance Alerts */}
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Alertas de Asistencia
            </h3>
            {alerts.length === 0 ? (
              <p className="text-gray-500">No hay alertas de asistencia.</p>
            ) : (
              <div className="space-y-3">
                {alerts.map((alert, index) => (
                  <div
                    key={index}
                    className={`flex items-center p-3 rounded-md ${
                      alert.alertLevel === 'Critical' 
                        ? 'bg-red-50 border-l-4 border-red-400' 
                        : 'bg-yellow-50 border-l-4 border-yellow-400'
                    }`}
                  >
                    <AlertTriangle 
                      className={`h-5 w-5 mr-3 ${
                        alert.alertLevel === 'Critical' ? 'text-red-500' : 'text-yellow-500'
                      }`} 
                    />
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">
                        {alert.studentName} - {alert.courseCode}
                      </p>
                      <p className="text-sm text-gray-600">
                        Asistencia: {alert.attendanceRate}% ({alert.attendedSessions}/{alert.totalSessions})
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
