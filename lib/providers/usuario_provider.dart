import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuarios/persona.dart';
import '../models/hogar/propiedad.dart';
import '../models/gestion/item_compra.dart';
import '../models/gestion/suscripcion.dart';
import '../models/gestion/suministro.dart';
import '../models/gestion/menu_dia.dart';
import '../models/common/app_event.dart';

class UsuarioProvider extends ChangeNotifier {
  FirebaseFirestore? _db;
  String? _userId;
  String? _familyId; // El ID compartido para los datos de la casa

  List<Persona> _familia = [];
  final List<ItemCompra> _listaCompra = [];
  final List<Suscripcion> _suscripciones = [];
  final List<Suministro> _suministros = [];
  late List<MenuDia> _menuSemanal;
  final List<Propiedad> _propiedades = [];

  // Getter seguro para Firestore
  FirebaseFirestore? get db {
    try {
      if (Firebase.apps.isEmpty) return null;
      return _db ??= FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore no disponible: $e");
      return null;
    }
  }

  // Caché de eventos para el calendario
  List<AppEvent>? _cacheEventos;
  final bool _isLoading = false;

  // Listeners de Firestore: hay que cancelarlos al cerrar sesión o cambiar de familia
  final List<StreamSubscription<dynamic>> _listeners = [];

  void _cancelarListeners() {
    for (final sub in _listeners) {
      sub.cancel();
    }
    _listeners.clear();
  }

  UsuarioProvider() {
    _resetMenu();
  }

  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get familyId => _familyId;

  // Los modelos y listas se mantienen para la UI
  List<Persona> get familia => _familia;
  List<ItemCompra> get listaCompra => _listaCompra;
  List<Suscripcion> get suscripciones => _suscripciones;
  List<Suministro> get suministros => _suministros;
  List<MenuDia> get menuSemanal => _menuSemanal;
  List<Propiedad> get propiedades => _propiedades;

  void _resetMenu() {
    _menuSemanal = [
      MenuDia(diaSemana: 'Lunes'),
      MenuDia(diaSemana: 'Martes'),
      MenuDia(diaSemana: 'Miércoles'),
      MenuDia(diaSemana: 'Jueves'),
      MenuDia(diaSemana: 'Viernes'),
      MenuDia(diaSemana: 'Sábado'),
      MenuDia(diaSemana: 'Domingo'),
    ];
  }

  // --- MÉTODOS DE INICIALIZACIÓN (ProxyProvider) ---
  void updateUserInfo(String? uid, String? email) {
    debugPrint("USUARIO_PROVIDER: updateUserInfo llamado con UID '$uid' y Email '$email'");
    if (_userId == uid) return;
    _userId = uid;
    
    if (_userId != null) {
      // Usamos el email como base para el ID de familia (eliminando puntos que molestan a firestore)
      _familyId = email?.replaceAll('.', '_') ?? _userId; 
      _inicializarFirestore();
    } else {
      _limpiarDatos();
    }
  }

  void setManualFamilyId(String email) {
    _familyId = email.replaceAll('.', '_');
    debugPrint("USUARIO_PROVIDER: Cambio manual de familia a $_familyId");
    _inicializarFirestore();
  }

  void _limpiarDatos() {
    _cancelarListeners();
    _familia = [];
    _listaCompra.clear();
    _suscripciones.clear();
    _suministros.clear();
    _propiedades.clear();
    _resetMenu();
    notifyListeners();
  }

