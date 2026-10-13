import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'pdf_reader_screen.dart';
import 'profile_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.displayName = 'Usuario',
    this.initialBookTitle,
  });

  final String displayName;
  final String? initialBookTitle;

  static List<String> ownedBooksFor(String user) =>
      CatalogScreen.ownedBookTitlesFor(user).toList();
  static List<String> get ownedBooks => CatalogScreen.ownedBookTitles.toList();

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _sideMenuOpen = true;
  int _selectedTab = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialBookTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final book = widget.initialBookTitle!;
        if (CatalogScreen.ownedBookTitlesFor(widget.displayName)
            .contains(book)) {
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
      isCompleted: CatalogScreen.completedBookTitlesFor(widget.displayName)
          .contains(title),
      isPending: CatalogScreen.pendingBookTitlesFor(widget.displayName)
          .contains(title),
      isFavorite: CatalogScreen.favoriteBookTitlesFor(widget.displayName)
          .contains(title),
      onChanged: () => setState(() {}),
    )._openBookDetail(context);
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

  List<String> get _activeBooks {
    final userKey = widget.displayName;
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
          final phoneRailOpenWidth = 112.0 * scale;
          final phoneRailClosedWidth = 58.0 * scale;
          final contentLeftPadding = isPhone
              ? 14 * scale +
                    (_sideMenuOpen ? phoneRailOpenWidth : phoneRailClosedWidth)
              : 14 * scale + (_sideMenuOpen ? 108 * scale : 48 * scale);
          final menuWidth = isPhone ? phoneRailOpenWidth : 118.0 * scale;

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
                                      hintText: 'Buscar en mi biblioteca',
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
                                          ? 'Aún no tienes libros en lectura.'
                                          : _selectedTab == 1
                                          ? 'Aún no tienes libros completados.'
                                          : _selectedTab == 2
                                          ? 'Aún no tienes libros pendientes.'
                                          : 'Aún no tienes libros favoritos.',
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
                                          isCompleted:
                                              CatalogScreen.completedBookTitlesFor(
                                                widget.displayName,
                                              ).contains(title),
                                          isPending:
                                              CatalogScreen.pendingBookTitlesFor(
                                                widget.displayName,
                                              ).contains(title),
                                          isFavorite:
                                              CatalogScreen.favoriteBookTitlesFor(
                                                widget.displayName,
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
                                      builder: (_) =>
                                          HomeScreen(displayName: displayName),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 14 * scale),
                              _SideMenuItem(
                                icon: Icons.business_center,
                                label: 'Catalogo',
                                selected: false,
                                scale: scale,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CatalogScreen(
                                        displayName: displayName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 14 * scale),
                              _SideMenuItem(
                                icon: Icons.menu_book,
                                label: 'Mi Biblioteca',
                                selected: true,
                                scale: scale,
                                onTap: () {},
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
                                        displayName: displayName,
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
                                    foregroundColor: Colors.white,
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
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

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({required this.selectedTab, required this.onChanged});

  final int selectedTab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = ['Leyendo', 'Completados', 'Pendiente', 'Favorito'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        tabs.length,
        (index) => GestureDetector(
          onTap: () => onChanged(index),
          child: _LibraryTab(
            label: tabs[index],
            selected: selectedTab == index,
          ),
        ),
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: selected ? const Color(0xFFE9BD40) : Colors.black54,
        fontSize: 17,
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
                  'pag\nleídas',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Progreso',
                      style: TextStyle(
                        fontSize: 17 * widget.scale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B3554),
                      ),
                    ),
                    SizedBox(width: 8 * widget.scale),
                    Text(
                      'de Lectura',
                      style: TextStyle(
                        fontSize: 17 * widget.scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B3554),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * widget.scale),
                Text(
                  '$pagesLeft páginas',
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
                  label: 'Avance',
                ),
                SizedBox(height: 8 * widget.scale),
                _AnimatedProgressBar(
                  value: 0.86,
                  scale: widget.scale,
                  label: 'Meta',
                ),
                SizedBox(height: 6 * widget.scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '313 páginas',
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
    this.isCompleted = false,
    this.isPending = false,
    this.isFavorite = false,
    this.onChanged,
  });

  final String title;
  final String imagePath;
  final double scale;
  final String displayName;
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
                  status: CatalogScreen.statusForTitle(title, displayName),
                  isFavorite: CatalogScreen.favoriteBookTitlesFor(displayName)
                      .contains(title),
                  onStatusChanged: (status) {
                    CatalogScreen.setBookStatus(title, status, displayName);
                    onChanged?.call();
                  },
                  onFavoriteChanged: (isFavorite) {
                    CatalogScreen.setFavorite(title, isFavorite, displayName);
                    onChanged?.call();
                  },
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
                      'Leer',
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
                            CatalogScreen.completedBookTitlesFor(displayName)
                                .contains(title)
                            ? Icons.check
                            : CatalogScreen.pendingBookTitlesFor(displayName)
                                  .contains(title)
                            ? Icons.hourglass_top_rounded
                            : Icons.book_rounded,
                        backgroundColor:
                            CatalogScreen.completedBookTitlesFor(displayName)
                                .contains(title)
                            ? const Color(0xFF2C6FB4)
                            : CatalogScreen.pendingBookTitlesFor(displayName)
                                  .contains(title)
                            ? const Color(0xFFF0C94D)
                            : const Color(0xFF3B6FA9),
                        iconColor:
                            CatalogScreen.pendingBookTitlesFor(displayName)
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
