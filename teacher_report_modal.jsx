import React, { useState } from 'react';
import { X, TrendingUp, BookOpen, Brain, MessageSquare, ChevronDown, ChevronUp, Filter, Award, AlertCircle, CheckCircle, BarChart3 } from 'lucide-react';

// Escala de respuestas
const RESPONSE_SCALE = {
  1: { label: 'N', full: 'Nunca', color: '#EF4444' },
  2: { label: 'CN', full: 'Casi nunca', color: '#F59E0B' },
  3: { label: 'AV', full: 'Algunas veces', color: '#FCD34D' },
  4: { label: 'CS', full: 'Casi siempre', color: '#8BC34A' },
  5: { label: 'S', full: 'Siempre', color: '#4CAF50' }
};

// Datos de ejemplo mejorados
const mockTeacherData = {
  teacher: {
    id: 1,
    name: "Dr. Carlos Martínez",
    email: "carlos.martinez@universidad.edu"
  },
  subjects: [
    { 
      id: 1, 
      name: "Programación Orientada a Objetos", 
      code: "POO-101",
      career: "Ingeniería de Sistemas",
      semester: 4,
      totalStudents: 45,
      completedEvaluations: 38,
      averageScore: 4.2
    },
    { 
      id: 2, 
      name: "Estructuras de Datos", 
      code: "ED-201",
      career: "Ingeniería de Sistemas",
      semester: 3,
      totalStudents: 52,
      completedEvaluations: 49,
      averageScore: 4.5
    },
    { 
      id: 3, 
      name: "Base de Datos I", 
      code: "BD-301",
      career: "Ingeniería de Sistemas",
      semester: 5,
      totalStudents: 38,
      completedEvaluations: 32,
      averageScore: 3.9
    }
  ],
  questions: [
    { 
      id: 1, 
      text: "Demuestra dominio y actualización en la presentación de los temas del curso",
      category: "Competencia Disciplinaria",
      aspect: "Formativo",
      responses: { 1: 2, 2: 3, 3: 8, 4: 45, 5: 61 }, // Total: 119 respuestas
      average: 4.3
    },
    { 
      id: 2, 
      text: "Orienta de manera clara los conceptos y teorías del curso",
      category: "Conocimiento y dominio de la materia",
      aspect: "Formativo",
      responses: { 1: 1, 2: 4, 3: 12, 4: 38, 5: 64 },
      average: 4.4
    },
    { 
      id: 3, 
      text: "Promueve el uso de textos u otros materiales en idioma extranjero",
      category: "Dominio de una segunda lengua",
      aspect: "Formativo",
      responses: { 1: 8, 2: 15, 3: 32, 4: 41, 5: 23 },
      average: 3.6
    },
    { 
      id: 4, 
      text: "Presenta el plan de curso y explica su importancia para la formación profesional",
      category: "Planeación y organización del trabajo pedagógico",
      aspect: "Destrezas para desarrollar el proceso de enseñanza y aprendizaje",
      responses: { 1: 3, 2: 5, 3: 15, 4: 48, 5: 48 },
      average: 4.1
    },
    { 
      id: 5, 
      text: "Relaciona el contenido del curso con experiencias y problemas reales",
      category: "Estrategias metodológicas",
      aspect: "Destrezas para desarrollar el proceso de enseñanza y aprendizaje",
      responses: { 1: 2, 2: 6, 3: 18, 4: 52, 5: 41 },
      average: 4.0
    }
  ],
  aiInsights: {
    profile: "Docente con excelente dominio técnico y fuerte compromiso con el aprendizaje estudiantil",
    strengths: [
      "Dominio excepcional de la materia y actualización constante",
      "Claridad en la orientación de conceptos y teorías",
      "Buena organización y presentación del plan de curso",
      "Capacidad para relacionar teoría con práctica"
    ],
    improvements: [
      "Incrementar el uso de materiales en idioma extranjero",
      "Diversificar las estrategias metodológicas",
      "Fortalecer la retroalimentación individualizada"
    ],
    recommendations: [
      "Integrar más recursos multimedia en idioma inglés gradualmente",
      "Implementar metodologías activas como aprendizaje basado en proyectos",
      "Crear espacios de consulta personalizada adicionales"
    ]
  },
  comments: [
    { id: 1, text: "Excelente profesor, explica muy bien y siempre está dispuesto a ayudar", sentiment: "positive", subject: "POO-101", career: "Ingeniería de Sistemas" },
    { id: 2, text: "Debería usar más ejemplos prácticos en clase", sentiment: "neutral", subject: "ED-201", career: "Ingeniería de Sistemas" },
    { id: 3, text: "Muy buen dominio de la materia, pero a veces va muy rápido", sentiment: "positive", subject: "POO-101", career: "Ingeniería de Sistemas" },
    { id: 4, text: "Me gustaría más retroalimentación en los trabajos", sentiment: "neutral", subject: "BD-301", career: "Ingeniería de Sistemas" },
    { id: 5, text: "El mejor profesor que he tenido, muy dedicado", sentiment: "positive", subject: "ED-201", career: "Ingeniería de Sistemas" },
    { id: 6, text: "Las evaluaciones son muy teóricas", sentiment: "negative", subject: "BD-301", career: "Ingeniería de Sistemas" },
    { id: 7, text: "Siempre está disponible para resolver dudas", sentiment: "positive", subject: "POO-101", career: "Ingeniería de Sistemas" },
    { id: 8, text: "Excelente metodología de enseñanza", sentiment: "positive", subject: "ED-201", career: "Ingeniería de Sistemas" }
  ]
};

