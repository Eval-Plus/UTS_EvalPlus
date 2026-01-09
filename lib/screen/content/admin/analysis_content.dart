import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';

/// Modelo de datos para un docente
class TeacherData {
  final int id;
  final String name;
  final String email;
  final String career;
  final String careerName;
  final int totalSubjects;
  final int activeEvaluations;
  final int closedEvaluations;
  final int completionRate;
  final int totalStudents;
  final int completedResponses;
  final int pendingResponses;
  final String lastActivity;
  final List<SubjectData> subjects;
  final double avgRating;
  final String period;

  TeacherData({
    required this.id,
    required this.name,
    required this.email,
    required this.career,
    required this.careerName,
    required this.totalSubjects,
    required this.activeEvaluations,
    required this.closedEvaluations,
    required this.completionRate,
    required this.totalStudents,
    required this.completedResponses,
    required this.pendingResponses,
    required this.lastActivity,
    required this.subjects,
    required this.avgRating,
    required this.period,
  });
}

/// Modelo de datos para una materia
class SubjectData {
  final String name;
  final String code;
  final int students;
  final int completed;
  final int pending;

  SubjectData({
    required this.name,
    required this.code,
    required this.students,
    required this.completed,
    required this.pending,
  });
}

/// Contenido de análisis administrativo
class AnalysisContent extends StatefulWidget {
  const AnalysisContent({super.key});

  @override
  State<AnalysisContent> createState() => _AnalysisContentState();
}

