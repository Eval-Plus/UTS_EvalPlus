/// Contenido de configuración para ADMINISTRADORES
/// Panel de sincronización y gestión del sistema - INTEGRADO CON BACKEND

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin_dashboard_model.dart';
import 'package:eval_plus/services/admin_dashboard_service.dart';
import 'package:eval_plus/config/app_colors.dart';

import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class ConfigContent extends StatefulWidget {
  const ConfigContent({super.key});

  @override
  State<ConfigContent> createState() => _ConfigContentState();
}

class _ConfigContentState extends State<ConfigContent> {
  late final AdminDashboardService _dashboardService;
  
  // Paleta de colores del rol admin
  final _adminPalette = AppColors.getPaletteForRole(UserRole.admin);
  
  // Paleta de verdes complementarios para diferenciación visual
  static const Color _emeraldColor = Color(0xFF2ECC71);    // Verde esmeralda para estudiantes
  static const Color _emeraldDark = Color(0xFF27AE60);
  static const Color _limeColor = Color(0xFF8BC34A);      // Verde lima para docentes
  static const Color _limeDark = Color(0xFF689F38);
  static const Color _tealColor = Color(0xFF009688);      // Verde azulado para evaluaciones
  static const Color _tealDark = Color(0xFF00796B);
  
  // Estado de carga para cada acción
  final Map<String, bool> _loadingStates = {
    'sync-students': false,
    'enroll-teachers': false,
    'generate-evaluations': false,
  };

  // Datos del dashboard
  AdminDashboardModel? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _dashboardService = AdminDashboardService();
    
    debugPrint('🎯 [Config] Inicializando...');
    _dashboardService.addListener(_onDashboardChanged);
    