const TeacherReportModal = () => {
  const [activeTab, setActiveTab] = useState('responses');
  const [commentFilter, setCommentFilter] = useState('all');
  const [subjectFilter, setSubjectFilter] = useState('all');
  const [expandedQuestion, setExpandedQuestion] = useState(null);

  const tabs = [
    { id: 'responses', label: 'Respuestas', icon: TrendingUp },
    { id: 'subjects', label: 'Materias', icon: BookOpen },
    { id: 'ai', label: 'Análisis IA', icon: Brain },
    { id: 'comments', label: 'Comentarios', icon: MessageSquare }
  ];

  const getScoreColor = (score) => {
    if (score >= 4.5) return '#4CAF50';
    if (score >= 4.0) return '#8BC34A';
    if (score >= 3.5) return '#FCD34D';
    if (score >= 3.0) return '#F59E0B';
    return '#EF4444';
  };

  const filteredComments = mockTeacherData.comments.filter(comment => {
    const sentimentMatch = commentFilter === 'all' || comment.sentiment === commentFilter;
    const subjectMatch = subjectFilter === 'all' || comment.subject === subjectFilter;
    return sentimentMatch && subjectMatch;
  });

  const sentimentCounts = {
    positive: mockTeacherData.comments.filter(c => c.sentiment === 'positive').length,
    neutral: mockTeacherData.comments.filter(c => c.sentiment === 'neutral').length,
    negative: mockTeacherData.comments.filter(c => c.sentiment === 'negative').length
  };

  const calculateDistribution = (responses) => {
    const total = Object.values(responses).reduce((sum, count) => sum + count, 0);
    return Object.entries(responses).map(([value, count]) => ({
      value: parseInt(value),
      count,
      percentage: (count / total) * 100
    }));
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-90 flex items-center justify-center z-50">
      <div className="bg-gray-50 w-full h-full flex flex-col">
        
        {/* Header compacto */}
        <div className="bg-gradient-to-br from-green-600 to-green-800 text-white p-4 flex-shrink-0 shadow-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <BarChart3 size={24} />
              </div>
              <div>
                <h2 className="text-lg font-bold">Informe Completo</h2>
                <p className="text-xs text-white text-opacity-90">{mockTeacherData.teacher.name}</p>
              </div>
            </div>
            <button className="p-2 hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors">
              <X size={24} />
            </button>
          </div>
        </div>

        {/* Tabs compactos */}
        <div className="bg-white border-b border-gray-200 flex-shrink-0 overflow-x-auto">
          <div className="flex gap-1 p-2 min-w-max">
            {tabs.map(tab => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm transition-all whitespace-nowrap ${
                    activeTab === tab.id
                      ? 'bg-green-600 text-white shadow-md'
                      : 'text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  <Icon size={16} />
                  {tab.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto">
          
          {/* TAB: Respuestas - REDISEÑADO PARA MÓVIL */}
          {activeTab === 'responses' && (
            <div className="p-4 space-y-3">
              
              {/* Resumen global compacto */}
              <div className="grid grid-cols-2 gap-2">
                <div className="bg-gradient-to-br from-green-500 to-green-600 text-white rounded-lg p-3">
                  <div className="text-xs opacity-90 mb-1">Promedio</div>
                  <div className="text-2xl font-bold">4.1</div>
                  <div className="text-xs opacity-75">/ 5.0</div>
                </div>
                <div className="bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-lg p-3">
                  <div className="text-xs opacity-90 mb-1">Respuestas</div>
                  <div className="text-2xl font-bold">119</div>
                  <div className="text-xs opacity-75">evaluaciones</div>
                </div>
              </div>

              {/* Preguntas expandibles */}
              <div className="space-y-2">
                {mockTeacherData.questions.map(q => {
                  const distribution = calculateDistribution(q.responses);
                  const totalResponses = distribution.reduce((sum, d) => sum + d.count, 0);
                  const isExpanded = expandedQuestion === q.id;

                  return (
                    <div key={q.id} className="bg-white rounded-lg shadow-sm border border-gray-200">
                      
                      {/* Header de pregunta (siempre visible) */}
                      <button
                        onClick={() => setExpandedQuestion(isExpanded ? null : q.id)}
                        className="w-full p-3 text-left"
                      >
                        <div className="flex items-start justify-between gap-3">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 mb-1">
                              <span className="text-xs font-bold text-green-700">#{q.id}</span>
                              <span className="text-xs text-gray-500 truncate">{q.category}</span>
                            </div>
                            <p className="text-sm text-gray-800 font-medium leading-tight">{q.text}</p>
                          </div>
                          <div className="flex flex-col items-end gap-1 flex-shrink-0">
                            <div className="text-xl font-bold" style={{ color: getScoreColor(q.average) }}>
                              {q.average.toFixed(1)}
                            </div>
                            {isExpanded ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
                          </div>
                        </div>

                        {/* Barra de promedio */}
                        <div className="mt-2 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                          <div 
                            className="h-full rounded-full transition-all"
                            style={{ 
                              width: `${(q.average / 5) * 100}%`,
                              backgroundColor: getScoreColor(q.average)
                            }}
                          />
                        </div>
                      </button>

                      {/* Distribución detallada (expandible) */}
                      {isExpanded && (
                        <div className="px-3 pb-3 pt-2 border-t border-gray-100">
                          <div className="text-xs font-semibold text-gray-600 mb-2">
                            Distribución ({totalResponses} respuestas)
                          </div>
                          <div className="space-y-2">
                            {distribution.reverse().map(d => (
                              <div key={d.value} className="flex items-center gap-2">
                                <div 
                                  className="w-8 h-8 rounded flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                                  style={{ backgroundColor: RESPONSE_SCALE[d.value].color }}
                                >
                                  {RESPONSE_SCALE[d.value].label}
                                </div>
                                <div className="flex-1 min-w-0">
                                  <div className="flex items-center justify-between text-xs mb-1">
                                    <span className="text-gray-700 font-medium truncate">
                                      {RESPONSE_SCALE[d.value].full}
                                    </span>
                                    <span className="text-gray-600 ml-2 flex-shrink-0">
                                      {d.count} ({d.percentage.toFixed(0)}%)
                                    </span>
                                  </div>
                                  <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                                    <div 
                                      className="h-full rounded-full transition-all"
                                      style={{ 
                                        width: `${d.percentage}%`,
                                        backgroundColor: RESPONSE_SCALE[d.value].color
                                      }}
                                    />
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* TAB: Materias */}
          {activeTab === 'subjects' && (
            <div className="p-4 space-y-3">
              {mockTeacherData.subjects.map(subject => {
                const completionRate = (subject.completedEvaluations / subject.totalStudents) * 100;
                return (
                  <div key={subject.id} className="bg-white rounded-lg p-4 shadow-sm border border-gray-200">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1 min-w-0">
                        <h3 className="text-base font-bold text-gray-800 truncate">{subject.name}</h3>
                        <div className="flex flex-wrap items-center gap-2 mt-1">
                          <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded font-medium">
                            {subject.code}
                          </span>
                          <span className="text-xs text-gray-600">Sem. {subject.semester}</span>
                        </div>
                        <p className="text-xs text-gray-500 mt-1">{subject.career}</p>
                      </div>
                      <div className="text-right flex-shrink-0 ml-3">
                        <div className="text-2xl font-bold" style={{ color: getScoreColor(subject.averageScore) }}>
                          {subject.averageScore.toFixed(1)}
                        </div>
                      </div>
                    </div>

                    <div className="grid grid-cols-3 gap-2 mb-3">
                      <div className="bg-gray-50 rounded p-2 text-center">
                        <div className="text-xs text-gray-600">Total</div>
                        <div className="text-lg font-bold text-gray-800">{subject.totalStudents}</div>
                      </div>
                      <div className="bg-green-50 rounded p-2 text-center">
                        <div className="text-xs text-gray-600">Evaluados</div>
                        <div className="text-lg font-bold text-green-700">{subject.completedEvaluations}</div>
                      </div>
                      <div className="bg-blue-50 rounded p-2 text-center">
                        <div className="text-xs text-gray-600">Pendientes</div>
                        <div className="text-lg font-bold text-blue-700">
                          {subject.totalStudents - subject.completedEvaluations}
                        </div>
                      </div>
                    </div>

                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <span className="text-xs font-medium text-gray-700">Progreso</span>
                        <span className="text-xs font-bold text-green-700">{completionRate.toFixed(0)}%</span>
                      </div>
                      <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-gradient-to-r from-green-500 to-green-600 rounded-full transition-all"
                          style={{ width: `${completionRate}%` }}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* TAB: Análisis IA */}
          {activeTab === 'ai' && (
            <div className="p-4 space-y-4">
              
              {/* Perfil */}
              <div className="bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-lg p-4 shadow-lg">
                <div className="flex items-center gap-2 mb-3">
                  <Brain size={24} />
                  <h3 className="text-lg font-bold">Perfil Docente</h3>
                </div>
                <p className="text-sm leading-relaxed opacity-95">{mockTeacherData.aiInsights.profile}</p>
              </div>

              {/* Fortalezas */}
              <div className="bg-white rounded-lg p-4 shadow-sm border-2 border-green-200">
                <h3 className="text-base font-bold text-gray-800 mb-3 flex items-center gap-2">
                  <Award size={18} className="text-green-600" />
                  Fortalezas
                </h3>
                <div className="space-y-2">
                  {mockTeacherData.aiInsights.strengths.map((strength, idx) => (
                    <div key={idx} className="flex items-start gap-2 bg-green-50 p-3 rounded-lg">
                      <CheckCircle size={16} className="text-green-600 flex-shrink-0 mt-0.5" />
                      <p className="text-sm text-gray-700">{strength}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Mejoras */}
              <div className="bg-white rounded-lg p-4 shadow-sm border-2 border-orange-200">
                <h3 className="text-base font-bold text-gray-800 mb-3 flex items-center gap-2">
                  <AlertCircle size={18} className="text-orange-600" />
                  Oportunidades de Mejora
                </h3>
                <div className="space-y-2">
                  {mockTeacherData.aiInsights.improvements.map((improvement, idx) => (
                    <div key={idx} className="flex items-start gap-2 bg-orange-50 p-3 rounded-lg">
                      <TrendingUp size={16} className="text-orange-600 flex-shrink-0 mt-0.5" />
                      <p className="text-sm text-gray-700">{improvement}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Recomendaciones */}
              <div className="bg-white rounded-lg p-4 shadow-sm border-2 border-blue-200">
                <h3 className="text-base font-bold text-gray-800 mb-3 flex items-center gap-2">
                  <Brain size={18} className="text-blue-600" />
                  Recomendaciones
                </h3>
                <div className="space-y-2">
                  {mockTeacherData.aiInsights.recommendations.map((rec, idx) => (
                    <div key={idx} className="flex items-start gap-2 bg-blue-50 p-3 rounded-lg">
                      <div className="w-5 h-5 bg-blue-600 text-white rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0">
                        {idx + 1}
                      </div>
                      <p className="text-sm text-gray-700">{rec}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB: Comentarios */}
          {activeTab === 'comments' && (
            <div className="p-4 space-y-4">
              
              {/* Filtros compactos */}
              <div className="bg-white rounded-lg p-3 shadow-sm border border-gray-200">
                <div className="flex items-center gap-2 mb-3">
                  <Filter size={16} className="text-gray-600" />
                  <h3 className="font-bold text-gray-800 text-sm">Filtros</h3>
                </div>
                <div className="space-y-2">
                  <select 
                    value={commentFilter}
                    onChange={(e) => setCommentFilter(e.target.value)}
                    className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  >
                    <option value="all">Todos ({mockTeacherData.comments.length})</option>
                    <option value="positive">Positivos ({sentimentCounts.positive})</option>
                    <option value="neutral">Neutrales ({sentimentCounts.neutral})</option>
                    <option value="negative">Negativos ({sentimentCounts.negative})</option>
                  </select>
                  <select 
                    value={subjectFilter}
                    onChange={(e) => setSubjectFilter(e.target.value)}
                    className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  >
                    <option value="all">Todas las materias</option>
                    {mockTeacherData.subjects.map(s => (
                      <option key={s.code} value={s.code}>{s.name}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Distribución */}
              <div className="grid grid-cols-3 gap-2">
                <div className="bg-green-50 border-2 border-green-200 rounded-lg p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-medium text-green-700">Positivos</span>
                    <CheckCircle size={14} className="text-green-600" />
                  </div>
                  <div className="text-2xl font-bold text-green-700">{sentimentCounts.positive}</div>
                </div>
                <div className="bg-gray-50 border-2 border-gray-200 rounded-lg p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-medium text-gray-700">Neutrales</span>
                    <AlertCircle size={14} className="text-gray-600" />
                  </div>
                  <div className="text-2xl font-bold text-gray-700">{sentimentCounts.neutral}</div>
                </div>
                <div className="bg-red-50 border-2 border-red-200 rounded-lg p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-medium text-red-700">Negativos</span>
                    <AlertCircle size={14} className="text-red-600" />
                  </div>
                  <div className="text-2xl font-bold text-red-700">{sentimentCounts.negative}</div>
                </div>
              </div>

              {/* Lista de comentarios */}
              <div className="space-y-2">
                {filteredComments.map(comment => (
                  <div 
                    key={comment.id}
                    className={`bg-white rounded-lg p-3 shadow-sm border-l-4 ${
                      comment.sentiment === 'positive' ? 'border-green-500' :
                      comment.sentiment === 'negative' ? 'border-red-500' :
                      'border-gray-400'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <span className={`text-xs font-semibold px-2 py-1 rounded ${
                        comment.sentiment === 'positive' ? 'bg-green-100 text-green-700' :
                        comment.sentiment === 'negative' ? 'bg-red-100 text-red-700' :
                        'bg-gray-100 text-gray-700'
                      }`}>
                        {comment.sentiment === 'positive' ? 'Positivo' :
                         comment.sentiment === 'negative' ? 'Negativo' : 'Neutral'}
                      </span>
                      <span className="text-xs text-gray-500">{comment.subject}</span>
                    </div>
                    <p className="text-sm text-gray-700 leading-relaxed">{comment.text}</p>
                  </div>
                ))}
              </div>

              {filteredComments.length === 0 && (
                <div className="bg-white rounded-lg p-8 text-center shadow-sm border border-gray-200">
                  <MessageSquare size={40} className="mx-auto text-gray-300 mb-3" />
                  <p className="text-sm text-gray-500">No hay comentarios</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TeacherReportModal;
