// lib/screens/admin/tabs/analysis_content.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/services/admin_analysis_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:provider/provider.dart';

/// Contenido de análisis administrativo
class AnalysisContent extends StatefulWidget {
  const AnalysisContent({super.key});

  @override
  State<AnalysisContent> createState() => _AnalysisContentState();
}

class _AnalysisContentState extends State<AnalysisContent> {
  // Controllers y estado de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  int? _expandedTeacherId;
  bool _showFilters = false;
  String _sortBy = 'name';
  
  // Filtros
  final Map<String, dynamic> _filters = {
    'careers': ['all'],
    'period': '2025-1',
    'status': 'all',
  };

  // Servicio de API
  late AdminAnalysisService _analysisService;

  // Estado de datos
  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _errorMessage;
  List<TeacherData> _teachers = [];
  AnalysisStats? _globalStats;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadData();
  }

  /// Inicializar servicio con configuración
  void _initializeService() {
    _analysisService = AdminAnalysisService(
      getToken: () => AuthStorageService.getToken(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Cargar datos desde la API
  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Determinar carrera seleccionada
      final selectedCareers = _filters['careers'] as List<String>;
      final career = selectedCareers.contains('all') || selectedCareers.isEmpty
          ? null
          : selectedCareers.first;

      // Cargar datos en paralelo
      final results = await Future.wait([
        _analysisService.getTeachersAnalysis(
          periodo: _filters['period'] as String,
          career: career,
          sortBy: _sortBy,
        ),
        _analysisService.getAnalysisStats(
          periodo: _filters['period'] as String,
          career: career,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        final analysisResponse = results[0] as TeachersAnalysisResponse;
        _teachers = analysisResponse.teachers;
        _globalStats = results[1] as AnalysisStats;
        _isLoading = false;
        _isInitialLoad = false;
      });
    } on UnauthorizedException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _isInitialLoad = false;
      });
      _showErrorSnackBar(e.message);
      // Aquí podrías navegar al login
    } on ForbiddenException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _isInitialLoad = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isInitialLoad = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Mostrar mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: _loadData,
        ),
      ),
    );
  }

  /// Aplicar filtros locales a los datos cargados
  List<TeacherData> get _filteredTeachers {
    return _teachers.where((teacher) {
      // Filtro de búsqueda
      final matchesSearch = teacher.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                            teacher.email.toLowerCase().contains(_searchTerm.toLowerCase());
      
      // Filtro de estado (se aplica localmente)
      final matchesStatus = _filters['status'] == 'all' ||
                           (_filters['status'] == 'active' && teacher.activeEvaluations > 0) ||
                           (_filters['status'] == 'none' && teacher.activeEvaluations == 0);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  /// Cambiar filtro y recargar si es necesario
  void _toggleFilter(String category, String value) {
    bool shouldReload = false;
    
    setState(() {
      if (category == 'careers') {
        final current = _filters[category] as List<String>;
        if (value == 'all') {
          _filters[category] = ['all'];
          shouldReload = true;
        } else {
          final newCareers = current.contains(value)
              ? current.where((c) => c != value).toList()
              : [...current.where((c) => c != 'all'), value];
          _filters[category] = newCareers.isEmpty ? ['all'] : newCareers;
          shouldReload = true;
        }
      } else if (category == 'period') {
        if (_filters[category] != value) {
          _filters[category] = value;
          shouldReload = true;
        }
      } else {
        _filters[category] = value;
        // 'status' es filtro local, no requiere recarga
      }
    });

    if (shouldReload) {
      _loadData();
    }
  }

  /// Cambiar ordenamiento
  void _changeSortBy(String? newSortBy) {
    if (newSortBy != null && _sortBy != newSortBy) {
      setState(() {
        _sortBy = newSortBy;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isInitialLoad
                  ? _buildInitialLoadingState()
                  : _buildContent(palette),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de carga inicial
  Widget _buildInitialLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando análisis...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Contenido principal
  Widget _buildContent(RoleColorPalette palette) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        
        _buildSearchAndFilters(palette),
        const SizedBox(height: 16),

        // Mostrar error si existe
        if (_errorMessage != null && !_isLoading)
          _buildErrorBanner(),
        
        if (_errorMessage == null) ...[
          _buildGlobalStats(palette),
          const SizedBox(height: 16),

          _buildSortingBar(),
          const SizedBox(height: 16),

          // Loading overlay al recargar
          if (_isLoading)
            _buildLoadingOverlay()
          else
            _filteredTeachers.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: _filteredTeachers
                        .map((teacher) => _buildTeacherCard(teacher, palette))
                        .toList(),
                  ),
        ] else
          _buildErrorState(),
      ],
    );
  }

  /// Banner de error
  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ),
          TextButton(
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Overlay de carga
  Widget _buildLoadingOverlay() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Estado de error completo
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
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
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
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
                      'Analiza los resultados de evaluaciones',
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
                    hintText: 'Nombre o Email',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchTerm = '');
                            },
                          )
                        : null,
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

  Widget _buildGlobalStats(RoleColorPalette palette) {
    if (_globalStats == null) return const SizedBox.shrink();

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
              _buildStatCard(Icons.people, 'Docentes', '${_globalStats!.totalTeachers}', Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard(Icons.book, 'Evaluaciones', '${_globalStats!.totalEvaluations}', Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(Icons.trending_up, 'Completitud', '${_globalStats!.avgCompletion}%', Colors.green),
              const SizedBox(width: 8),
              _buildStatCard(Icons.school, 'Estudiantes', '${_globalStats!.totalStudents}', Colors.orange),
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
              onChanged: _changeSortBy,
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: palette.avatarGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(teacher.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                if (teacher.career.isNotEmpty)
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
                          _getCompletionColor(teacher.completionRate),
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                    Row(
                      children: [
                        const Icon(Icons.email, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            teacher.email,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navegar a informe detallado
                        },
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
                            onPressed: () {
                              // TODO: Enviar email
                            },
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
                            onPressed: () {
                              // TODO: Exportar a Excel
                            },
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
                            onPressed: () {
                              // TODO: Compartir link
                            },
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

  // ==============================================
  // MÉTODOS AUXILIARES
  // ==============================================

  /// Obtener iniciales del nombre
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Obtener color según tasa de completitud
  Color _getCompletionColor(int rate) {
    if (rate < 50) return Colors.red;
    if (rate < 80) return Colors.orange;
    return Colors.green;
  }

  /// Obtener información de estado del docente
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
