import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_localization.dart';
import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import '../widgets/navigation/app_sidebar.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'pdf_reader_screen.dart';
import 'profile_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.displayName = 'Usuario',
    this.userId,
    this.initialBookTitle,
    this.initialSidebarOpen = true,
  });

  final String displayName;
  final String? userId;
  final String? initialBookTitle;
  final bool initialSidebarOpen;

  static List<String> ownedBooksFor(String user) =>
      CatalogScreen.ownedBookTitlesFor(user).toList();
  static List<String> get ownedBooks => CatalogScreen.ownedBookTitles.toList();

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late bool _sideMenuOpen = widget.initialSidebarOpen;
  double _sideMenuOffset = 0;
  int _selectedTab = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      CatalogScreen.restoreUserLibrary(_accountId)
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((Object error, StackTrace stackTrace) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'BookSmart local database',
                context: ErrorDescription('while loading a user library'),
              ),
            );
          });
    }
    if (widget.initialBookTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final book = widget.initialBookTitle!;
        if (CatalogScreen.ownedBookTitlesFor(_accountId).contains(book)) {
          _openInitialBook(book);
        }
      });
    }
  }

  void _openInitialBook(String title) {
    final scale = (MediaQuery.sizeOf(context).width / 600).clamp(0.82, 1.0);
    _LibraryBook(
      title: title,
      imagePath: CatalogScreen.imagePathForTitle(title),
      scale: scale,
      displayName: widget.displayName,
      userId: _accountId,
      isCompleted: CatalogScreen.completedBookTitlesFor(_accountId)
          .contains(title),
      isPending: CatalogScreen.pendingBookTitlesFor(_accountId).contains(title),
      isFavorite: CatalogScreen.favoriteBookTitlesFor(_accountId)
          .contains(title),
      onChanged: () => setState(() {}),
    )._openBookDetail(context);
  }

  String get _accountId => widget.userId ?? widget.displayName;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _activeBooks {
    final userKey = _accountId;
    final ownedBooks = CatalogScreen.ownedBookTitlesFor(userKey);
    switch (_selectedTab) {
      case 0:
        return CatalogScreen.readingBookTitlesFor(userKey)
            .where(ownedBooks.contains)
            .toList();
      case 1:
        final completed = CatalogScreen.completedBookTitlesFor(userKey);
        return completed.isEmpty
            ? []
            : completed.where(ownedBooks.contains).toList();
      case 2:
        final pending = CatalogScreen.pendingBookTitlesFor(userKey);
        return pending.isEmpty
            ? []
            : pending.where(ownedBooks.contains).toList();
      case 3:
        return CatalogScreen.favoriteBookTitlesFor(userKey)
            .where(ownedBooks.contains)
            .toList();
      default:
        return ownedBooks.toList();
    }
  }

  List<String> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _activeBooks;
    }

    return _activeBooks
        .where((title) => title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;
    final displayName = widget.displayName;
    final userId = _accountId;
    final activeBooks = _filteredBooks;

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
          final sidebarScale = AppSidebar.scaleFor(width);
          final sidebarWidth = AppSidebar.widthFor(
            scale: sidebarScale,
            isPhone: isPhone,
            isOpen: _sideMenuOpen,
          );
          final horizontalPadding = 30 * scale;
          final layoutWidth = frameWidth - (useFullScreen ? 0 : 18 * scale);
          final maxSidebarOffset = isPhone
              ? (layoutWidth - sidebarWidth - horizontalPadding - 180 * scale)
                    .clamp(0.0, double.infinity)
              : 0.0;
          final sidebarLeft = _sideMenuOffset.clamp(0.0, maxSidebarOffset);
          final contentLeftPadding = 14 * scale + sidebarLeft + sidebarWidth;

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
                            contentLeftPadding,
                            14 * scale,
                            16 * scale,
                            10 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'BookSmart',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 26 * scale,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6 * scale),
                                  _LibraryTabs(
                                    selectedTab: _selectedTab,
                                    scale: scale,
                                    onChanged: (index) => setState(() {
                                      _selectedTab = index;
                                      _searchController.clear();
                                    }),
                                  ),
                                  SizedBox(height: 10 * scale),
                                  TextField(
                                    key: const ValueKey('library_search_field'),
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: localizedText(
                                        context,
                                        'Buscar en mi biblioteca',
                                        'Search my library',
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 30 * scale,
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
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              _ReadingProgress(scale: scale),
                              SizedBox(height: 8 * scale),
                              Text(
                                'BookSmart',
                                style: TextStyle(
                                  fontSize: 24 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              if (activeBooks.isEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20 * scale,
                                    ),
                                    child: Text(
                                      _selectedTab == 0
                                          ? localizedText(
                                              context,
                                              'Aún no tienes libros en lectura.',
                                              'You have no books in progress yet.',
                                            )
                                          : _selectedTab == 1
                                          ? localizedText(
                                              context,
                                              'Aún no tienes libros completados.',
                                              'You have no completed books yet.',
                                            )
                                          : _selectedTab == 2
                                          ? localizedText(
                                              context,
                                              'Aún no tienes libros pendientes.',
                                              'You have no pending books yet.',
                                            )
                                          : localizedText(
                                              context,
                                              'Aún no tienes libros favoritos.',
                                              'You have no favorite books yet.',
                                            ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4C5663),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 6 * scale,
                                  mainAxisSpacing: 10 * scale,
                                  childAspectRatio: 0.72,
                                  children: activeBooks
                                      .map(
                                        (title) => _LibraryBook(
                                          title: title,
                                          imagePath:
                                              CatalogScreen.imagePathForTitle(
                                                title,
                                              ),
                                          scale: scale,
                                          displayName: widget.displayName,
                                          userId: userId,
                                          isCompleted:
                                              CatalogScreen.completedBookTitlesFor(
                                                userId,
                                              ).contains(title),
                                          isPending:
                                              CatalogScreen.pendingBookTitlesFor(
                                                userId,
                                              ).contains(title),
                                          isFavorite:
                                              CatalogScreen.favoriteBookTitlesFor(
                                                userId,
                                              ).contains(title),
                                          onChanged: () => setState(() {}),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: sidebarLeft,
                    top: 70 * sidebarScale,
                    bottom: 64 * sidebarScale,
                    child: AppSidebar(
                      scale: sidebarScale,
                      isPhone: isPhone,
                      isOpen: _sideMenuOpen,
                      selectedIndex: 2,
                      onOpenChanged: (open) =>
                          setState(() => _sideMenuOpen = open),
                      onHorizontalDragDelta: isPhone
                          ? (delta) => setState(() {
                              _sideMenuOffset = (sidebarLeft + delta).clamp(
                                0.0,
                                maxSidebarOffset,
                              );
                            })
                          : null,
                      onDestinationSelected: (index) {
                        if (index == 2) return;
                        final screen = switch (index) {
                          0 => HomeScreen(
                            displayName: displayName,
                            userId: userId,
                          ),
                          1 => CatalogScreen(
                            displayName: displayName,
                            userId: userId,
                          ),
                          3 => ProfileScreen(
                            displayName: displayName,
                            userId: userId,
                          ),
                          _ => null,
                        };
                        if (screen != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => screen),
                          );
                        }
                      },
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

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({
    required this.selectedTab,
    required this.scale,
    required this.onChanged,
  });

  final int selectedTab;
  final double scale;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      localizedText(context, 'Leyendo', 'Reading'),
      localizedText(context, 'Completados', 'Completed'),
      localizedText(context, 'Pendiente', 'Pending'),
      localizedText(context, 'Favorito', 'Favorites'),
    ];

    return SingleChildScrollView(
      key: const ValueKey('library_tabs_scroll'),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          tabs.length,
          (index) => GestureDetector(
            onTap: () => onChanged(index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: _LibraryTab(
                label: tabs[index],
                selected: selectedTab == index,
                scale: scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({
    required this.label,
    required this.scale,
    this.selected = false,
  });

  final String label;
  final double scale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: selected ? const Color(0xFFE9BD40) : Colors.black54,
        fontSize: 17 * scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReadingProgress extends StatefulWidget {
  const _ReadingProgress({required this.scale});

  final double scale;

  @override
  State<_ReadingProgress> createState() => _ReadingProgressState();
}

class _ReadingProgressState extends State<_ReadingProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    )..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = 0.72 + (_progressAnimation.value * 0.14);
    final pagesRead = 313;
    final pagesLeft = 6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(12 * widget.scale),
      decoration: BoxDecoration(
        color: const Color(0xFFC8CFCC),
        border: Border.all(
          color: const Color(0xFF1A90FF),
          width: 2.5 * widget.scale,
        ),
        borderRadius: BorderRadius.circular(22 * widget.scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A90FF).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 86 * widget.scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66 * widget.scale,
                  height: 66 * widget.scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF28639B),
                      width: 2.2 * widget.scale,
                    ),
                    color: const Color(0xFFE7F2FF),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$pagesRead',
                      style: TextStyle(
                        fontSize: 20 * widget.scale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B3554),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4 * widget.scale),
                Text(
                  localizedText(context, 'pág.\nleídas', 'pages\nread'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11 * widget.scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2A39),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14 * widget.scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedText(
                    context,
                    'Progreso de lectura',
                    'Reading progress',
                  ),
                  style: TextStyle(
                    fontSize: 17 * widget.scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B3554),
                  ),
                ),
                SizedBox(height: 6 * widget.scale),
                Text(
                  localizedText(
                    context,
                    '$pagesLeft páginas',
                    '$pagesLeft pages',
                  ),
                  style: TextStyle(
                    fontSize: 13 * widget.scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475A6C),
                  ),
                ),
                SizedBox(height: 10 * widget.scale),
                _AnimatedProgressBar(
                  value: progressValue,
                  scale: widget.scale,
                  label: localizedText(context, 'Avance', 'Progress'),
                ),
                SizedBox(height: 8 * widget.scale),
                _AnimatedProgressBar(
                  value: 0.86,
                  scale: widget.scale,
                  label: localizedText(context, 'Meta', 'Goal'),
                ),
                SizedBox(height: 6 * widget.scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    localizedText(context, '313 páginas', '313 pages'),
                    style: TextStyle(
                      fontSize: 11 * widget.scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C2D43),
                    ),
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

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.value,
    required this.scale,
    required this.label,
  });

  final double value;
  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            height: 10 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF20364C),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE4B958),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
              ),
            ),
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4 * scale),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E2A39),
              ),
            ),
          ),
      ],
    );
  }
}

