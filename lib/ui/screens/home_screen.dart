import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_sync_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/common/app_event.dart';
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

  String _claveEvento(AppEvent evento) {
    final d = evento.fecha.toLocal();
    return '${evento.titulo.trim().toLowerCase()}|'
        '${d.year}-${d.month}-${d.day}';
  }

  /// Combina los eventos locales con los importados de Google, evitando
  /// duplicados cuando ambos representan el mismo evento.
  List<AppEvent> _combinarEventos(
    List<AppEvent> locales,
    List<AppEvent> deGoogle,
  ) {
    final claves = locales.map(_claveEvento).toSet();
    return [
      ...locales,
      ...deGoogle.where((evento) => !claves.contains(_claveEvento(evento))),
    ];
  }

  Future<void> _sincronizar(
    UsuarioProvider prov,
    AuthProvider auth,
  ) async {
    final calendar = context.read<CalendarSyncProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('Sincronizando con Google Calendar...'),
      backgroundColor: AppTheme.bgCard,
      behavior: SnackBarBehavior.floating,
    ));

    await calendar.sincronizar(eventosLocales: prov.todosLosEventos);
    if (!mounted) return;
    messenger.hideCurrentSnackBar();

    if (calendar.error != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(calendar.error!),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        action: calendar.sinPermiso
            ? SnackBarAction(
                label: 'CONECTAR',
                textColor: Colors.white,
                onPressed: () => _conectarGoogle(auth),
              )
            : null,
      ));
    } else {
      final limpiados = calendar.ultimosEliminados > 0
          ? ' · ${calendar.ultimosEliminados} duplicados limpiados'
          : '';
      messenger.showSnackBar(SnackBar(
        content: Text(
          '✅ Google Calendar: ${calendar.ultimosImportados} importados y '
          '${calendar.ultimosEnviados} enviados$limpiados.',
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _conectarGoogle(AuthProvider auth) async {
    final ok = await auth.loginConGoogle();
    if (!mounted) return;
    if (ok) {
      final calendar = context.read<CalendarSyncProvider>();
      final prov = context.read<UsuarioProvider>();
      await calendar.sincronizar(eventosLocales: prov.todosLosEventos);
      if (!mounted) return;
      final detalle = auth.calendarError ?? calendar.error;
      if (detalle != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(detalle),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'No se pudo conectar con Google.'),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UsuarioProvider>();
    final authProv = context.read<AuthProvider>();
    final calendarProv = context.watch<CalendarSyncProvider>();
    final allEvents = _combinarEventos(
      prov.todosLosEventos,
      calendarProv.eventosGoogle,
    );
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
            icon: calendarProv.syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentGlow,
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: AppTheme.accentGlow),
            tooltip: 'Sincronizar con Google Calendar',
            onPressed: calendarProv.syncing
                ? null
                : () => _sincronizar(prov, authProv),
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
              boxShadow: [BoxShadow(color: const Color(0xFF2E3A34).withValues(alpha: 0.07), blurRadius: 15, offset: const Offset(0, 5))],
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
              lastDay: DateTime.now().add(const Duration(days: 730)),
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
                weekendTextStyle: const TextStyle(color: AppTheme.accentGlow),
                outsideTextStyle: const TextStyle(color: AppTheme.textSecondary),
                todayDecoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 1.5),
                ),
                todayTextStyle: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                selectedDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                markerSize: 5.5,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.accentGlow),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.accentGlow),
                formatButtonTextStyle: TextStyle(color: AppTheme.accent, fontSize: 12),
                formatButtonDecoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(color: AppTheme.accent)),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(color: AppTheme.accentGlow, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // LISTA DE EVENTOS DEL DÍA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildCalendarStatus(calendarProv, authProv),
                if (selectedEvents.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.event_note_rounded, color: AppTheme.accentGlow, size: 18),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columnas = constraints.maxWidth > 840 ? 4 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: columnas,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columnas == 4 ? 2.9 : 2.3,
                      children: [
                        _buildQuickCard(context, 'Familia', Icons.group_rounded, AppTheme.accent, const UsuariosScreen()),
                        _buildQuickCard(context, 'Vivienda', Icons.home_rounded, const Color(0xFFFBBF24), const HogarScreen()),
                        _buildQuickCard(context, 'Gestión', Icons.settings_suggest_rounded, const Color(0xFF34D399), const GestionScreen()),
                        if (prov.familia.isNotEmpty)
                          _buildQuickCard(context, 'Estudios', Icons.school_rounded, const Color(0xFFF87171), EducacionScreen(persona: prov.familia[0])),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStatus(
    CalendarSyncProvider calendar,
    AuthProvider auth,
  ) {
    if (calendar.error != null) {
      final sinPermiso = calendar.sinPermiso;
      final detalle = calendar.error!;
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0EA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              sinPermiso ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
              color: sinPermiso ? AppTheme.textSecondary : AppTheme.dangerRed,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sinPermiso
                        ? 'Google Calendar no está conectado'
                        : 'No se pudo sincronizar el calendario',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: sinPermiso ? AppTheme.textSecondary : AppTheme.dangerRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => sinPermiso
                  ? _conectarGoogle(auth)
                  : _sincronizar(context.read<UsuarioProvider>(), auth),
              child: Text(
                sinPermiso ? 'Conectar' : 'Reintentar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    if (calendar.syncing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF5F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Sincronizando con Google Calendar...',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (calendar.lastSync != null) {
      final subidos = calendar.ultimosEnviados;
      final importados = calendar.ultimosImportados;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            const Icon(Icons.cloud_done_rounded,
                color: AppTheme.accent, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Google Calendar · ${DateFormat('HH:mm').format(calendar.lastSync!)}'
                ' · ↑ $subidos enviados · ↓ $importados recibidos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEventCard(AppEvent ev) {
    final hora = ev.fecha.toLocal();
    final mostrarHora = ev.desdeGoogle &&
        (hora.hour != 0 || hora.minute != 0);

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
        subtitle: Text(
          mostrarHora
              ? '${DateFormat('HH:mm').format(hora)} · ${ev.descripcion}'
              : ev.descripcion,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ev.desdeGoogle
            ? const Tooltip(
                message: 'Evento de Google Calendar',
                child: Icon(Icons.cloud_done_rounded,
                    color: Color(0xFF4C8BF5), size: 18),
              )
            : const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 18),
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