import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/common/app_event.dart';
import '../../services/google_calendar_service.dart';
import '../theme/app_theme.dart';
import 'usuarios_screen.dart';
import 'hogar_screen.dart';
import 'gestion_screen.dart';
import 'educacion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<AppEvent> _getEventsForDay(DateTime day, List<AppEvent> allEvents) {
    return allEvents.where((event) => isSameDay(event.fecha, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UsuarioProvider>();
    final authProv = context.read<AuthProvider>();
    final allEvents = prov.todosLosEventos;
    final selectedEvents = _getEventsForDay(_selectedDay!, allEvents);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('AppHome', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontSize: 20)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppTheme.accentLight),
            tooltip: 'Sincronizar con Google Calendar',
            onPressed: () async {
              final calendarService = GoogleCalendarService(authProv.googleSignIn);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronizando con Google Calendar...'),
                  backgroundColor: AppTheme.bgCard,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              try {
                await calendarService.syncEvents(prov.todosLosEventos);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Sincronización completada'),
                      backgroundColor: AppTheme.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: AppTheme.dangerRed,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 8),
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.bgCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Cerrar sesión', style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text('¿Estás seguro?', style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: AppTheme.textSecondary))),
                    TextButton(
                      onPressed: () { context.read<AuthProvider>().cerrarSesion(); Navigator.pop(context); },
                      child: const Text('SALIR', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // CALENDARIO DARK
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              border: const Border(
                bottom: BorderSide(color: AppTheme.borderColor),
                left: BorderSide(color: AppTheme.borderColor),
                right: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 8),
            child: TableCalendar<AppEvent>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: 'es_ES',
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              eventLoader: (day) => _getEventsForDay(day, allEvents),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
                weekendTextStyle: const TextStyle(color: AppTheme.accentLight),
                outsideTextStyle: const TextStyle(color: AppTheme.textSecondary),
                todayDecoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 1.5),
                ),
                todayTextStyle: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                selectedDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: BoxDecoration(color: AppTheme.accentLight, shape: BoxShape.circle),
                markerSize: 5.5,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.accentLight),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.accentLight),
                formatButtonTextStyle: TextStyle(color: AppTheme.accent, fontSize: 12),
                formatButtonDecoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(color: AppTheme.accent)),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(color: AppTheme.accentLight, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // LISTA DE EVENTOS DEL DÍA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (selectedEvents.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.event_note_rounded, color: AppTheme.accentLight, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMMM', 'es_ES').format(_selectedDay!),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('${selectedEvents.length}', style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ...selectedEvents.map((ev) => _buildEventCard(ev)),
                ] else ...[
                  const SizedBox(height: 30),
                  const Center(
                    child: Column(children: [
                      Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.borderColor),
                      SizedBox(height: 12),
                      Text('Sin eventos para este día', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ]),
                  ),
                ],

                const SizedBox(height: 28),
                const Text('Accesos Directos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    _buildQuickCard(context, 'Familia', Icons.group_rounded, AppTheme.accentLight, const UsuariosScreen()),
                    _buildQuickCard(context, 'Vivienda', Icons.home_rounded, const Color(0xFFFBBF24), const HogarScreen()),
                    _buildQuickCard(context, 'Gestión', Icons.settings_suggest_rounded, const Color(0xFF34D399), const GestionScreen()),
                    if (prov.familia.isNotEmpty)
                      _buildQuickCard(context, 'Estudios', Icons.school_rounded, const Color(0xFFF87171), EducacionScreen(persona: prov.familia[0])),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(AppEvent ev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ev.color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: ev.color.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: ev.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(ev.icono, color: ev.color, size: 20),
        ),
        title: Text(ev.titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
        subtitle: Text(ev.descripcion, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 18),
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}