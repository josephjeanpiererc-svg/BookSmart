import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_localization.dart';
import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import '../widgets/book_details_sheet.dart';
import '../widgets/navigation/app_sidebar.dart';
import 'catalog_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.displayName = 'Usuario',
    this.userId,
    this.paidPlan = false,
  });

  final String displayName;
  final String? userId;
  final bool paidPlan;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFloatingButton = true;
  bool _sideMenuOpen = true;
  String get _accountId => widget.userId ?? widget.displayName;

  final _books = const [
    (
      'Anatomía humana',
      '320 pág.',
      Color(0xFF496344),
      'assets/images/ImagenLibro/LibroAnatomiaHumana.png',
    ),
    (
      'Diagnóstico clínico',
      '280 pág.',
      Color(0xFF7A2830),
      'assets/images/ImagenLibro/LibroDiagnosticoClinico.png',
    ),
    (
      'JavaScript',
      '706 pág.',
      Color(0xFF3E5668),
      'assets/images/ImagenLibro/LibroJavaScriptTheDefinitiveGuide.png',
    ),
    (
      'Python',
      '450 pág.',
      Color(0xFFC88E65),
      'assets/images/ImagenLibro/LibroPython.png',
    ),
    (
      'Contabilidad básica',
      '380 pág.',
      Color(0xFF527FE1),
      'assets/images/ImagenLibro/LibroApuntesdeContabilidadFinanciera.png',
    ),
    (
      'Contabilidad intermedia',
      '410 pág.',
      Color(0xFF39688F),
      'assets/images/ImagenLibro/LibroContabilidadFinancieraIntermedia.png',
    ),
    (
      'Refino del petróleo',
      '295 pág.',
      Color(0xFFC88E65),
      'assets/images/ImagenLibro/LibroElRefinodelPetroleo.png',
    ),
    (
      'Inteligencia artificial',
      '360 pág.',
      Color(0xFF496344),
      'assets/images/ImagenLibro/LibroLugarArtificialIntelligence.png',
    ),
    (
      'Matemáticas aplicadas',
      '425 pág.',
      Color(0xFF7A2830),
      'assets/images/ImagenLibro/LibroMatematicasAplicadasalaIngenieriaPetrolera.png',
    ),
    (
      'Programación con C++',
      '510 pág.',
      Color(0xFF3E5668),
      'assets/images/ImagenLibro/LibroObject-OrientedProgrammingWithc++.png',
    ),
  ];

  List<(String, String, Color, String)> _booksForRow(int row) {
    const startPositions = [0, 4, 8, 2];
    final start = startPositions[row];
    return List.generate(7, (index) => _books[(start + index) % _books.length]);
  }

  void _openBookDetails(String homeTitle, double scale) {
    final catalogTitle = CatalogScreen.catalogTitleForHomeBook(homeTitle);
    if (catalogTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              'No hay información disponible para este libro.',
              'No information is available for this book.',
            ),
          ),
        ),
      );
      return;
    }

    final book = CatalogScreen.detailsForTitle(catalogTitle);
    if (book == null) return;

    BookDetailsSheet.show(
      context: context,
      book: book,
      imagePath: CatalogScreen.imagePathForTitle(catalogTitle),
      qrAssetPath: CatalogScreen.qrPathForTitle(catalogTitle),
      scale: scale,
      status: CatalogScreen.statusForTitle(catalogTitle, _accountId),
      isFavorite: CatalogScreen.favoriteBookTitlesFor(_accountId)
          .contains(catalogTitle),
      isOwned: CatalogScreen.ownedBookTitlesFor(_accountId)
          .contains(catalogTitle),
      onStatusChanged: (status) {
        setState(
          () => CatalogScreen.setBookStatus(catalogTitle, status, _accountId),
        );
      },
      onFavoriteChanged: (isFavorite) {
        setState(
          () => CatalogScreen.setFavorite(catalogTitle, isFavorite, _accountId),
        );
      },
      onAddToLibrary: () {
        CatalogScreen.ownedBookTitlesFor(_accountId).add(catalogTitle);
        CatalogScreen.setBookStatus(
          catalogTitle,
          BookReadingStatus.reading,
          _accountId,
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${localizedText(context, 'Ya está en tu posesión:', 'Already in your library:')} $catalogTitle',
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
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = isPhoneLayout(width);
        final frameWidth = useFullScreen
            ? width
            : (width - 32).clamp(280.0, 440.0);
        final scale = useFullScreen
            ? (width / 600).clamp(0.82, 1.0)
            : (frameWidth / 375).clamp(0.68, 1.1);
        final sidebarScale = AppSidebar.scaleFor(width);
        final sidebarWidth = AppSidebar.widthFor(
          scale: sidebarScale,
          isPhone: isPhone,
          isOpen: _sideMenuOpen,
        );
        final contentPaddingLeft = 14 * scale + sidebarWidth;
        final availableContentWidth = width - contentPaddingLeft - 16 * scale;
        final homeContentWidth = availableContentWidth
            .clamp(0.0, 700.0)
            .toDouble();
        final homeContentLeft =
            contentPaddingLeft + (availableContentWidth - homeContentWidth) / 2;
        final showDesktopNews = kIsWeb && !isPhone && width >= 1000;
        final leftNewsWidth = (homeContentLeft - sidebarWidth - 8 * scale)
            .clamp(0.0, 205 * scale)
            .toDouble();
        final rightNewsWidth =
            (width - homeContentLeft - homeContentWidth - 8 * scale)
                .clamp(0.0, 205 * scale)
                .toDouble();
        final readingBooks = _booksForRow(0);
        final newBooks = _booksForRow(1);
        final popularBooks = _booksForRow(2);
        final recommendedBooks = _booksForRow(3);

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
                if (showDesktopNews && leftNewsWidth > 40 * scale)
                  Positioned(
                    left: sidebarWidth + 4 * scale,
                    top: 48 * scale,
                    bottom: 10 * scale,
                    width: leftNewsWidth,
                    child: const IgnorePointer(
                      child: _HomeNewsColumn(
                        imagePaths: [
                          'assets/images/noticias/NoticiaProyecto001.jpg',
                          'assets/images/noticias/NoticiaProyecto002.jpg',
                          'assets/images/noticias/NoticiaProyecto003.jpg',
                        ],
                      ),
                    ),
                  ),
                if (showDesktopNews && rightNewsWidth > 40 * scale)
                  Positioned(
                    right: 4 * scale,
                    top: 48 * scale,
                    bottom: 10 * scale,
                    width: rightNewsWidth,
                    child: const IgnorePointer(
                      child: _HomeNewsColumn(
                        imagePaths: [
                          'assets/images/noticias/NoticiaProyecto004.jpg',
                          'assets/images/noticias/NoticiaProyecto005.jpg',
                          'assets/images/noticias/NoticiaProyecto006.jpg',
                        ],
                      ),
                    ),
                  ),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          contentPaddingLeft,
                          16 * scale,
                          16 * scale,
                          10 * scale,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HomeHeader(
                                  displayName: widget.displayName,
                                  paidPlan: widget.paidPlan,
                                  scale: scale,
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  localizedText(
                                    context,
                                    'Continuar Leyendo',
                                    'Continue reading',
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xFFC2A50B),
                                    fontSize: 21 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                SizedBox(
                                  height: 152 * scale,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: readingBooks.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 14 * scale),
                                    itemBuilder: (context, index) => _BookCard(
                                      title: readingBooks[index].$1,
                                      pages: readingBooks[index].$2,
                                      color: readingBooks[index].$3,
                                      imagePath: readingBooks[index].$4,
                                      scale: scale,
                                      onTap: () => _openBookDetails(
                                        readingBooks[index].$1,
                                        scale,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  localizedText(context, 'Novedades', 'New'),
                                  style: TextStyle(
                                    color: const Color(0xFFC2A50B),
                                    fontSize: 21 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                SizedBox(
                                  height: 152 * scale,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: newBooks.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 14 * scale),
                                    itemBuilder: (context, index) => _BookCard(
                                      title: newBooks[index].$1,
                                      pages: newBooks[index].$2,
                                      color: newBooks[index].$3,
                                      imagePath: newBooks[index].$4,
                                      scale: scale,
                                      onTap: () => _openBookDetails(
                                        newBooks[index].$1,
                                        scale,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  localizedText(
                                    context,
                                    'Populares',
                                    'Popular',
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xFFC2A50B),
                                    fontSize: 21 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                SizedBox(
                                  height: 152 * scale,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: popularBooks.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 14 * scale),
                                    itemBuilder: (context, index) => _BookCard(
                                      title: popularBooks[index].$1,
                                      pages: popularBooks[index].$2,
                                      color: popularBooks[index].$3,
                                      imagePath: popularBooks[index].$4,
                                      scale: scale,
                                      onTap: () => _openBookDetails(
                                        popularBooks[index].$1,
                                        scale,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  localizedText(context, 'Para ti', 'For you'),
                                  style: TextStyle(
                                    color: const Color(0xFFC2A50B),
                                    fontSize: 21 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                SizedBox(
                                  height: 152 * scale,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recommendedBooks.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 14 * scale),
                                    itemBuilder: (context, index) => _BookCard(
                                      title: recommendedBooks[index].$1,
                                      pages: recommendedBooks[index].$2,
                                      color: recommendedBooks[index].$3,
                                      imagePath: recommendedBooks[index].$4,
                                      scale: scale,
                                      onTap: () => _openBookDetails(
                                        recommendedBooks[index].$1,
                                        scale,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  top: 70 * sidebarScale,
                  bottom: 64 * sidebarScale,
                  child: AppSidebar(
                    scale: sidebarScale,
                    isPhone: isPhone,
                    isOpen: _sideMenuOpen,
                    selectedIndex: 0,
                    onOpenChanged: (open) =>
                        setState(() => _sideMenuOpen = open),
                    onDestinationSelected: (index) {
                      setState(() => _sideMenuOpen = true);
                      switch (index) {
                        case 0:
                          break;
                        case 1:
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CatalogScreen(
                                displayName: widget.displayName,
                                userId: _accountId,
                              ),
                            ),
                          );
                        case 2:
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LibraryScreen(
                                displayName: widget.displayName,
                                userId: _accountId,
                                initialSidebarOpen: true,
                              ),
                            ),
                          );
                        case 3:
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProfileScreen(
                                displayName: widget.displayName,
                                userId: _accountId,
                              ),
                            ),
                          );
                      }
                    },
                  ),
                ),
                if (_showFloatingButton)
                  Positioned(
                    right: 8 * scale,
                    bottom: 64 * scale,
                    child: _FloatingQrButton(
                      scale: scale,
                      onClose: () =>
                          setState(() => _showFloatingButton = false),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => widget.paidPlan
                                ? PaidQrScreen(
                                    displayName: widget.displayName,
                                    userId: _accountId,
                                  )
                                : FreeQrScreen(
                                    displayName: widget.displayName,
                                    userId: _accountId,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(body: useFullScreen ? body : SafeArea(child: body));
  }
}

class _HomeNewsColumn extends StatelessWidget {
  const _HomeNewsColumn({required this.imagePaths});

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: imagePaths
          .map(
            (imagePath) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Opacity(
                  opacity: 0.62,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.paidPlan,
    required this.scale,
  });

  final String displayName;
  final bool paidPlan;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220 * scale,
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        16 * scale,
        18 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7D1A1),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 164 * scale,
                height: 164 * scale,
                padding: EdgeInsets.all(6 * scale),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: BookSmartEmblem(size: 152 * scale),
              ),
              SizedBox(width: 22 * scale),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useThreeLines = constraints.maxWidth < 260 * scale;
                    return Padding(
                      padding: EdgeInsets.only(top: 44 * scale),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          useThreeLines
                              ? 'BookSmart\nReading &\nknowledge'
                              : 'BookSmart\nReading & knowledge',
                          style: TextStyle(
                            fontSize: (useThreeLines ? 23 : 31) * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.05,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 16 * scale,
            bottom: -8 * scale,
            child: Text(
              '${localizedText(context, 'Bienvenido/a:', 'Welcome:')}     $displayName',
              style: TextStyle(
                fontSize: 25 * scale,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingQrButton extends StatelessWidget {
  const _FloatingQrButton({
    required this.scale,
    required this.onClose,
    required this.onPressed,
  });

  final double scale;
  final VoidCallback onClose;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = 62 * scale;
    return SizedBox(
      width: size + 12 * scale,
      height: size + 12 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6 * scale,
            bottom: 0,
            child: Material(
              color: Colors.black,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 48 * scale,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -1 * scale,
            top: -1 * scale,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, size: 22 * scale, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.title,
    required this.pages,
    required this.color,
    required this.imagePath,
    required this.scale,
    required this.onTap,
  });

  final String title;
  final String pages;
  final Color color;
  final String imagePath;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('home_book_$title'),
      onTap: onTap,
      child: SizedBox(
        width: 82 * scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 98 * scale,
              width: 68 * scale,
              margin: EdgeInsets.only(left: 8 * scale),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3 * scale),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3 * scale),
                child: BookCoverImage(path: imagePath),
              ),
            ),
            SizedBox(height: 5 * scale),
            Text(
              localizedText(context, 'Continuar..', 'Continue..'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '★ ${localizedText(context, pages, pages.replaceAll(' pág.', ' pages'))}',
              maxLines: 1,
              style: TextStyle(
                color: const Color(0xFFE8B72C),
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
