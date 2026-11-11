import 'package:app_home/providers/auth_provider.dart';
import 'package:app_home/ui/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app() => ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: const MaterialApp(home: LoginScreen()),
    );

void main() {
  testWidgets('muestra el aviso cuando no hay Firebase configurado',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.textContaining('Firebase no está configurado'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Entrar como Invitado'), findsOneWidget);
  });

  testWidgets('entrar como invitado deja la app con sesión iniciada',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final auth = tester
        .element(find.byType(LoginScreen))
        .read<AuthProvider>();

    final invitado = find.text('Entrar como Invitado');
    await tester.ensureVisible(invitado);
    await tester.pumpAndSettle();

    await tester.tap(invitado);
    await tester.pump();

    expect(auth.isLoggedIn, isTrue);
  });

  testWidgets('el formulario muestra el error al intentar entrar sin Firebase',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Firebase no está configurado'), findsWidgets);
  });
}
