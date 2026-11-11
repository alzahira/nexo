/// En web no hay instancias locales: siempre se permite abrir.
Future<bool> adquirirInstanciaUnica() async => true;

/// En web nunca se muestra el aviso, pero la firma debe existir.
void cerrarAplicacion() {}

/// En web no hay bloqueo que liberar.
void liberarInstanciaUnica() {}