  // --- CARGA DESDE FIRESTORE (REACTIVA) ---
  void _inicializarFirestore() {
    if (_userId == null || _familyId == null || db == null) return;

    _cancelarListeners();
    _migrarDatosSiEsNecesario();

    debugPrint("FIRESTORE: Iniciando sincronización reactiva para familia $_familyId");

    // 1. Familia (Subcolección)
    _listeners.add(db!.collection('familias').doc(_familyId).collection('miembros').snapshots().listen((snap) {
      debugPrint("FIRESTORE: Update Familia -> ${snap.docs.length} miembros");
      _familia = snap.docs.map((doc) => Persona.fromMap(doc.data())).toList();
      _cacheEventos = null;
      notifyListeners();
    }, onError: (e) => debugPrint("Error en stream familia: $e")));

    // 2. Propiedades (Subcolección)
    _listeners.add(db!.collection('familias').doc(_familyId).collection('propiedades').snapshots().listen((snap) {
      debugPrint("FIRESTORE: Update Propiedades -> ${snap.docs.length} docs");
      _propiedades.clear();
      _propiedades.addAll(snap.docs.map((doc) => Propiedad.fromMap(doc.data())));
      notifyListeners();
    }, onError: (e) => debugPrint("Error en stream propiedades: $e")));

    // 3. Gestión (Documento único de configuración)
    _listeners.add(db!.collection('familias').doc(_familyId).collection('gestion').doc('datos').snapshots().listen((docSnap) {
      if (docSnap.exists) {
        final data = docSnap.data()!;
        debugPrint("FIRESTORE: Update Gestión (listaCompra, suministros, etc.)");
        
        if (data['listaCompra'] != null) {
          _listaCompra.clear();
          _listaCompra.addAll((data['listaCompra'] as List).map((i) => ItemCompra.fromMap(i)));
        }
        if (data['suscripciones'] != null) {
          _suscripciones.clear();
          _suscripciones.addAll((data['suscripciones'] as List).map((i) => Suscripcion.fromMap(i)));
        }
        if (data['suministros'] != null) {
          _suministros.clear();
          _suministros.addAll((data['suministros'] as List).map((i) => Suministro.fromMap(i)));
        }
        if (data['menuSemanal'] != null) {
          _menuSemanal = (data['menuSemanal'] as List).map((m) => MenuDia.fromMap(m)).toList();
        }
        notifyListeners();
      }
    }, onError: (e) => debugPrint("Error en stream gestión: $e")));
  }

  // --- MÉTODOS DE PERSISTENCIA PÚBLICOS ---
  
  Future<void> notify({Persona? personaParaGuardar, Propiedad? propiedadParaGuardar, bool guardarGestion = false}) async {
    if (_familyId == null || db == null) return;
    
    if (personaParaGuardar != null) {
      await db!.collection('familias').doc(_familyId).collection('miembros').doc(personaParaGuardar.dni).set(personaParaGuardar.toMap());
    }
    if (propiedadParaGuardar != null) {
      await db!.collection('familias').doc(_familyId).collection('propiedades').doc(propiedadParaGuardar.alias).set(propiedadParaGuardar.toMap());
    }
    if (guardarGestion) {
      await _guardarGestion();
    }
    notifyListeners();
  }

  // --- MÉTODOS LISTA DE COMPRA ---
  void toggleItemCompra(int index) {
    _listaCompra[index].estaComprado = !_listaCompra[index].estaComprado;
    notifyListeners();
    _guardarGestion();
  }

  Future<void> addItemCompra(ItemCompra item) async {
    _listaCompra.add(item);
    notifyListeners();
    await _guardarGestion();
  }

  Future<void> removeItemCompra(ItemCompra item) async {
    _listaCompra.remove(item);
    notifyListeners();
    await _guardarGestion();
  }

  // --- MÉTODOS SUSCRIPCIONES ---
  Future<void> addSuscripcion(Suscripcion s) async {
    _suscripciones.add(s);
    notifyListeners();
    await _guardarGestion();
  }

  Future<void> removeSuscripcion(Suscripcion s) async {
    _suscripciones.remove(s);
    notifyListeners();
    await _guardarGestion();
  }

  // --- MÉTODOS SUMINISTROS ---
  Future<void> addSuministro(Suministro s) async {
    _suministros.add(s);
    notifyListeners();
    await _guardarGestion();
  }

  Future<void> removeSuministro(Suministro s) async {
    _suministros.remove(s);
    notifyListeners();
    await _guardarGestion();
  }

  // --- MENÚ SEMANAL ---
  Future<void> actualizarMenu(int index, String? desayuno, String? almuerzo, String? cena) async {
    _menuSemanal[index].desayuno = desayuno;
    _menuSemanal[index].almuerzo = almuerzo;
    _menuSemanal[index].cena = cena;
    notifyListeners();
    await _guardarGestion();
  }

  @override
  void notifyListeners() {
    _cacheEventos = null;
    super.notifyListeners();
  }

  // --- MÉTODOS HOGAR ---
  Future<void> addPropiedad(Propiedad p) async {
    _propiedades.add(p);
    notifyListeners();
    await db!.collection('familias').doc(_familyId).collection('propiedades').doc(p.alias).set(p.toMap());
  }

  Future<void> removePropiedad(Propiedad p) async {
    await db!.collection('familias').doc(_familyId).collection('propiedades').doc(p.alias).delete();
    _propiedades.remove(p);
    notifyListeners();
  }

