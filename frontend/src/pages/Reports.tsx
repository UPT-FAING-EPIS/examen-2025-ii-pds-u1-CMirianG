import { useState, useEffect } from 'react';
import { BarChart3, TrendingDown, TrendingUp, Download } from 'lucide-react';
import { reportsApi, coursesApi } from '../services/api';
import { AttendanceReportDto, Course } from '../types';

export default function Reports() {
  const [reports, setReports] = useState<AttendanceReportDto[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [alerts, setAlerts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCourse, setSelectedCourse] = useState<number | null>(null);
  const [alertThreshold, setAlertThreshold] = useState(70);

  useEffect(() => {
    fetchData();
  }, [selectedCourse, alertThreshold]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [reportsRes, coursesRes, alertsRes] = await Promise.all([
        reportsApi.getAttendanceReports(selectedCourse || undefined),
        coursesApi.getAll(),
        reportsApi.getAttendanceAlerts(alertThreshold),
      ]);
      
      setReports(reportsRes.data);
      setCourses(coursesRes.data);
      setAlerts(alertsRes.data);
    } catch (error) {
      console.error('Error fetching reports:', error);
    } finally {
      setLoading(false);
    }
  };

  const exportToCSV = (report: AttendanceReportDto) => {
    const headers = ['Estudiante', 'Código', 'Sesiones Asistidas', 'Total Sesiones', 'Porcentaje Asistencia'];
    const rows = report.studentSummaries.map(student => [
      student.studentName,
      student.studentCode,
      student.attendedSessions.toString(),
      student.totalSessions.toString(),
      `${student.attendanceRate}%`
    ]);

    const csvContent = [headers, ...rows]
      .map(row => row.map(cell => `"${cell}"`).join(','))
      .join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `reporte-asistencia-${report.courseCode}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const getAttendanceColor = (rate: number) => {
    if (rate >= 85) return 'text-green-600';
    if (rate >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getAttendanceIcon = (rate: number) => {
    if (rate >= 70) return <TrendingUp className="h-5 w-5 text-green-500" />;
    return <TrendingDown className="h-5 w-5 text-red-500" />;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-4 sm:space-y-0">
        <h2 className="text-2xl font-bold text-gray-900">Reportes de Asistencia</h2>
        
        <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4">
          <select
            value={selectedCourse || ''}
            onChange={(e) => setSelectedCourse(e.target.value ? parseInt(e.target.value) : null)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
            <option value="">Todos los cursos</option>
            {courses.map((course) => (
              <option key={course.id} value={course.id}>
                {course.code} - {course.name}
              </option>
            ))}
          </select>
          
          <div className="flex items-center space-x-2">
            <label className="text-sm text-gray-700">Umbral de alerta:</label>
            <input
              type="number"
              min="0"
              max="100"
              value={alertThreshold}
              onChange={(e) => setAlertThreshold(parseInt(e.target.value) || 70)}
              className="w-16 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            <span className="text-sm text-gray-500">%</span>
          </div>
        </div>
      </div>

      {/* Overall Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <BarChart3 className="h-8 w-8 text-blue-500" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Promedio General
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    {reports.length > 0 
                      ? Math.round(reports.reduce((sum, r) => sum + r.attendanceRate, 0) / reports.length * 100) / 100
                      : 0}%
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <TrendingDown className="h-8 w-8 text-red-500" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Alertas Activas
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    {alerts.length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <TrendingUp className="h-8 w-8 text-green-500" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Cursos Activos
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    {reports.length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Course Reports */}
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Reportes por Curso
            </h3>
            
            {reports.length === 0 ? (
              <p className="text-gray-500">No hay datos de asistencia disponibles.</p>
            ) : (
              <div className="space-y-4">
                {reports.map((report) => (
                  <div key={report.courseId} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div>
                        <h4 className="font-medium text-gray-900">
                          {report.courseCode} - {report.courseName}
                        </h4>
                        <p className="text-sm text-gray-500">
                          {report.totalSessions} sesiones • {report.totalStudents} estudiantes
                        </p>
                      </div>
                      <div className="flex items-center space-x-2">
                        <span className={`text-lg font-semibold ${getAttendanceColor(report.attendanceRate)}`}>
                          {report.attendanceRate}%
                        </span>
                        {getAttendanceIcon(report.attendanceRate)}
                        <button
                          onClick={() => exportToCSV(report)}
                          className="p-1 text-gray-400 hover:text-gray-600"
                          title="Exportar a CSV"
                        >
                          <Download className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                    
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span>Estudiantes con buena asistencia (≥70%):</span>
                        <span className="font-medium">
                          {report.studentSummaries.filter(s => s.attendanceRate >= 70).length}
                        </span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span>Estudiantes en riesgo (&lt;70%):</span>
                        <span className="font-medium text-red-600">
                          {report.studentSummaries.filter(s => s.attendanceRate < 70).length}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Attendance Alerts */}
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Alertas de Asistencia
            </h3>
            
            {alerts.length === 0 ? (
              <div className="text-center py-8">
                <TrendingUp className="mx-auto h-12 w-12 text-green-400" />
                <p className="mt-2 text-sm text-gray-500">
                  ¡Excelente! No hay estudiantes por debajo del umbral de {alertThreshold}%
                </p>
              </div>
            ) : (
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {alerts.map((alert, index) => (
                  <div
                    key={index}
                    className={`p-3 rounded-lg border-l-4 ${
                      alert.alertLevel === 'Critical' 
                        ? 'bg-red-50 border-red-400' 
                        : 'bg-yellow-50 border-yellow-400'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <h4 className="font-medium text-gray-900">
                          {alert.studentName}
                        </h4>
                        <p className="text-sm text-gray-600">
                          {alert.studentCode} • {alert.courseCode}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                          {alert.courseName}
                        </p>
                      </div>
                      <div className="text-right">
                        <div className={`text-lg font-semibold ${
                          alert.alertLevel === 'Critical' ? 'text-red-600' : 'text-yellow-600'
                        }`}>
                          {alert.attendanceRate}%
                        </div>
                        <div className="text-xs text-gray-500">
                          {alert.attendedSessions}/{alert.totalSessions}
                        </div>
                        <span className={`inline-block px-2 py-1 text-xs font-medium rounded-full mt-1 ${
                          alert.alertLevel === 'Critical' 
                            ? 'bg-red-100 text-red-800' 
                            : 'bg-yellow-100 text-yellow-800'
                        }`}>
                          {alert.alertLevel === 'Critical' ? 'Crítico' : 'Advertencia'}
                        </span>
                      </div>
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