class _LibraryBook extends StatelessWidget {
  const _LibraryBook({
    required this.title,
    required this.imagePath,
    required this.scale,
    required this.displayName,
    required this.userId,
    this.isCompleted = false,
    this.isPending = false,
    this.isFavorite = false,
    this.onChanged,
  });

  final String title;
  final String imagePath;
  final double scale;
  final String displayName;
  final String userId;
  final bool isCompleted;
  final bool isPending;
  final bool isFavorite;
  final VoidCallback? onChanged;

  void _openBookDetail(BuildContext context) {
    final book = CatalogScreen.detailsForTitle(title);
    if (book == null) {
      return;
    }

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
                SizedBox(height: 14 * scale),
                BookStatusControls(
                  scale: scale,
                  status: CatalogScreen.statusForTitle(title, userId),
                  isFavorite: CatalogScreen.favoriteBookTitlesFor(userId)
                      .contains(title),
                  onStatusChanged: (status) {
                    CatalogScreen.setBookStatus(title, status, userId);
                    onChanged?.call();
                  },
                  onFavoriteChanged: (isFavorite) {
                    CatalogScreen.setFavorite(title, isFavorite, userId);
                    onChanged?.call();
                  },
                ),
                SizedBox(height: 12 * scale),
                Text(
                  localizedText(context, 'Descripción', 'Description'),
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
                  label: localizedText(
                    context,
                    'Fecha de publicación',
                    'Publication date',
                  ),
                  value: book.$4,
                  scale: scale,
                ),
                SizedBox(height: 10 * scale),
                _DetailInfoRow(
                  label: localizedText(
                    context,
                    '¿De qué se trata?',
                    'About this book',
                  ),
                  value: book.$5,
                  scale: scale,
                ),
                SizedBox(height: 18 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PdfReaderScreen(
                            title: title,
                            assetPath: CatalogScreen.pdfPathForTitle(title),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5F9BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                    ),
                    child: Text(
                      localizedText(context, 'Leer', 'Read'),
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
    return InkWell(
      onTap: () => _openBookDetail(context),
      borderRadius: BorderRadius.circular(18 * scale),
      child: Container(
        padding: EdgeInsets.all(7 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFC7CDCB),
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12 * scale),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BookCoverImage(path: imagePath),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.50),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6 * scale,
                      right: 6 * scale,
                      bottom: 8 * scale,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (isFavorite)
                      Positioned(
                        top: 6 * scale,
                        right: 6 * scale,
                        child: _LibraryStatusBadge(
                          icon: Icons.favorite,
                          backgroundColor: const Color(0xFFF0C94D),
                          iconColor: const Color(0xFF2C6FB4),
                          scale: scale,
                        ),
                      ),
                    Positioned(
                      top: 38 * scale,
                      right: 6 * scale,
                      child: _LibraryStatusBadge(
                        icon:
                            CatalogScreen.completedBookTitlesFor(userId)
                                .contains(title)
                            ? Icons.check
                            : CatalogScreen.pendingBookTitlesFor(userId)
                                  .contains(title)
                            ? Icons.hourglass_top_rounded
                            : Icons.book_rounded,
                        backgroundColor:
                            CatalogScreen.completedBookTitlesFor(userId)
                                .contains(title)
                            ? const Color(0xFF2C6FB4)
                            : CatalogScreen.pendingBookTitlesFor(userId)
                                  .contains(title)
                            ? const Color(0xFFF0C94D)
                            : const Color(0xFF3B6FA9),
                        iconColor:
                            CatalogScreen.pendingBookTitlesFor(userId)
                                .contains(title)
                            ? const Color(0xFF1B3554)
                            : Colors.white,
                        scale: scale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4 * scale),
          ],
        ),
      ),
    );
  }
}

class _LibraryStatusBadge extends StatelessWidget {
  const _LibraryStatusBadge({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.scale,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26 * scale,
      height: 26 * scale,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 15 * scale, color: iconColor),
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
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 15 * scale,
            color: const Color(0xFF4C5663),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