class _AnalysisContentState extends State<AnalysisContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  int? _expandedTeacherId;
  bool _showFilters = false;
  String _sortBy = 'name';
  
  final Map<String, dynamic> _filters = {
    'careers': ['all'],
    'period': '2025-1',
    'status': 'all',
  };

  // Datos quemados de docentes
  final List<TeacherData> _teachers = [
    TeacherData(
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
        SubjectData(name: 'Programación Avanzada', code: 'SIS301', students: 45, completed: 36, pending: 9),
        SubjectData(name: 'Bases de Datos II', code: 'SIS302', students: 38, completed: 30, pending: 8),
        SubjectData(name: 'Ingeniería de Software', code: 'SIS401', students: 45, completed: 36, pending: 9),
      ],
      avgRating: 4.3,
      period: '2025-1',
    ),
    TeacherData(
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
        SubjectData(name: 'Fundamentos de Administración', code: 'ADM101', students: 45, completed: 45, pending: 0),
        SubjectData(name: 'Gestión Empresarial', code: 'ADM201', students: 38, completed: 38, pending: 0),
      ],
      avgRating: 4.8,
      period: '2025-1',
    ),
    TeacherData(
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
        SubjectData(name: 'Algoritmos y Estructuras', code: 'SIS201', students: 42, completed: 18, pending: 24),
        SubjectData(name: 'Matemáticas Discretas', code: 'SIS202', students: 30, completed: 14, pending: 16),
      ],
      avgRating: 3.9,
      period: '2025-1',
    ),
    TeacherData(
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
        SubjectData(name: 'Derecho Constitucional', code: 'DER301', students: 48, completed: 45, pending: 3),
        SubjectData(name: 'Derecho Penal', code: 'DER302', students: 42, completed: 40, pending: 2),
        SubjectData(name: 'Derecho Civil', code: 'DER201', students: 40, completed: 38, pending: 2),
        SubjectData(name: 'Derecho Laboral', code: 'DER401', students: 35, completed: 29, pending: 6),
      ],
      avgRating: 4.6,
      period: '2025-1',
    ),
    TeacherData(
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
        SubjectData(name: 'Marketing Digital', code: 'ADM301', students: 40, completed: 26, pending: 14),
      ],
      avgRating: 4.1,
      period: '2025-1',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherData> get _filteredTeachers {
    var result = _teachers.where((teacher) {
      // Filtro de búsqueda
      final matchesSearch = teacher.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                            teacher.email.toLowerCase().contains(_searchTerm.toLowerCase());
      
      // Filtro de carrera
      final matchesCareer = (_filters['careers'] as List).contains('all') ||
                           (_filters['careers'] as List).contains(teacher.career);
      
      // Filtro de período
      final matchesPeriod = _filters['period'] == 'all' || teacher.period == _filters['period'];
      
      // Filtro de estado
      final matchesStatus = _filters['status'] == 'all' ||
                           (_filters['status'] == 'active' && teacher.activeEvaluations > 0) ||
                           (_filters['status'] == 'none' && teacher.activeEvaluations == 0);
      
      return matchesSearch && matchesCareer && matchesPeriod && matchesStatus;
    }).toList();

    // Ordenar
    result.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'evaluations':
          return b.activeEvaluations.compareTo(a.activeEvaluations);
        case 'completion':
          return a.completionRate.compareTo(b.completionRate);
        case 'activity':
          return b.lastActivity.compareTo(a.lastActivity);
        default:
          return 0;
      }
    });

    return result;
  }

  Map<String, dynamic> get _globalStats {
    final filtered = _filteredTeachers;
    final totalEvals = filtered.fold<int>(0, (sum, t) => sum + t.activeEvaluations);
    final avgCompletion = filtered.isEmpty
        ? 0.0
        : filtered.fold<int>(0, (sum, t) => sum + t.completionRate) / filtered.length;
    final totalStuds = filtered.fold<int>(0, (sum, t) => sum + t.totalStudents);

    return {
      'totalTeachers': filtered.length,
      'totalEvaluations': totalEvals,
      'avgCompletion': avgCompletion.toStringAsFixed(1),
      'totalStudents': totalStuds,
    };
  }

  void _toggleFilter(String category, String value) {
    setState(() {
      if (category == 'careers') {
        final current = _filters[category] as List<String>;
        if (value == 'all') {
          _filters[category] = ['all'];
        } else {
          final newCareers = current.contains(value)
              ? current.where((c) => c != value).toList()
              : [...current.where((c) => c != 'all'), value];
          _filters[category] = newCareers.isEmpty ? ['all'] : newCareers;
        }
      } else {
        _filters[category] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);
    final stats = _globalStats;

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Contenido desplazable
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // Header
                _buildHeader(),
                const SizedBox(height: 16),
              
                // Barra de búsqueda y filtros
                _buildSearchAndFilters(palette),
                const SizedBox(height: 16),

                // Estadísticas globales
                _buildGlobalStats(stats, palette),
                const SizedBox(height: 16),

                // Ordenamiento
                _buildSortingBar(),
                const SizedBox(height: 16),

                // Lista de docentes
                _filteredTeachers.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: _filteredTeachers
                            .map((teacher) => _buildTeacherCard(teacher, palette))
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50), // Verde fuerte (admin primary)
            Color(0xFF388E3C), // Verde muy oscuro (admin primaryDark)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Analisa los resultados de evaluaciones',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(RoleColorPalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchTerm = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showFilters ? palette.primary : Colors.grey[100],
                  foregroundColor: _showFilters ? Colors.white : Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.filter_list, size: 18),
                    SizedBox(width: 8),
                    Text('Filtros'),
                  ],
                ),
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildFiltersPanel(),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtro por carrera
        const Text('Carrera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('all', 'Todas', 'careers'),
            _buildFilterChip('ING-SIS', 'Ingeniería de Sistemas', 'careers'),
            _buildFilterChip('ADM-EMP', 'Administración', 'careers'),
            _buildFilterChip('DER', 'Derecho', 'careers'),
          ],
        ),
        const SizedBox(height: 16),

        // Filtro por período
        const Text('Período', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('2025-1', '2025-1 (actual)', 'period'),
            _buildFilterChip('2024-2', '2024-2', 'period'),
            _buildFilterChip('all', 'Todos', 'period'),
          ],
        ),
        const SizedBox(height: 16),

        // Filtro por estado
        const Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('all', 'Todos', 'status'),
            _buildFilterChip('active', 'Con evaluaciones activas', 'status'),
            _buildFilterChip('none', 'Sin evaluaciones', 'status'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, String category) {
    final isSelected = category == 'careers'
        ? (_filters[category] as List).contains(value)
        : _filters[category] == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _toggleFilter(category, value),
      selectedColor: AppColors.getPaletteForRole(UserRole.admin).primary.withOpacity(0.2),
      checkmarkColor: AppColors.getPaletteForRole(UserRole.admin).primary,
    );
  }

  Widget _buildGlobalStats(Map<String, dynamic> stats, RoleColorPalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Primera fila
          Row(
            children: [
              _buildStatCard(Icons.people, 'Docentes', '${stats['totalTeachers']}', Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard(Icons.book, 'Evaluaciones', '${stats['totalEvaluations']}', Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila
          Row(
            children: [
              _buildStatCard(Icons.trending_up, 'Completitud', '${stats['avgCompletion']}%', Colors.green),
              const SizedBox(width: 8),
              _buildStatCard(Icons.school, 'Estudiantes', '${stats['totalStudents']}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Ordenar por:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _sortBy,
              isExpanded: true,
              onChanged: (value) => setState(() => _sortBy = value!),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Nombre (A-Z)')),
                DropdownMenuItem(value: 'evaluations', child: Text('Evaluaciones activas')),
                DropdownMenuItem(value: 'completion', child: Text('Completitud (urgentes primero)')),
                DropdownMenuItem(value: 'activity', child: Text('Última actividad')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(TeacherData teacher, RoleColorPalette palette) {
    final isExpanded = _expandedTeacherId == teacher.id;
    final statusInfo = _getStatusInfo(teacher);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? palette.primary : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card colapsado
          InkWell(
            onTap: () => setState(() {
              _expandedTeacherId = isExpanded ? null : teacher.id;
            }),
            borderRadius: isExpanded 
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  )
                : BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: palette.avatarGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            teacher.name.split(' ')[0][0] + teacher.name.split(' ')[1][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCareerColor(teacher.career).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.getCareerColor(teacher.career).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    teacher.career,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${teacher.totalSubjects} materias • ${teacher.activeEvaluations} activas',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Barra de progreso
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completitud',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                          ),
                          Text(
                            '${teacher.completionRate}%',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: teacher.completionRate / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          teacher.completionRate < 50
                              ? Colors.red
                              : teacher.completionRate < 80
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Badge de estado
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo['color'],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusInfo['borderColor']),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusInfo['icon'], size: 12, color: statusInfo['textColor']),
                          const SizedBox(width: 4),
                          Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusInfo['textColor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card expandido
          if (isExpanded) ...[
            const Divider(height: 1),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    Row(
                      children: [
                        const Icon(Icons.email, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(teacher.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Materias
                    const Row(
                      children: [
                        Icon(Icons.book, size: 14),
                        SizedBox(width: 6),
                        Text('Materias', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...teacher.subjects.map((subject) => _buildSubjectItem(subject)),
                    const SizedBox(height: 16),

                    // Estadísticas
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bar_chart, size: 14),
                              SizedBox(width: 6),
                              Text('Estadísticas rápidas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Evaluaciones:', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    Text(
                                      '${teacher.activeEvaluations} activas, ${teacher.closedEvaluations} cerradas',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Respuestas:', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    Text(
                                      '${teacher.completedResponses}/${teacher.totalStudents} (${teacher.completionRate}%)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Período actual:', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    Text(
                                      teacher.period,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Última actividad:', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    Text(
                                      teacher.lastActivity,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botones de acción
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bar_chart, size: 18),
                        label: const Text('Ver Informe Completo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.email, size: 16),
                            label: const Text('Email', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Excel', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('Link', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectItem(SubjectData subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      subject.code,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${subject.students} estudiantes',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '✓ ${subject.completed} completadas',
                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Text(
                '⏳ ${subject.pending} pendientes',
                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron docentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros o el término de búsqueda',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(TeacherData teacher) {
    if (teacher.completionRate < 50) {
      return {
        'color': Colors.red[50],
        'borderColor': Colors.red[200],
        'textColor': Colors.red[700],
        'icon': Icons.warning,
        'text': 'Atención requerida',
      };
    } else if (teacher.completionRate < 80) {
      return {
        'color': Colors.orange[50],
        'borderColor': Colors.orange[200],
        'textColor': Colors.orange[700],
        'icon': Icons.trending_up,
        'text': 'En progreso',
      };
    } else {
      return {
        'color': Colors.green[50],
        'borderColor': Colors.green[200],
        'textColor': Colors.green[700],
        'icon': Icons.check_circle,
        'text': 'Excelente',
      };
    }
  }
}
