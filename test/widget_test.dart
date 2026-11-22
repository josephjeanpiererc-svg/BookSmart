import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_editorial/data/booksmart_database.dart';
import 'package:app_editorial/main.dart';
import 'package:app_editorial/screens/catalog_screen.dart';
import 'package:app_editorial/utils/app_localization.dart';
import 'package:app_editorial/utils/platform_layout.dart';
import 'package:app_editorial/widgets/booksmart_widgets.dart';
import 'package:app_editorial/widgets/navigation/app_sidebar.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('la base local separa cuentas y conserva estados de libros', () async {
    final databaseName =
        'booksmart_test_${DateTime.now().microsecondsSinceEpoch}';
    final database = BooksmartDatabase.forTesting(
      databaseFactoryMemory,
      databaseName,
    );
    addTearDown(() async {
      await database.closeForTesting();
      await databaseFactoryMemory.deleteDatabase(databaseName);
    });

    final luciano = await database.createPasswordAccount(
      displayName: 'Luciano',
      username: 'luciano',
      email: 'luciano@example.com',
      password: 'secreto',
    );
    final maria = await database.createPasswordAccount(
      displayName: 'María',
      username: 'maria',
      email: 'maria@example.com',
      password: 'otra-clave',
    );

    final savedUser = await database.loadUser(luciano.userId);
    expect(savedUser?.displayName, 'Luciano');
    expect(savedUser?.username, 'luciano');
    expect(savedUser?.email, 'luciano@example.com');

    await database.saveLibrary(
      luciano.userId,
      BookLibraryData(
        owned: ['Python'],
        reading: ['Python'],
        favorites: ['Python'],
      ),
    );

    expect(
      (await database.authenticatePassword(
        username: 'LUCIANO',
        password: 'secreto',
      ))?.userId,
      luciano.userId,
    );
    expect(
      await database.authenticatePassword(
        username: 'luciano',
        password: 'incorrecta',
      ),
      isNull,
    );
    expect((await database.loadLibrary(luciano.userId)).owned, {'Python'});
    expect((await database.loadLibrary(maria.userId)).owned, isEmpty);
    await expectLater(
      database.createPasswordAccount(
        displayName: 'Otro Luciano',
        username: 'Luciano',
        email: 'other@example.com',
        password: 'otra-clave',
      ),
      throwsA(isA<UsernameAlreadyExistsException>()),
    );

    final googleUser = await database.signInWithGoogle(
      googleId: 'google-subject-1',
      displayName: 'Google User',
      email: 'google@example.com',
    );
    await database.saveLibrary(
      googleUser.userId,
      BookLibraryData(owned: ['JavaScript'], pending: ['JavaScript']),
    );
    final googleUserAgain = await database.signInWithGoogle(
      googleId: 'google-subject-1',
      displayName: 'Google User',
      email: 'google@example.com',
    );

    expect(googleUserAgain.userId, googleUser.userId);
    expect((await database.loadLibrary(googleUserAgain.userId)).pending, {
      'JavaScript',
    });
  });

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

  testWidgets('permite cambiar el idioma y lo guarda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(find.text('Loading'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_language'), 'en');

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pump();
    expect(find.text('Inicio de sesión:'), findsOneWidget);

    expect(preferences.getString('app_language'), 'es');
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
    expect(find.text('Descargar app para Android'), findsNothing);
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
    expect(find.byType(ScreenCloseButton), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Continuar Leyendo'), findsOneWidget);
    expect(find.text('Inicio de sesión:'), findsNothing);
  });

  testWidgets('el botón de cerrar sesión vuelve al inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/login': (_) => const LoginScreen()},
        home: const ProfileScreen(displayName: 'Luciano'),
      ),
    );

    final logoutButton = find.byKey(const ValueKey('logout_button'));
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión:'), findsOneWidget);
    expect(find.text('Ajustes de lectura'), findsNothing);
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

  testWidgets('el título BookSmart usa tres líneas cuando el ancho es corto', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();

    expect(find.text('BookSmart\nReading &\nknowledge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra la ficha sin salir de Inicio al tocar un libro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );

    await tester.tap(
      find.byKey(const ValueKey('home_book_Anatomía humana')).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Descripción'), findsOneWidget);
    expect(find.text('Guía visual del cuerpo humano.'), findsOneWidget);
    expect(find.text('Fecha de publicación'), findsOneWidget);
    expect(find.text('Continuar Leyendo'), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byType(CatalogScreen), findsNothing);
    expect(find.byKey(const ValueKey('catalog_search_field')), findsNothing);
  });

  testWidgets('el botón de añadir en Catálogo cambia al inglés', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AppLanguageScope(
        locale: const Locale('en'),
        child: const MaterialApp(home: CatalogScreen(displayName: 'Luciano')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add to library'), findsWidgets);
    expect(find.text('Añadir a la biblioteca'), findsNothing);
  });

  testWidgets('el nuevo libro de inglés aparece con su ficha y QR', (
    WidgetTester tester,
  ) async {
    const title = 'Aprender Inglés para Adultos Principiantes';
    await tester.pumpWidget(
      const MaterialApp(home: CatalogScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idiomas').first);
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);

    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Método 8 en 1 para adultos principiantes, de Valeria L. García.',
      ),
      findsOneWidget,
    );
    expect(find.text('2024'), findsOneWidget);
    expect(
      find.text('Incluye gramática, vocabulario, conversación y más.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('detail_add_button_$title')),
      findsOneWidget,
    );
    expect(CatalogScreen.titleForQrCode(title), title);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el libro de conversación aparece con su ficha y QR', (
    WidgetTester tester,
  ) async {
    const title = 'Inglés para conversar';
    await tester.pumpWidget(
      const MaterialApp(home: CatalogScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idiomas').first);
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);

    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Curso práctico de conversación cotidiana para hispanohablantes.',
      ),
      findsOneWidget,
    );
    expect(find.text('2024'), findsOneWidget);
    expect(CatalogScreen.titleForQrCode(title), title);
    expect(
      CatalogScreen.pdfPathForTitle(title),
      'assets/PdfLibro/Ingles_Para_Conversar.pdf',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('el libro Inglés Excelente Nivel 3 muestra su ficha y QR', (
    WidgetTester tester,
  ) async {
    const title = 'Inglés ¡Excelente! Nivel 3';
    await tester.pumpWidget(
      const MaterialApp(home: CatalogScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idiomas').first);
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);

    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Libro didáctico e ilustrado de Langenscheidt para enseñar inglés a niños hispanohablantes.',
      ),
      findsOneWidget,
    );
    expect(find.text('2007'), findsOneWidget);
    expect(CatalogScreen.titleForQrCode(title), title);
    expect(
      CatalogScreen.pdfPathForTitle(title),
      'assets/PdfLibro/Ingles_Excelente_Nivel_3.pdf',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('los botones de detalle de Biblioteca usan inglés', (
    WidgetTester tester,
  ) async {
    const user = 'english-library-test';
    CatalogScreen.ownedBookTitlesFor(user).add('Anatomía humana');
    CatalogScreen.readingBookTitlesFor(user).add('Anatomía humana');
    addTearDown(() {
      CatalogScreen.ownedBookTitlesFor(user).clear();
      CatalogScreen.readingBookTitlesFor(user).clear();
    });

    await tester.pumpWidget(
      AppLanguageScope(
        locale: const Locale('en'),
        child: const MaterialApp(home: LibraryScreen(displayName: user)),
      ),
    );
    await tester.pumpAndSettle();
    final bookTitle = find.text('Anatomía humana');
    await tester.ensureVisible(bookTitle);
    await tester.pumpAndSettle();
    await tester.tap(bookTitle);
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.byTooltip('Download QR code'), findsOneWidget);
  });

  test('cada libro de Inicio tiene una ficha en el catálogo', () {
    const homeTitles = [
      'Anatomía humana',
      'Diagnóstico clínico',
      'JavaScript',
      'Python',
      'Contabilidad básica',
      'Contabilidad intermedia',
      'Refino del petróleo',
      'Inteligencia artificial',
      'Matemáticas aplicadas',
      'Programación con C++',
    ];

    for (final homeTitle in homeTitles) {
      final catalogTitle = CatalogScreen.catalogTitleForHomeBook(homeTitle);
      expect(catalogTitle, isNotNull, reason: homeTitle);
      expect(CatalogScreen.detailsForTitle(catalogTitle!), isNotNull);
    }
  });

  testWidgets('mantiene la misma barra lateral al navegar entre pantallas', (
    WidgetTester tester,
  ) async {
    double sidebarWidth() {
      return tester
          .getSize(
            find.descendant(
              of: find.byType(AppSidebar),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .width;
    }

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppSidebar), findsOneWidget);
    final homeWidth = sidebarWidth();

    await tester.tap(find.text('Catalogo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_search_field')), findsOneWidget);
    expect(sidebarWidth(), homeWidth);

    await tester.tap(find.text('Mi Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('library_search_field')), findsOneWidget);
    expect(sidebarWidth(), homeWidth);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes de lectura'), findsOneWidget);
    expect(sidebarWidth(), homeWidth);
  });

  testWidgets('al volver de Catálogo Inicio queda seleccionado en la barra', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );

    await tester.tap(find.text('Catalogo'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Icon>(find.byIcon(Icons.business_center)).color,
      Colors.white,
    );

    await tester.tap(find.byType(ScreenCloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Continuar Leyendo'), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(Icons.home)).color, Colors.white);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.business_center)).color,
      const Color(0xFF28639B),
    );
  });

  testWidgets('la barra y las pestañas de Biblioteca caben en móvil', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sidebarFinder = find.byType(AppSidebar).last;

    Rect sidebarRect() {
      return tester.getRect(sidebarFinder);
    }

    double sidebarWidth() {
      return tester
          .getSize(
            find.descendant(
              of: sidebarFinder,
              matching: find.byType(AnimatedContainer),
            ),
          )
          .width;
    }

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(displayName: 'Luciano')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi Biblioteca'));
    await tester.pumpAndSettle();

    final openWidth = sidebarWidth();
    expect(
      openWidth,
      AppSidebar.widthFor(
        scale: AppSidebar.scaleFor(360),
        isPhone: true,
        isOpen: true,
      ),
    );
    final initialLeft = sidebarRect().left;
    expect(find.byKey(const ValueKey('library_tabs_scroll')), findsOneWidget);
    expect(find.text('Mi Biblioteca'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.chevron_left).last);
    await tester.pumpAndSettle();
    final collapsedWidth = sidebarWidth();
    expect(collapsedWidth, lessThan(openWidth));

    await tester.drag(sidebarFinder, const Offset(30, 0));
    await tester.pumpAndSettle();
    expect(sidebarRect().left, greaterThan(initialLeft));
    expect(sidebarWidth(), collapsedWidth);

    await tester.drag(sidebarFinder, const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(sidebarRect().left, initialLeft);
    expect(tester.takeException(), isNull);
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
    expect(find.text('Datos personales'), findsOneWidget);
  });

  testWidgets('el perfil muestra los datos personales disponibles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfileScreen(displayName: 'Juan')),
    );

    await tester.tap(find.text('Datos personales'));
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('No disponible'), findsNWidgets(2));
    expect(find.text('Juan'), findsWidgets);
  });

  test('genera la ruta web correcta para el QR del libro', () {
    expect(
      qrAssetUrl('assets/ImagenQR/AnatomiaHumanaQR.png'),
      equals('assets/assets/ImagenQR/AnatomiaHumanaQR.png'),
    );
  });

  testWidgets('carga las portadas desde assets locales', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BookCoverImage(path: 'assets/images/ImagenLibro/LibroPython.png'),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
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
