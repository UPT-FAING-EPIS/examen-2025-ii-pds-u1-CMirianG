import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import QuickAttendance from './pages/QuickAttendance';
import Courses from './pages/Courses';
import Sessions from './pages/Sessions';
import Attendance from './pages/Attendance';
import Reports from './pages/Reports';
import StudentPortal from './pages/StudentPortal';

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/quick-attendance" element={<QuickAttendance />} />
        <Route path="/courses" element={<Courses />} />
        <Route path="/sessions" element={<Sessions />} />
        <Route path="/attendance" element={<Attendance />} />
        <Route path="/reports" element={<Reports />} />
        <Route path="/student" element={<StudentPortal />} />
      </Routes>
    </Layout>
  );
}

export default App;