  // --- MÉTODOS MIGRACIÓN ---
  Future<void> _migrarDatosSiEsNecesario() async {
    if (_userId == null || db == null) return;
    
    // Verificamos si ya hay datos en la nueva ruta
    final docMiembros = await db!.collection('familias').doc(_familyId).collection('miembros').limit(1).get();
    if (docMiembros.docs.isNotEmpty) return; // Ya migrado o ya hay datos

    debugPrint("MIGRACIÓN: Detectados datos antiguos, procediendo a migrar a Familia...");

    // Migrar miembros (antigua ruta: usuarios/uid/familia)
    final viejosMiembros = await db!.collection('usuarios').doc(_userId).collection('familia').get();
    for (var d in viejosMiembros.docs) {
      await db!.collection('familias').doc(_familyId).collection('miembros').doc(d.id).set(d.data());
    }

    // Migrar propiedades (antigua ruta: usuarios/uid/propiedades)
    final viejasProps = await db!.collection('usuarios').doc(_userId).collection('propiedades').get();
    for (var d in viejasProps.docs) {
      await db!.collection('familias').doc(_familyId).collection('propiedades').doc(d.id).set(d.data());
    }

    // Migrar gestión
    final viejaGestion = await db!.collection('usuarios').doc(_userId).collection('gestion').doc('datos').get();
    if (viejaGestion.exists) {
      await db!.collection('familias').doc(_familyId).collection('gestion').doc('datos').set(viejaGestion.data()!);
    }
  }

  // --- MÉTODOS FAMILIA ---
  Future<void> addPersona(Persona p) async {
    _familia.add(p);
    notifyListeners();
    await db!.collection('familias').doc(_familyId).collection('miembros').doc(p.dni).set(p.toMap());
  }

  Future<void> removePersona(int index) async {
    final p = _familia[index];
    await db!.collection('familias').doc(_familyId).collection('miembros').doc(p.dni).delete();
    _familia.removeAt(index);
    notifyListeners();
  }

  // --- PERSISTENCIA PRIVADA ---
  Future<void> _guardarGestion() async {
    if (_familyId == null || db == null) return;
    await db!.collection('familias').doc(_familyId).collection('gestion').doc('datos').set({
      'listaCompra': _listaCompra.map((i) => i.toMap()).toList(),
      'suscripciones': _suscripciones.map((i) => i.toMap()).toList(),
      'suministros': _suministros.map((i) => i.toMap()).toList(),
      'menuSemanal': _menuSemanal.map((m) => m.toMap()).toList(),
    });
  }

  // --- CALENDARIO (UNIFICADO) ---
  List<AppEvent> get todosLosEventos {
    if (_cacheEventos != null) return _cacheEventos!;
    
    final lista = <AppEvent>[];
    
    // 1. Citas Médicas
    for (var p in _familia) {
      for (var c in p.citas) {
        lista.add(AppEvent(
          titulo: 'Cita Médica: ${p.nombre}',
          descripcion: c.especialidad,
          fecha: c.fecha,
          color: Colors.red,
          icono: Icons.medical_services,
          tipo: TipoEvento.salud,
        ));
      }
      // 2. Eventos Escolares
      if (p.rolEstudiante != null) {
        for (var e in p.rolEstudiante!.eventos) {
          lista.add(AppEvent(
            titulo: e.tipo.trim().isEmpty ? 'Evento escolar' : e.tipo.trim(),
            descripcion: 'Colegio de ${p.nombre}',
            fecha: e.fecha,
            color: Colors.orange,
            icono: Icons.school,
            tipo: TipoEvento.educacion,
          ));
        }
      }
    }
    
    // 3. Vencimientos de Seguros de Hogar
    for (var prop in _propiedades) {
      if (prop.seguro != null) {
        lista.add(AppEvent(
          titulo: 'Seguro Hogar: ${prop.alias}',
          descripcion: 'Vencimiento',
          fecha: prop.seguro!.fechaVencimiento,
          color: Colors.blueGrey,
          icono: Icons.security,
          tipo: TipoEvento.hogar,
        ));
      }
    }
    
    // 4. Suscripciones (Próximo pago) 
    for (var s in _suscripciones) {
      lista.add(AppEvent(
        titulo: 'Pago: ${s.nombre.trim()}',
        descripcion: '${s.precio.toStringAsFixed(2)} €',
        fecha: s.fechaProximoCobro,
        color: Colors.purple,
        icono: Icons.payments,
        tipo: TipoEvento.gestion,
      ));
    }

    _cacheEventos = lista;
    return lista;
  }

  @override
  void dispose() {
    _cancelarListeners();
    super.dispose();
  }
}
