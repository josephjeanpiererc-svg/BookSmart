import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.displayName = 'Usuario',
    this.paidPlan = false,
  });

  final String displayName;
  final bool paidPlan;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  bool _showFloatingButton = true;
  bool _sideMenuOpen = true;

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
        final phoneRailOpenWidth = 92.0 * scale;
        final phoneRailClosedWidth = 56.0 * scale;
        final contentPaddingLeft = isPhone
            ? 14 * scale +
                  (_sideMenuOpen ? phoneRailOpenWidth : phoneRailClosedWidth)
            : 14 * scale + (_sideMenuOpen ? 112 * scale : 48 * scale);
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
                if (kIsWeb && !isPhone && width >= 1000)
                  const Positioned.fill(
                    child: IgnorePointer(child: _NewsBackground()),
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
                                  'Continuar Leyendo',
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
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  'Novedades',
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
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  'Populares',
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
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  'Para ti',
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
                          : (_sideMenuOpen ? 130 * scale : 54 * scale),
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
                      child: isPhone
                          ? Column(
                              children: [
                                if (_sideMenuOpen) ...[
                                  _SideMenuItem(
                                    icon: Icons.home,
                                    label: 'Inicio',
                                    selected: _selectedTab == 0,
                                    scale: scale,
                                    onTap: () => setState(() {
                                      _selectedTab = 0;
                                      _sideMenuOpen = true;
                                    }),
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _SideMenuItem(
                                    icon: Icons.business_center,
                                    label: 'Catalogo',
                                    selected: _selectedTab == 1,
                                    scale: scale,
                                    onTap: () {
                                      setState(() {
                                        _selectedTab = 1;
                                        _sideMenuOpen = true;
                                      });
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => CatalogScreen(
                                            displayName: widget.displayName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _SideMenuItem(
                                    icon: Icons.menu_book,
                                    label: 'Mi Biblioteca',
                                    selected: _selectedTab == 2,
                                    scale: scale,
                                    onTap: () {
                                      setState(() {
                                        _selectedTab = 2;
                                        _sideMenuOpen = true;
                                      });
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
                                    selected: _selectedTab == 3,
                                    scale: scale,
                                    onTap: () {
                                      setState(() {
                                        _selectedTab = 3;
                                        _sideMenuOpen = true;
                                      });
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
                                const Spacer(),
                                IconButton(
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
                              ],
                            )
                          : _sideMenuOpen
                          ? Column(
                              children: [
                                _SideMenuItem(
                                  icon: Icons.home,
                                  label: 'Inicio',
                                  selected: _selectedTab == 0,
                                  scale: scale,
                                  onTap: () => setState(() {
                                    _selectedTab = 0;
                                    _sideMenuOpen = true;
                                  }),
                                ),
                                SizedBox(height: 14 * scale),
                                _SideMenuItem(
                                  icon: Icons.business_center,
                                  label: 'Catalogo',
                                  selected: _selectedTab == 1,
                                  scale: scale,
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 1;
                                      _sideMenuOpen = true;
                                    });
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => CatalogScreen(
                                          displayName: widget.displayName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 14 * scale),
                                _SideMenuItem(
                                  icon: Icons.menu_book,
                                  label: 'Mi Biblioteca',
                                  selected: _selectedTab == 2,
                                  scale: scale,
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 2;
                                      _sideMenuOpen = true;
                                    });
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
                                  selected: _selectedTab == 3,
                                  scale: scale,
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 3;
                                      _sideMenuOpen = true;
                                    });
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ProfileScreen(
                                          displayName: widget.displayName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _sideMenuOpen = false),
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: const Color(0xFF28639B),
                                    size: 30 * scale,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEFE4CF),
                                    shape: const CircleBorder(),
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 52 * scale,
                                height: 52 * scale,
                                margin: EdgeInsets.only(top: 8 * scale),
                                child: IconButton(
                                  onPressed: () =>
                                      setState(() => _sideMenuOpen = true),
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 28 * scale,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF5D7E9E),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                  ),
                                ),
                              ),
                            ),
                    ),
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
                                ? PaidQrScreen(displayName: widget.displayName)
                                : FreeQrScreen(displayName: widget.displayName),
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

    return Scaffold(
      floatingActionButton: const ScreenCloseButton(confirmExit: true),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: useFullScreen ? body : SafeArea(child: body),
    );
  }
}

class _NewsBackground extends StatelessWidget {
  const _NewsBackground();

  static const _leftImages = [
    'assets/images/noticias/NoticiaProyecto001.jpg',
    'assets/images/noticias/NoticiaProyecto002.jpg',
    'assets/images/noticias/NoticiaProyecto003.jpg',
  ];
  static const _rightImages = [
    'assets/images/noticias/NoticiaProyecto004.jpg',
    'assets/images/noticias/NoticiaProyecto005.jpg',
    'assets/images/noticias/NoticiaProyecto006.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(175, 48, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NewsColumn(imagePaths: _leftImages),
          _NewsColumn(imagePaths: _rightImages),
        ],
      ),
    );
  }
}

class _NewsColumn extends StatelessWidget {
  const _NewsColumn({required this.imagePaths});

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 205,
      child: Column(
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
      ),
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
                child: Padding(
                  padding: EdgeInsets.only(top: 44 * scale),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'BookSmart\nReading & knowledge',
                      style: TextStyle(
                        fontSize: 31 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16 * scale,
            bottom: -8 * scale,
            child: Text(
              'Bienvenido/a:     $displayName',
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
  });

  final String title;
  final String pages;
  final Color color;
  final String imagePath;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            'Continuar..',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w700),
          ),
          Text(
            '★ $pages',
            maxLines: 1,
            style: TextStyle(
              color: const Color(0xFFE8B72C),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
