import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_editorial/main.dart';
import 'package:app_editorial/screens/catalog_screen.dart';
import 'package:app_editorial/utils/platform_layout.dart';
import 'package:app_editorial/widgets/booksmart_widgets.dart';

void main() {
  test('usa pantalla completa en Android', () {
    expect(shouldUseFullScreenLayout(TargetPlatform.android), isTrue);
    expect(shouldUseFullScreenLayout(TargetPlatform.iOS), isFalse);
    expect(shouldUseFullScreenLayout(TargetPlatform.windows), isFalse);
  });

  testWidgets('muestra la pantalla inicial de carga', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Cargando'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra el formulario de inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión:'), findsOneWidget);
    expect(find.text('Usuario:'), findsOneWidget);
    expect(find.text('Contraseña:'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('INICIO'), findsOneWidget);
    expect(find.text('Crear cuenta nueva'), findsOneWidget);
  });

  testWidgets('abre el formulario para crear una cuenta', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final createAccountLink = find.text('Crear cuenta nueva');
    await tester.ensureVisible(createAccountLink);
    await tester.tap(createAccountLink);
    await tester.pumpAndSettle();

    expect(find.text('Crear una Nueva Cuenta:'), findsOneWidget);
    expect(find.text('Nombre:'), findsOneWidget);
    expect(find.text('Confirma Contraseña:'), findsOneWidget);
    expect(find.text('Continua...'), findsOneWidget);
    expect(find.text('Volver a la parte de Inicio Sesión.'), findsOneWidget);
  });

  testWidgets('muestra la verificación de correo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EmailVerificationScreen()));

    expect(find.text('Verificación de correo'), findsOneWidget);
    expect(find.text('Correo:'), findsOneWidget);
    expect(find.text('Obtener Código'), findsOneWidget);
    expect(find.text('Verificar correo'), findsOneWidget);
    expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(7));
  });

  testWidgets('confirma la cuenta y vuelve al inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AccountCreatedScreen()));

    expect(find.text('Cuenta creada\ncon éxito'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión:'), findsOneWidget);
  });

  testWidgets('muestra el login sin opciones de pago', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Inicio de sesión:'), findsOneWidget);
    expect(find.text('De Paga'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'Luciano');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto');
    final loginButton = find.text('INICIO');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido/a:     Luciano'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Continuar Leyendo'), findsOneWidget);
  });

  testWidgets('abre el Home después de iniciar sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Luciano');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto');
    final loginButton = find.text('INICIO');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido/a:     Luciano'), findsOneWidget);
    expect(find.text('Continuar Leyendo'), findsOneWidget);
    expect(find.text('Novedades'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('muestra el nombre de cada cuenta en el Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );

    expect(find.text('Bienvenido/a:     Luciano'), findsOneWidget);
    expect(find.text('Bienvenido/a:     Juan'), findsNothing);
  });

  testWidgets('muestra el perfil gratuito con más opciones de configuración', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfileScreen(displayName: 'Juan')),
    );

    expect(find.text('Bienvenido :'), findsOneWidget);
    expect(find.text('Juan'), findsWidgets);
    expect(find.text('Ajustes de lectura'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Privacidad'), findsOneWidget);
    expect(find.text('Cambiar foto'), findsOneWidget);
    expect(find.text('Suscripción'), findsNothing);
    expect(find.text('Comprobantes'), findsNothing);
  });

  test('genera la ruta web correcta para el QR del libro', () {
    expect(
      qrAssetUrl('assets/ImagenQR/AnatomiaHumanaQR.png'),
      equals('/assets/ImagenQR/AnatomiaHumanaQR.png'),
    );
  });

  test('cada cuenta mantiene su propia biblioteca y una nueva cuenta empieza vacía', () {
    final alice = 'Alice';
    final bob = 'Bob';
    final nueva = 'Cuenta nueva';

    CatalogScreen.ownedBookTitlesFor(alice).add('Anatomía humana');
    CatalogScreen.readingBookTitlesFor(alice).add('Anatomía humana');

    expect(
      CatalogScreen.ownedBookTitlesFor(alice),
      contains('Anatomía humana'),
    );
    expect(CatalogScreen.ownedBookTitlesFor(bob), isEmpty);
    expect(CatalogScreen.ownedBookTitlesFor(nueva), isEmpty);
    expect(CatalogScreen.readingBookTitlesFor(bob), isEmpty);
  });

  testWidgets('filtra los libros por coincidencia parcial en el buscador', (
    WidgetTester tester,
  ) async {
    CatalogScreen.ownedBookTitles.clear();

    await tester.pumpWidget(
      const MaterialApp(home: CatalogScreen(displayName: 'Luciano')),
    );

    final searchField = find.byKey(const ValueKey('catalog_search_field'));
    await tester.enterText(searchField, 'anatom');
    await tester.pumpAndSettle();

    expect(find.text('Anatomía humana'), findsOneWidget);
    expect(find.text('Python'), findsNothing);
    expect(find.text('JavaScript: The Definitive Guide'), findsNothing);

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    await tester.enterText(searchField, 'conta');
    await tester.pumpAndSettle();

    expect(find.text('Apuntes de contabilidad financiera'), findsOneWidget);
    expect(find.text('Contabilidad financiera intermedia'), findsOneWidget);
  });
}
