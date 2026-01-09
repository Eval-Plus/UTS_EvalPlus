import React, { useState, useMemo } from 'react';
import { Search, Filter, ChevronDown, ChevronUp, TrendingUp, Users, BookOpen, CheckCircle, AlertCircle, BarChart3, Mail, Download, Share2 } from 'lucide-react';

const AdminAnalysisPanel = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedTeacher, setExpandedTeacher] = useState(null);
  const [showFilters, setShowFilters] = useState(false);
  const [sortBy, setSortBy] = useState('name');
  const [filters, setFilters] = useState({
    careers: ['all'],
    period: '2025-1',
    status: 'all'
  });

  // Datos quemados de docentes
  const teachers = [
    {
      id: 1,
      name: 'Dr. Juan Pérez Martínez',
      email: 'juan.perez@universidad.edu.co',
      career: 'ING-SIS',
      careerName: 'Ingeniería de Sistemas',
      totalSubjects: 3,
      activeEvaluations: 2,
      closedEvaluations: 1,
      completionRate: 80,
      totalStudents: 128,
      completedResponses: 102,
      pendingResponses: 26,
      lastActivity: '2025-01-07',
      subjects: [
        { name: 'Programación Avanzada', code: 'SIS301', students: 45, completed: 36, pending: 9 },
        { name: 'Bases de Datos II', code: 'SIS302', students: 38, completed: 30, pending: 8 },
        { name: 'Ingeniería de Software', code: 'SIS401', students: 45, completed: 36, pending: 9 }
      ],
      avgRating: 4.3,
      period: '2025-1'
    },
    {
      id: 2,
      name: 'Dra. María García Rodríguez',
      email: 'maria.garcia@universidad.edu.co',
      career: 'ADM-EMP',
      careerName: 'Administración de Empresas',
      totalSubjects: 2,
      activeEvaluations: 2,
      closedEvaluations: 0,
      completionRate: 100,
      totalStudents: 83,
      completedResponses: 83,
      pendingResponses: 0,
      lastActivity: '2025-01-08',
      subjects: [
        { name: 'Fundamentos de Administración', code: 'ADM101', students: 45, completed: 45, pending: 0 },
        { name: 'Gestión Empresarial', code: 'ADM201', students: 38, completed: 38, pending: 0 }
      ],
      avgRating: 4.8,
      period: '2025-1'
    },
    {
      id: 3,
      name: 'Mg. Carlos López Sánchez',
      email: 'carlos.lopez@universidad.edu.co',
      career: 'ING-SIS',
      careerName: 'Ingeniería de Sistemas',
      totalSubjects: 2,
      activeEvaluations: 1,
      closedEvaluations: 1,
      completionRate: 45,
      totalStudents: 72,
      completedResponses: 32,
      pendingResponses: 40,
      lastActivity: '2025-01-05',
      subjects: [
        { name: 'Algoritmos y Estructuras', code: 'SIS201', students: 42, completed: 18, pending: 24 },
        { name: 'Matemáticas Discretas', code: 'SIS202', students: 30, completed: 14, pending: 16 }
      ],
      avgRating: 3.9,
      period: '2025-1'
    },
    {
      id: 4,
      name: 'Dr. Ana Martínez Torres',
      email: 'ana.martinez@universidad.edu.co',
      career: 'DER',
      careerName: 'Derecho',
      totalSubjects: 4,
      activeEvaluations: 3,
      closedEvaluations: 1,
      completionRate: 92,
      totalStudents: 165,
      completedResponses: 152,
      pendingResponses: 13,
      lastActivity: '2025-01-08',
      subjects: [
        { name: 'Derecho Constitucional', code: 'DER301', students: 48, completed: 45, pending: 3 },
        { name: 'Derecho Penal', code: 'DER302', students: 42, completed: 40, pending: 2 },
        { name: 'Derecho Civil', code: 'DER201', students: 40, completed: 38, pending: 2 },
        { name: 'Derecho Laboral', code: 'DER401', students: 35, completed: 29, pending: 6 }
      ],
      avgRating: 4.6,
      period: '2025-1'
    },
    {
      id: 5,
      name: 'Mg. Roberto Silva Campos',
      email: 'roberto.silva@universidad.edu.co',
      career: 'ADM-EMP',
      careerName: 'Administración de Empresas',
      totalSubjects: 1,
      activeEvaluations: 1,
      closedEvaluations: 0,
      completionRate: 65,
      totalStudents: 40,
      completedResponses: 26,
      pendingResponses: 14,
      lastActivity: '2025-01-06',
      subjects: [
        { name: 'Marketing Digital', code: 'ADM301', students: 40, completed: 26, pending: 14 }
      ],
      avgRating: 4.1,
      period: '2025-1'
    }
  ];

  // Filtrar y ordenar docentes
  const filteredTeachers = useMemo(() => {
    let result = teachers.filter(teacher => {
      const matchesSearch = teacher.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           teacher.email.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesCareer = filters.careers.includes('all') || filters.careers.includes(teacher.career);
      
      const matchesPeriod = filters.period === 'all' || teacher.period === filters.period;
      
      const matchesStatus = filters.status === 'all' ||
                           (filters.status === 'active' && teacher.activeEvaluations > 0) ||
                           (filters.status === 'none' && teacher.activeEvaluations === 0);
      
      return matchesSearch && matchesCareer && matchesPeriod && matchesStatus;
    });

    // Ordenar
    result.sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'evaluations':
          return b.activeEvaluations - a.activeEvaluations;
        case 'completion':
          return a.completionRate - b.completionRate;
        case 'activity':
          return new Date(b.lastActivity) - new Date(a.lastActivity);
        default:
          return 0;
      }
    });

    return result;
  }, [teachers, searchTerm, filters, sortBy]);

  // Estadísticas globales
  const globalStats = useMemo(() => {
    const filtered = filteredTeachers;
    return {
      totalTeachers: filtered.length,
      totalEvaluations: filtered.reduce((sum, t) => sum + t.activeEvaluations, 0),
      avgCompletion: filtered.length > 0 
        ? (filtered.reduce((sum, t) => sum + t.completionRate, 0) / filtered.length).toFixed(1)
        : 0,
      totalStudents: filtered.reduce((sum, t) => sum + t.totalStudents, 0)
    };
  }, [filteredTeachers]);

  const toggleFilter = (category, value) => {
    setFilters(prev => {
      const current = prev[category];
      if (category === 'careers') {
        if (value === 'all') {
          return { ...prev, careers: ['all'] };
        }
        const newCareers = current.includes(value)
          ? current.filter(c => c !== value)
          : [...current.filter(c => c !== 'all'), value];
        return { ...prev, careers: newCareers.length === 0 ? ['all'] : newCareers };
      }
      return { ...prev, [category]: value };
    });
  };

  const getStatusBadge = (teacher) => {
    if (teacher.completionRate < 50) {
      return { color: 'bg-red-100 text-red-700 border-red-300', icon: AlertCircle, text: 'Atención requerida' };
    } else if (teacher.completionRate < 80) {
      return { color: 'bg-yellow-100 text-yellow-700 border-yellow-300', icon: TrendingUp, text: 'En progreso' };
    } else {
      return { color: 'bg-green-100 text-green-700 border-green-300', icon: CheckCircle, text: 'Excelente' };
    }
  };

  const getCareerColor = (career) => {
    const colors = {
      'ING-SIS': 'bg-blue-100 text-blue-700 border-blue-300',
      'ADM-EMP': 'bg-green-100 text-green-700 border-green-300',
      'DER': 'bg-red-100 text-red-700 border-red-300'
    };
    return colors[career] || 'bg-gray-100 text-gray-700 border-gray-300';
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        
        {/* Header */}
        <div className="bg-gradient-to-br from-green-600 to-green-800 rounded-2xl p-8 mb-6 shadow-lg">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center border-2 border-white border-opacity-30">
              <BarChart3 className="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white">Panel de Análisis</h1>
              <p className="text-green-100 text-sm mt-1">Gestión de evaluaciones docentes</p>
            </div>
          </div>
        </div>

        {/* Barra de búsqueda y filtros */}
        <div className="bg-white rounded-xl p-4 mb-6 shadow-sm border border-gray-200">
          <div className="flex gap-3 mb-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Buscar docente por nombre o email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none"
              />
            </div>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className={`px-6 py-3 rounded-lg font-medium flex items-center gap-2 transition-colors ${
                showFilters ? 'bg-green-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Filter className="w-5 h-5" />
              Filtros
            </button>
          </div>

          {/* Panel de filtros expandible */}
          {showFilters && (
            <div className="border-t border-gray-200 pt-4 grid md:grid-cols-3 gap-4">
              {/* Filtro por carrera */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Carrera</label>
                <div className="space-y-2">
                  {[
                    { value: 'all', label: 'Todas' },
                    { value: 'ING-SIS', label: 'Ingeniería de Sistemas' },
                    { value: 'ADM-EMP', label: 'Administración' },
                    { value: 'DER', label: 'Derecho' }
                  ].map(option => (
                    <label key={option.value} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={filters.careers.includes(option.value)}
                        onChange={() => toggleFilter('careers', option.value)}
                        className="w-4 h-4 text-green-600 rounded focus:ring-green-500"
                      />
                      <span className="text-sm text-gray-700">{option.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Filtro por período */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Período</label>
                <div className="space-y-2">
                  {[
                    { value: '2025-1', label: '2025-1 (actual)' },
                    { value: '2024-2', label: '2024-2' },
                    { value: 'all', label: 'Todos' }
                  ].map(option => (
                    <label key={option.value} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="radio"
                        name="period"
                        checked={filters.period === option.value}
                        onChange={() => setFilters(prev => ({ ...prev, period: option.value }))}
                        className="w-4 h-4 text-green-600 focus:ring-green-500"
                      />
                      <span className="text-sm text-gray-700">{option.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Filtro por estado */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Estado</label>
                <div className="space-y-2">
                  {[
                    { value: 'all', label: 'Todos' },
                    { value: 'active', label: 'Con evaluaciones activas' },
                    { value: 'none', label: 'Sin evaluaciones' }
                  ].map(option => (
                    <label key={option.value} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="radio"
                        name="status"
                        checked={filters.status === option.value}
                        onChange={() => setFilters(prev => ({ ...prev, status: option.value }))}
                        className="w-4 h-4 text-green-600 focus:ring-green-500"
                      />
                      <span className="text-sm text-gray-700">{option.label}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Estadísticas globales */}
        <div className="bg-white rounded-xl p-6 mb-6 shadow-sm border border-gray-200">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard icon={Users} label="Docentes" value={globalStats.totalTeachers} color="blue" />
            <StatCard icon={BookOpen} label="Evaluaciones" value={globalStats.totalEvaluations} color="purple" />
            <StatCard icon={TrendingUp} label="Completitud" value={`${globalStats.avgCompletion}%`} color="green" />
            <StatCard icon={Users} label="Estudiantes" value={globalStats.totalStudents} color="orange" />
          </div>
        </div>

        {/* Ordenamiento */}
        <div className="bg-white rounded-xl p-4 mb-6 shadow-sm border border-gray-200">
          <div className="flex items-center gap-3">
            <span className="text-sm font-medium text-gray-700">Ordenar por:</span>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent outline-none text-sm"
            >
              <option value="name">Nombre (A-Z)</option>
              <option value="evaluations">Evaluaciones activas</option>
              <option value="completion">Completitud (urgentes primero)</option>
              <option value="activity">Última actividad</option>
            </select>
          </div>
        </div>

        {/* Lista de docentes */}
        <div className="space-y-4">
          {filteredTeachers.length === 0 ? (
            <div className="bg-white rounded-xl p-12 text-center shadow-sm border border-gray-200">
              <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-700 mb-2">No se encontraron docentes</h3>
              <p className="text-gray-500">Intenta ajustar los filtros o el término de búsqueda</p>
            </div>
          ) : (
            filteredTeachers.map(teacher => (
              <TeacherCard
                key={teacher.id}
                teacher={teacher}
                isExpanded={expandedTeacher === teacher.id}
                onToggle={() => setExpandedTeacher(expandedTeacher === teacher.id ? null : teacher.id)}
                getStatusBadge={getStatusBadge}
                getCareerColor={getCareerColor}
              />
            ))
          )}
        </div>
      </div>
    </div>
  );
};

// Componente de tarjeta de estadística
const StatCard = ({ icon: Icon, label, value, color }) => {
  const colors = {
    blue: 'bg-blue-50 text-blue-700 border-blue-200',
    purple: 'bg-purple-50 text-purple-700 border-purple-200',
    green: 'bg-green-50 text-green-700 border-green-200',
    orange: 'bg-orange-50 text-orange-700 border-orange-200'
  };

  return (
    <div className={`${colors[color]} border rounded-xl p-4`}>
      <div className="flex items-center gap-2 mb-2">
        <Icon className="w-4 h-4" />
        <span className="text-xs font-medium">{label}</span>
      </div>
      <div className="text-2xl font-bold">{value}</div>
    </div>
  );
};

// Componente de tarjeta de docente
const TeacherCard = ({ teacher, isExpanded, onToggle, getStatusBadge, getCareerColor }) => {
  const status = getStatusBadge(teacher);
  const StatusIcon = status.icon;

  return (
    <div className="bg-white rounded-xl shadow-sm border-2 border-gray-200 hover:border-green-300 transition-all">
      {/* Card colapsado */}
      <div
        className="p-5 cursor-pointer"
        onClick={onToggle}
      >
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-green-700 rounded-xl flex items-center justify-center text-white font-bold text-lg shadow-lg">
                {teacher.name.split(' ')[0][0]}{teacher.name.split(' ')[1]?.[0]}
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-bold text-gray-900">{teacher.name}</h3>
                <div className="flex items-center gap-2 mt-1">
                  <span className={`text-xs px-2 py-1 rounded-md border font-medium ${getCareerColor(teacher.career)}`}>
                    {teacher.career}
                  </span>
                  <span className="text-xs text-gray-500">•</span>
                  <span className="text-xs text-gray-600">{teacher.totalSubjects} materias</span>
                  <span className="text-xs text-gray-500">•</span>
                  <span className="text-xs text-gray-600">{teacher.activeEvaluations} activas</span>
                </div>
              </div>
            </div>

            {/* Barra de progreso */}
            <div className="mt-3">
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-medium text-gray-600">Completitud</span>
                <span className="text-xs font-bold text-gray-900">{teacher.completionRate}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className={`h-2 rounded-full transition-all ${
                    teacher.completionRate < 50 ? 'bg-red-500' :
                    teacher.completionRate < 80 ? 'bg-yellow-500' : 'bg-green-500'
                  }`}
                  style={{ width: `${teacher.completionRate}%` }}
                />
              </div>
            </div>

            {/* Badge de estado */}
            <div className="mt-3">
              <span className={`inline-flex items-center gap-1 text-xs px-2 py-1 rounded-md border font-medium ${status.color}`}>
                <StatusIcon className="w-3 h-3" />
                {status.text}
              </span>
            </div>
          </div>

          {/* Botón expandir */}
          <button className="ml-4 p-2 hover:bg-gray-100 rounded-lg transition-colors">
            {isExpanded ? (
              <ChevronUp className="w-5 h-5 text-gray-600" />
            ) : (
              <ChevronDown className="w-5 h-5 text-gray-600" />
            )}
          </button>
        </div>
      </div>

      {/* Card expandido */}
      {isExpanded && (
        <div className="border-t border-gray-200 p-5 bg-gray-50">
          {/* Información de contacto */}
          <div className="mb-4 flex items-center gap-2 text-sm text-gray-600">
            <Mail className="w-4 h-4" />
            <span>{teacher.email}</span>
          </div>

          {/* Lista de materias */}
          <div className="mb-4">
            <h4 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <BookOpen className="w-4 h-4" />
              Materias
            </h4>
            <div className="space-y-2">
              {teacher.subjects.map((subject, idx) => (
                <div key={idx} className="bg-white rounded-lg p-3 border border-gray-200">
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <p className="font-medium text-gray-900">{subject.name}</p>
                      <p className="text-xs text-gray-500">{subject.code}</p>
                    </div>
                    <span className="text-xs font-semibold text-gray-600 bg-gray-100 px-2 py-1 rounded">
                      {subject.students} estudiantes
                    </span>
                  </div>
                  <div className="flex gap-4 text-xs">
                    <span className="text-green-600 font-medium">
                      ✓ {subject.completed} completadas
                    </span>
                    <span className="text-orange-600 font-medium">
                      ⏳ {subject.pending} pendientes
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Estadísticas rápidas */}
          <div className="bg-white rounded-lg p-4 border border-gray-200 mb-4">
            <h4 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <BarChart3 className="w-4 h-4" />
              Estadísticas rápidas
            </h4>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <span className="text-gray-600">Evaluaciones:</span>
                <p className="font-semibold text-gray-900">
                  {teacher.activeEvaluations} activas, {teacher.closedEvaluations} cerradas
                </p>
              </div>
              <div>
                <span className="text-gray-600">Respuestas:</span>
                <p className="font-semibold text-gray-900">
                  {teacher.completedResponses}/{teacher.totalStudents} ({teacher.completionRate}%)
                </p>
              </div>
              <div>
                <span className="text-gray-600">Período actual:</span>
                <p className="font-semibold text-gray-900">{teacher.period}</p>
              </div>
              <div>
                <span className="text-gray-600">Última actividad:</span>
                <p className="font-semibold text-gray-900">{teacher.lastActivity}</p>
              </div>
            </div>
          </div>

          {/* Botones de acción */}
          <div className="space-y-2">
            <button className="w-full bg-gradient-to-r from-green-500 to-green-700 text-white font-semibold py-3 px-4 rounded-lg hover:shadow-lg transition-all flex items-center justify-center gap-2">
              <BarChart3 className="w-5 h-5" />
              Ver Informe Completo
            </button>
            
            <div className="grid grid-cols-3 gap-2">
              <button className="bg-white border border-gray-300 text-gray-700 font-medium py-2 px-3 rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-center gap-1 text-sm">
                <Mail className="w-4 h-4" />
                Email
              </button>
              <button className="bg-white border border-gray-300 text-gray-700 font-medium py-2 px-3 rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-center gap-1 text-sm">
                <Download className="w-4 h-4" />
                Excel
              </button>
              <button className="bg-white border border-gray-300 text-gray-700 font-medium py-2 px-3 rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-center gap-1 text-sm">
                <Share2 className="w-4 h-4" />
                Link
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminAnalysisPanel;
