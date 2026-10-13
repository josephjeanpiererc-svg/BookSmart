import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    this.displayName = 'Usuario',
    this.paidPlan = false,
    this.initialBookTitle,
  });

  static final Map<String, Set<String>> _ownedBookTitlesByUser = {};
  static final Map<String, Set<String>> _readingBookTitlesByUser = {};
  static final Map<String, Set<String>> _completedBookTitlesByUser = {};
  static final Map<String, Set<String>> _pendingBookTitlesByUser = {};
  static final Map<String, Set<String>> _favoriteBookTitlesByUser = {};

  static String _userKey(String? user) {
    final sanitized = (user ?? 'Usuario').trim();
    return sanitized.isEmpty ? 'Usuario' : sanitized;
  }

  static Set<String> ownedBookTitlesFor(String? user) {
    return _ownedBookTitlesByUser.putIfAbsent(_userKey(user), () => <String>{});
  }

  static Set<String> readingBookTitlesFor(String? user) {
    return _readingBookTitlesByUser.putIfAbsent(
      _userKey(user),
      () => <String>{},
    );
  }

  static Set<String> completedBookTitlesFor(String? user) {
    return _completedBookTitlesByUser.putIfAbsent(
      _userKey(user),
      () => <String>{},
    );
  }

  static Set<String> pendingBookTitlesFor(String? user) {
    return _pendingBookTitlesByUser.putIfAbsent(
      _userKey(user),
      () => <String>{},
    );
  }

  static Set<String> favoriteBookTitlesFor(String? user) {
    return _favoriteBookTitlesByUser.putIfAbsent(
      _userKey(user),
      () => <String>{},
    );
  }

  static Set<String> get ownedBookTitles => ownedBookTitlesFor('Usuario');
  static Set<String> get readingBookTitles => readingBookTitlesFor('Usuario');
  static Set<String> get completedBookTitles =>
      completedBookTitlesFor('Usuario');
  static Set<String> get pendingBookTitles => pendingBookTitlesFor('Usuario');
  static Set<String> get favoriteBookTitles => favoriteBookTitlesFor('Usuario');

  static BookReadingStatus statusForTitle(String title, [String? user]) {
    final completed = completedBookTitlesFor(user);
    final pending = pendingBookTitlesFor(user);
    if (completed.contains(title)) {
      return BookReadingStatus.completed;
    }
    if (pending.contains(title)) {
      return BookReadingStatus.pending;
    }
    return BookReadingStatus.reading;
  }

  static void setBookStatus(
    String title,
    BookReadingStatus status, [
    String? user,
  ]) {
    final reading = readingBookTitlesFor(user);
    final pending = pendingBookTitlesFor(user);
    final completed = completedBookTitlesFor(user);
    reading.remove(title);
    pending.remove(title);
    completed.remove(title);

    switch (status) {
      case BookReadingStatus.reading:
        reading.add(title);
      case BookReadingStatus.pending:
        pending.add(title);
      case BookReadingStatus.completed:
        completed.add(title);
    }
  }

  static void setFavorite(String title, bool isFavorite, [String? user]) {
    final favorites = favoriteBookTitlesFor(user);
    if (isFavorite) {
      favorites.add(title);
    } else {
      favorites.remove(title);
    }
  }

  static (String, String, String, String, String)? detailsForTitle(
    String title,
  ) {
    final book = _bookCatalog.firstWhere(
      (entry) => entry.$2 == title,
      orElse: () => const ('', '', '', '', ''),
    );

    if (book.$2.isEmpty) {
      return null;
    }

    return book;
  }

  static const List<(String, String, String, String, String)> _bookCatalog = [
    (
      'Salud',
      'Anatomía humana',
      'Guía visual del cuerpo humano.',
      '2024',
      'Una introducción ilustrada a la estructura y el funcionamiento del cuerpo humano.',
    ),
    (
      'Contabilidad',
      'Apuntes de contabilidad financiera',
      'Fundamentos contables prácticos.',
      '2023',
      'Material de estudio para comprender registros, estados financieros y operaciones básicas.',
    ),
    (
      'Contabilidad',
      'Contabilidad financiera intermedia',
      'Contenido para nivel intermedio.',
      '2023',
      'Desarrolla casos y conceptos contables para profundizar en la información financiera.',
    ),
    (
      'Salud',
      'Diagnóstico clínico',
      'Herramientas para el análisis clínico.',
      '2024',
      'Presenta bases para la evaluación de síntomas y el razonamiento clínico.',
    ),
    (
      'Ingeniería',
      'El refino del petróleo',
      'Procesos de la industria petrolera.',
      '2022',
      'Explica las etapas principales del refinamiento y la transformación del petróleo.',
    ),
    (
      'Tecnología',
      'JavaScript: The Definitive Guide',
      'Referencia completa de JavaScript.',
      '2023',
      'Una guía de consulta para crear aplicaciones modernas con JavaScript.',
    ),
    (
      'Tecnología',
      'Artificial Intelligence',
      'Introducción a la inteligencia artificial.',
      '2024',
      'Explora conceptos, aplicaciones y fundamentos de la inteligencia artificial.',
    ),
    (
      'Ingeniería',
      'Matemáticas aplicadas a la ingeniería petrolera',
      'Matemáticas para problemas de ingeniería.',
      '2022',
      'Reúne métodos matemáticos aplicados a procesos de ingeniería petrolera.',
    ),
    (
      'Tecnología',
      'Object-Oriented Programming with C++',
      'Programación orientada a objetos.',
      '2023',
      'Explica clases, objetos y diseño de software usando C++.',
    ),
    (
      'Tecnología',
      'Python',
      'Programación práctica con Python.',
      '2024',
      'Una introducción clara al lenguaje Python y sus aplicaciones.',
    ),
  ];

  static String imagePathForTitle(String title) {
    const paths = {
      'Anatomía humana': 'assets/images/ImagenLibro/LibroAnatomiaHumana.png',
      'Apuntes de contabilidad financiera':
          'assets/images/ImagenLibro/LibroApuntesdeContabilidadFinanciera.png',
      'Contabilidad financiera intermedia':
          'assets/images/ImagenLibro/LibroContabilidadFinancieraIntermedia.png',
      'Diagnóstico clínico':
          'assets/images/ImagenLibro/LibroDiagnosticoClinico.png',
      'El refino del petróleo':
          'assets/images/ImagenLibro/LibroElRefinodelPetroleo.png',
      'JavaScript: The Definitive Guide':
          'assets/images/ImagenLibro/LibroJavaScriptTheDefinitiveGuide.png',
      'Artificial Intelligence':
          'assets/images/ImagenLibro/LibroLugarArtificialIntelligence.png',
      'Matemáticas aplicadas a la ingeniería petrolera': 'assets/images/ImagenLibro/LibroMatematicasAplicadasalaIngenieriaPetrolera.png',
      'Object-Oriented Programming with C++': 'assets/images/ImagenLibro/LibroObject-OrientedProgrammingWithc++.png',
      'Python': 'assets/images/ImagenLibro/LibroPython.png',
    };
    return paths[title] ?? 'assets/images/ImagenLibro/LibroPython.png';
  }

  static String pdfPathForTitle(String title) {
    const paths = {
      'Anatomía humana': 'assets/PdfLibro/Anatomia_Humana.pdf',
      'Apuntes de contabilidad financiera':
          'assets/PdfLibro/Apuntes_de_Contabilidad_Financiera.pdf',
      'Contabilidad financiera intermedia':
          'assets/PdfLibro/Contabilidad_Financiera_Intermedia.pdf',
      'Diagnóstico clínico':
          'assets/PdfLibro/Diagnostico_Clinico_Ciencia_y_Arte.pdf',
      'El refino del petróleo': 'assets/PdfLibro/El_Refino_del_Petroleo.pdf',
      'JavaScript: The Definitive Guide':
          'assets/PdfLibro/JavaScript_The_Definitive_Guide.pdf',
      'Artificial Intelligence': 'assets/PdfLibro/Artificial_Intelligence.pdf',
      'Matemáticas aplicadas a la ingeniería petrolera':
          'assets/PdfLibro/Matematicas_Aplicadas_Ingenieria_Petrolera.pdf',
      'Object-Oriented Programming with C++':
          'assets/PdfLibro/Object_Oriented_Programming_with_Cpp.pdf',
      'Python': 'assets/PdfLibro/Python_The_Complete_Reference.pdf',
    };
    return paths[title] ?? '';
  }

  static String qrPathForTitle(String title) {
    const paths = {
      'Anatomía humana': 'assets/ImagenQR/AnatomiaHumanaQR.png',
      'Apuntes de contabilidad financiera':
          'assets/ImagenQR/ApuntesContabilidadFinancieraQR.png',
      'Artificial Intelligence': 'assets/ImagenQR/ArtificialIntelligenceQR.png',
      'Contabilidad financiera intermedia':
          'assets/ImagenQR/ContabilidadFinancieraIntermediaQR.png',
      'Diagnóstico clínico': 'assets/ImagenQR/DiagnosticoClinicoQR.png',
      'El refino del petróleo': 'assets/ImagenQR/ElRefinoDelPetroleoQR.png',
      'JavaScript: The Definitive Guide':
          'assets/ImagenQR/JavaScriptDefinitiveGuideQR.png',
      'Matemáticas aplicadas a la ingeniería petrolera':
          'assets/ImagenQR/MatematicasIngenieriaPetroleraQR.png',
      'Object-Oriented Programming with C++':
          'assets/ImagenQR/ObjectOrientedProgrammingCppQR.png',
      'Python': 'assets/ImagenQR/PythonQR.png',
    };
    return paths[title] ?? '';
  }

  static String? titleForQrCode(String value) {
    final normalizedValue = _normalizeQrValue(value);
    const pdfCodes = {
      'anatomia humana': 'Anatomía humana',
      'apuntes de contabilidad financiera':
          'Apuntes de contabilidad financiera',
      'artificial intelligence': 'Artificial Intelligence',
      'contabilidad financiera intermedia':
          'Contabilidad financiera intermedia',
      'diagnostico clinico ciencia y arte': 'Diagnóstico clínico',
      'el refino del petroleo': 'El refino del petróleo',
      'javascript the definitive guide': 'JavaScript: The Definitive Guide',
      'matematicas aplicadas ingenieria petrolera':
          'Matemáticas aplicadas a la ingeniería petrolera',
      'object oriented programming with cpp':
          'Object-Oriented Programming with C++',
      'python the complete reference': 'Python',
    };

    for (final book in _bookCatalog) {
      if (_normalizeQrValue(book.$2) == normalizedValue) {
        return book.$2;
      }
    }
    return pdfCodes[normalizedValue];
  }

  static String _normalizeQrValue(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\.pdf$'), '')
        .replaceAll('_', ' ')
        .replaceAll(':', '')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  final String displayName;
  final bool paidPlan;
  final String? initialBookTitle;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _selectedCategory = 0;
  bool _sideMenuOpen = true;
  final _searchController = TextEditingController();
  final _categories = const [
    'Todo',
    'Salud',
    'Contabilidad',
    'Ingeniería',
    'Tecnología',
  ];
  final _books = CatalogScreen._bookCatalog;

  @override
  void initState() {
    super.initState();
    if (widget.initialBookTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final book = CatalogScreen.detailsForTitle(widget.initialBookTitle!);
        if (book != null) {
          _openBookDetail(context, book, 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSideMenu(bool open) {
    if (_sideMenuOpen != open) {
      setState(() => _sideMenuOpen = open);
    }
  }

  void _handleSideMenuDragUpdate(DragUpdateDetails details) {
    if (!isPhoneLayout(MediaQuery.sizeOf(context).width)) {
      return;
    }

    final delta = details.primaryDelta ?? 0;
    if (delta > 0 && !_sideMenuOpen) {
      _toggleSideMenu(true);
    } else if (delta < 0 && _sideMenuOpen) {
      _toggleSideMenu(false);
    }
  }

  void _handleSideMenuDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 180) {
      _toggleSideMenu(true);
    } else if (velocity < -180) {
      _toggleSideMenu(false);
    }
  }

  List<(String, String, String, String, String)> get _filteredBooks {
    final selected = _categories[_selectedCategory];
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _books
        .where((book) {
          final matchesCategory = selected == 'Todo' || book.$1 == selected;
          final title = book.$2.toLowerCase();
          final matchesQuery = query.isEmpty || title.contains(query);
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);

    return filtered;
  }

  void _addBookToLibrary(String title, {bool fromDetail = false}) {
    final userKey = widget.displayName;
    final owned = CatalogScreen.ownedBookTitlesFor(userKey);
    final alreadyOwned = owned.contains(title);
    if (alreadyOwned) {
      return;
    }

    setState(() {
      owned.add(title);
      final hasSelectedStatus =
          CatalogScreen.readingBookTitlesFor(userKey).contains(title) ||
          CatalogScreen.pendingBookTitlesFor(userKey).contains(title) ||
          CatalogScreen.completedBookTitlesFor(userKey).contains(title);
      if (!hasSelectedStatus) {
        CatalogScreen.setBookStatus(title, BookReadingStatus.reading, userKey);
      }
    });

    if (fromDetail) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ya está en tu posesión: $title'),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _openBookDetail(
    BuildContext context,
    (String, String, String, String, String) book,
    double scale,
  ) {
    final title = book.$2;
    final imagePath = CatalogScreen.imagePathForTitle(title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E7),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28 * scale),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            18 * scale,
            18 * scale,
            22 * scale,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52 * scale,
                    height: 6 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD6E5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                SizedBox(
                  height: 240 * scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18 * scale),
                    child: BookCoverImage(path: imagePath),
                  ),
                ),
                SizedBox(height: 18 * scale),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A39),
                  ),
                ),
                SizedBox(height: 10 * scale),
                BookQrCard(
                  assetPath: CatalogScreen.qrPathForTitle(title),
                  title: title,
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B3A4D),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  book.$3,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    color: const Color(0xFF4C5663),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16 * scale),
                _DetailInfoRow(
                  label: 'Fecha de publicación',
                  value: book.$4,
                  scale: scale,
                ),
                SizedBox(height: 10 * scale),
                _DetailInfoRow(
                  label: '¿De qué se trata?',
                  value: book.$5,
                  scale: scale,
                ),
                SizedBox(height: 18 * scale),
                BookStatusControls(
                  scale: scale,
                  status: CatalogScreen.statusForTitle(
                    title,
                    widget.displayName,
                  ),
                  isFavorite: CatalogScreen.favoriteBookTitlesFor(
                    widget.displayName,
                  ).contains(title),
                  onStatusChanged: (status) {
                    setState(
                      () => CatalogScreen.setBookStatus(
                        title,
                        status,
                        widget.displayName,
                      ),
                    );
                  },
                  onFavoriteChanged: (isFavorite) {
                    setState(
                      () => CatalogScreen.setFavorite(
                        title,
                        isFavorite,
                        widget.displayName,
                      ),
                    );
                  },
                ),
                SizedBox(height: 18 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    key: ValueKey('detail_add_button_$title'),
                    onPressed:
                        CatalogScreen.ownedBookTitlesFor(widget.displayName)
                            .contains(title)
                        ? null
                        : () => _addBookToLibrary(title, fromDetail: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CatalogScreen.ownedBookTitlesFor(widget.displayName)
                              .contains(title)
                          ? const Color(0xFFBFBFBF)
                          : const Color(0xFFF0C94D),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                    ),
                    child: Text(
                      CatalogScreen.ownedBookTitlesFor(widget.displayName)
                              .contains(title)
                          ? 'Ya está en tu posesión'
                          : 'Añadir a la biblioteca',
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;
    return Scaffold(
      floatingActionButton: const ScreenCloseButton(),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isPhone = isPhoneLayout(width);
          final frameWidth = useFullScreen
              ? width
              : (width - 32).clamp(280.0, 440.0);
          final scale = useFullScreen
              ? (width / 600).clamp(0.82, 1.0)
              : (frameWidth / 375).clamp(0.68, 1.1);
          final phoneRailOpenWidth = 112.0 * scale;
          final phoneRailClosedWidth = 58.0 * scale;
          final contentPaddingLeft = isPhone
              ? (12 * scale) +
                    (_sideMenuOpen ? phoneRailOpenWidth : phoneRailClosedWidth)
              : (12 * scale) + (_sideMenuOpen ? 108 * scale : 42 * scale);
          final menuWidth = isPhone ? phoneRailOpenWidth : 112.0 * scale;
          final compactGridCount = isPhone ? 2 : 3;

          return Center(
            child: Container(
              width: frameWidth,
              height: useFullScreen
                  ? constraints.maxHeight
                  : constraints.maxHeight - 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2DB),
                border: useFullScreen
                    ? null
                    : Border.all(
                        color: const Color(0xFF39688F),
                        width: 9 * scale,
                      ),
                borderRadius: useFullScreen
                    ? null
                    : BorderRadius.circular(28 * scale),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            contentPaddingLeft,
                            18 * scale,
                            14 * scale,
                            10 * scale,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: const ValueKey(
                                        'catalog_search_field',
                                      ),
                                      controller: _searchController,
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText: 'Buscar',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20 * scale,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 32 * scale,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF638DB1),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20 * scale,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  SizedBox(
                                    width: 50 * scale,
                                    height: 50 * scale,
                                    child: IconButton(
                                      onPressed: () {},
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF0C94D,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF28639B,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10 * scale,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.filter_alt_outlined,
                                        size: 30 * scale,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12 * scale),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 8 * scale,
                                  runSpacing: 8 * scale,
                                  children: List.generate(
                                    _categories.length,
                                    (index) => ChoiceChip(
                                      label: Text(_categories[index]),
                                      selected: _selectedCategory == index,
                                      onSelected: (_) => setState(
                                        () => _selectedCategory = index,
                                      ),
                                      selectedColor: const Color(0xFFF0C94D),
                                      backgroundColor: const Color(0xFF527FE1),
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          24 * scale,
                                        ),
                                      ),
                                      avatar: _selectedCategory == index
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14 * scale),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredBooks.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: compactGridCount,
                                      crossAxisSpacing: 6 * scale,
                                      mainAxisSpacing: 14 * scale,
                                      childAspectRatio: isPhone ? 0.82 : 0.73,
                                    ),
                                itemBuilder: (context, index) {
                                  final book = _filteredBooks[index];
                                  return _CatalogBookCard(
                                    category: book.$1,
                                    title: book.$2,
                                    description: book.$3,
                                    publicationDate: book.$4,
                                    summary: book.$5,
                                    imagePath: CatalogScreen.imagePathForTitle(
                                      book.$2,
                                    ),
                                    scale: scale,
                                    onTap: () =>
                                        _openBookDetail(context, book, scale),
                                    isOwned: CatalogScreen.ownedBookTitlesFor(
                                      widget.displayName,
                                    ).contains(book.$2),
                                    displayName: widget.displayName,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    top: 70 * scale,
                    bottom: 64 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: isPhone
                          ? _handleSideMenuDragUpdate
                          : null,
                      onHorizontalDragEnd: isPhone
                          ? _handleSideMenuDragEnd
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isPhone
                            ? (_sideMenuOpen
                                  ? phoneRailOpenWidth
                                  : phoneRailClosedWidth)
                            : (_sideMenuOpen ? menuWidth : 54 * scale),
                        padding: EdgeInsets.fromLTRB(
                          8 * scale,
                          12 * scale,
                          8 * scale,
                          12 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCC9AA),
                          border: Border.all(
                            color: const Color(0xFF2F6C9A),
                            width: 3 * scale,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18 * scale),
                            bottomRight: Radius.circular(18 * scale),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_sideMenuOpen) ...[
                              _SideMenuItem(
                                icon: Icons.home,
                                label: 'Inicio',
                                selected: false,
                                scale: scale,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => HomeScreen(
                                        displayName: widget.displayName,
                                        paidPlan: widget.paidPlan,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 14 * scale),
                              _SideMenuItem(
                                icon: Icons.business_center,
                                label: 'Catalogo',
                                selected: true,
                                scale: scale,
                                onTap: () =>
                                    setState(() => _sideMenuOpen = true),
                              ),
                              SizedBox(height: 14 * scale),
                              _SideMenuItem(
                                icon: Icons.menu_book,
                                label: 'Mi Biblioteca',
                                selected: false,
                                scale: scale,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => LibraryScreen(
                                        displayName: widget.displayName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 14 * scale),
                              _SideMenuItem(
                                icon: Icons.person,
                                label: 'Perfil',
                                selected: false,
                                scale: scale,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ProfileScreen(
                                        displayName: widget.displayName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            Expanded(
                              child: Center(
                                child: IconButton(
                                  onPressed: () => setState(
                                    () => _sideMenuOpen = !_sideMenuOpen,
                                  ),
                                  icon: Icon(
                                    _sideMenuOpen
                                        ? Icons.chevron_left
                                        : Icons.menu,
                                    color: const Color(0xFF28639B),
                                    size: 30 * scale,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEFE4CF),
                                    shape: const CircleBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogBookCard extends StatelessWidget {
  const _CatalogBookCard({
    required this.category,
    required this.title,
    required this.description,
    required this.publicationDate,
    required this.summary,
    required this.imagePath,
    required this.scale,
    required this.onTap,
    required this.isOwned,
    required this.displayName,
  });

  final String category;
  final String title;
  final String description;
  final String publicationDate;
  final String summary;
  final String imagePath;
  final double scale;
  final VoidCallback onTap;
  final bool isOwned;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20 * scale),
      child: Container(
        padding: EdgeInsets.all(7 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFD0D0D0),
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFFE7E7E7),
                    child: BookCoverImage(path: imagePath),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    color: const Color(0xFF4B4B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6 * scale),
                SizedBox(
                  height: 36 * scale,
                  child: ElevatedButton(
                    onPressed: isOwned
                        ? null
                        : () {
                            final currentState = context
                                .findAncestorStateOfType<_CatalogScreenState>();
                            currentState?._addBookToLibrary(title);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned
                          ? const Color(0xFFBFBFBF)
                          : const Color(0xFFF0C94D),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text(
                      isOwned
                          ? 'Ya está en tu posesión'
                          : 'Añadir a la biblioteca',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (CatalogScreen.readingBookTitlesFor(displayName).contains(title))
              Positioned(
                top: 4 * scale,
                right: 4 * scale,
                child: Container(
                  padding: EdgeInsets.all(4 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6FA9),
                    borderRadius: BorderRadius.circular(8 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    size: 15 * scale,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2B3A4D),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * scale,
            color: const Color(0xFF495A6D),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SideMenuItem extends StatelessWidget {
  const _SideMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5D7E9E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF28639B),
              size: 28 * scale,
            ),
            SizedBox(height: 4 * scale),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF1E2A39),
                fontSize: 11 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