    _loadDashboard();
  }

  @override
  void dispose() {
    debugPrint('🎯 [Config] Desuscribiéndose del servicio...');
    _dashboardService.removeListener(_onDashboardChanged);
    super.dispose();
  }

  void _onDashboardChanged() {
    debugPrint('🔔 [Config] Notificación recibida: Recargando dashboard...');
    _loadDashboard(forceRefresh: true);
  }

  Future<void> _loadDashboard({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📊 [Config] Cargando dashboard...');
      final dashboard = await _dashboardService.getDashboard(
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _isLoading = false;
        });
        debugPrint('✅ [Config] Dashboard cargado exitosamente');
      }
    } catch (e) {
      debugPrint('💥 [Config] Error cargando dashboard: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar dashboard: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAction(String action) async {
    if (_dashboard == null) return;
    
    final stats = _dashboard!.stats;
    
    // Validaciones previas para evitar llamadas innecesarias a la API
    if (action == 'sync-students' && stats.pendingStudents == 0) {
      _showInfoDialog(
        title: 'Sin estudiantes pendientes',
        message: 'Todos los estudiantes ya están sincronizados. No hay acciones pendientes por realizar.',
        color: _emeraldColor,
        icon: Icons.check_circle_outline,
      );
      return;
    }
    
    if (action == 'enroll-teachers' && stats.pendingTeachers == 0) {
      _showInfoDialog(
        title: 'Sin docentes pendientes',
        message: 'Todos los docentes ya están inscritos en sus materias. No hay acciones pendientes por realizar.',
        color: _limeColor,
        icon: Icons.check_circle_outline,
      );
      return;
    }
    
    if (action == 'generate-evaluations' && stats.activeEvaluations > 0) {
      _showInfoDialog(
        title: 'Evaluaciones ya generadas',
        message: 'Ya existen ${stats.activeEvaluations} evaluaciones activas en el sistema. No es necesario generar nuevas en este momento.',
        color: _tealColor,
        icon: Icons.assignment_turned_in,
      );
      return;
    }
    
    setState(() {
      _loadingStates[action] = true;
    });

    try {
      String message;
      
      switch (action) {
        case 'sync-students':
          final result = await _dashboardService.syncStudents();
          message = 'Sincronización completada: ${result['exitosos']} estudiantes procesados';
          break;
          
        case 'enroll-teachers':
          final result = await _dashboardService.syncTeachers();
          message = 'Sincronización completada: ${result['exitosos']} profesores procesados';
          break;
          
        case 'generate-evaluations':
          final now = DateTime.now();
          final fechaCierre = now.add(const Duration(days: 90));
          
          final result = await _dashboardService.generateEvaluations(
            periodo: _dashboard!.periodo,
            fechaInicio: now,
            fechaCierre: fechaCierre,
          );
          message = 'Evaluaciones generadas: ${result['creadas']} creadas';
          break;
          
        default:
          message = 'Acción no implementada';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: _adminPalette.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        await _loadDashboard(forceRefresh: true);
      }
    } catch (e) {
      debugPrint('💥 [Config] Error en acción $action: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates[action] = false;
        });
      }
    }
  }
  
  void _showInfoDialog({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget(
        type: MessageType.info,
        title: title,
        message: message,
        customIcon: icon,
        customColor: color, // 🎨 Aplica el color específico de cada sincronización
        onPrimaryAction: () => Navigator.of(context).pop(),
        primaryButtonText: 'Entendido',
        barrierDismissible: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadDashboard(forceRefresh: true),
      color: _adminPalette.primary,
      child: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _adminPalette.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando dashboard...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDashboard(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _adminPalette.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_dashboard == null) {
      return const SizedBox.shrink();
    }

    final stats = _dashboard!.stats;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Header con estadísticas reales
            _buildHeader(stats),
            
            const SizedBox(height: 24),
            
            // Estado del Sistema
            _buildSystemStatus(stats),
            
            const SizedBox(height: 24),
            
            // Acciones Principales
            _buildMainActions(stats),
            
            const SizedBox(height: 20),
            
            // Nota informativa
            _buildInfoBanner(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardStats stats) {
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
                  Icons.settings,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Periodo: ${_dashboard!.periodo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Grid de estadísticas reales
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.people_rounded,
                      label: 'Estudiantes',
                      value: '${stats.totalStudents}',
                      subtitle: '${stats.syncedStudents} sincronizados',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.school_rounded,
                      label: 'Docentes',
                      value: '${stats.totalTeachers}',
                      subtitle: '${stats.enrolledTeachers} inscritos',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.assignment_rounded,
                      label: 'Evaluaciones',
                      value: '${stats.totalEvaluations}',
                      subtitle: '${stats.activeEvaluations} activas',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.trending_up_rounded,
                      label: 'Completadas',
                      value: '${stats.completedEvaluations}',
                      subtitle: '${stats.evaluationsCompletionRate.toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSystemStatus(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers_rounded,
                color: _adminPalette.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado del Sistema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Barra de progreso - Estudiantes (Verde esmeralda)
          _buildProgressCard(
            title: 'Estudiantes Inscritos',
            current: stats.syncedStudents,
            total: stats.totalStudents,
            percentage: stats.studentsSyncRate,
            icon: Icons.people_rounded,
            color: _emeraldColor,
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso - Docentes (Verde lima)
          _buildProgressCard(
            title: 'Docentes Inscritos',
            current: stats.enrolledTeachers,
            total: stats.totalTeachers,
            percentage: stats.teachersEnrollRate,
            icon: Icons.school_rounded,
            color: _limeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required int current,
    required int total,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    final backgroundColor = Color.alphaBlend(
      color.withOpacity(0.1),
      Colors.white,
    );
    final borderColor = Color.alphaBlend(
      color.withOpacity(0.3),
      Colors.white,
    );
    final textColor = Color.fromRGBO(
      (color.red * 0.7).toInt(),
      (color.green * 0.7).toInt(),
      (color.blue * 0.7).toInt(),
      1.0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current de $total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${total - current} pendientes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_rounded,
                color: _adminPalette.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Acciones de Sincronización',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Botón 1: Sincronizar Estudiantes (Verde esmeralda)
          _buildActionCard(
            icon: Icons.people_rounded,
            title: 'Sincronizar Estudiantes',
            description:
                'Asocia estudiantes registrados con sus respectivas materias del sistema académico',
            actionLabel: 'Sincronizar Ahora',
            actionKey: 'sync-students',
            gradient: const LinearGradient(
              colors: [_emeraldColor, _emeraldDark],
            ),
            stats: [
              {'label': 'Total', 'value': stats.totalStudents},
              {'label': 'Sincronizados', 'value': stats.syncedStudents},
              {'label': 'Pendientes', 'value': stats.pendingStudents},
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón 2: Inscribir Docentes (Verde lima)
          _buildActionCard(
            icon: Icons.school_rounded,
            title: 'Inscribir Docentes',
            description:
                'Asigna docentes a las materias correspondientes según el registro académico',
            actionLabel: 'Inscribir Ahora',
            actionKey: 'enroll-teachers',
            gradient: const LinearGradient(
              colors: [_limeColor, _limeDark],
            ),
            stats: [
              {'label': 'Total', 'value': stats.totalTeachers},
              {'label': 'Inscritos', 'value': stats.enrolledTeachers},
              {'label': 'Pendientes', 'value': stats.pendingTeachers},
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón 3: Generar Evaluaciones (Verde azulado)
          _buildActionCard(
            icon: Icons.assignment_rounded,
            title: 'Generar Evaluaciones',
            description:
                'Crea evaluaciones masivas para materias con docentes y estudiantes asignados',
            actionLabel: 'Generar Ahora',
            actionKey: 'generate-evaluations',
            gradient: const LinearGradient(
              colors: [_tealColor, _tealDark],
            ),
            stats: [
              {'label': 'Existentes', 'value': stats.totalEvaluations},
              {'label': 'Activas', 'value': stats.activeEvaluations},
              {'label': 'Cerradas', 'value': stats.closedEvaluations},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required String actionLabel,
    required String actionKey,
    required LinearGradient gradient,
    required List<Map<String, dynamic>> stats,
  }) {
    final isLoading = _loadingStates[actionKey] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Mini estadísticas
          Row(
            children: stats.map((stat) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${stat['value']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat['label'],
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: isLoading ? null : () => _handleAction(actionKey),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Procesando...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _adminPalette.chipBackground,
        border: Border.all(color: _adminPalette.borderColor(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_rounded,
            color: _adminPalette.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información importante',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _adminPalette.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Las sincronizaciones pueden tardar varios minutos dependiendo del volumen de datos. '
                  'Se recomienda ejecutar estas acciones en horarios de baja actividad del sistema.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _adminPalette.primaryDark.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
