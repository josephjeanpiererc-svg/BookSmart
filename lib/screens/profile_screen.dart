import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../utils/profile_image_picker.dart';
import '../utils/profile_image_persistence.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.displayName = 'Usuario'});

  final String displayName;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImageBytes;
  bool _sideMenuOpen = true;

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
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    final bytes = await loadProfileImageForUser(widget.displayName);
    if (!mounted) {
      return;
    }

    setState(() {
      _profileImageBytes = bytes;
    });
  }

  Future<void> _pickProfileImage() async {
    final bytes = await pickProfileImage();
    if (bytes == null) {
      return;
    }

    await saveProfileImageForUser(widget.displayName, bytes);

    if (!mounted) {
      return;
    }

    setState(() {
      _profileImageBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;

    return Scaffold(
      backgroundColor: Colors.white,
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
              ? (width / 430).clamp(0.72, 1.0)
              : (frameWidth / 375).clamp(0.68, 1.1);
          final phoneRailOpenWidth = 92.0 * scale;
          final phoneRailClosedWidth = 56.0 * scale;

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
                            isPhone
                                ? 24 * scale +
                                      (_sideMenuOpen
                                          ? phoneRailOpenWidth
                                          : phoneRailClosedWidth)
                                : 24 * scale +
                                      (_sideMenuOpen
                                          ? 120 * scale
                                          : 52 * scale),
                            34 * scale,
                            24 * scale,
                            18 * scale,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 380),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _pickProfileImage,
                                    child: Container(
                                      width: 150 * scale,
                                      height: 150 * scale,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF285A98),
                                        shape: BoxShape.circle,
                                        image: _profileImageBytes != null
                                            ? DecorationImage(
                                                image: MemoryImage(
                                                  _profileImageBytes!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _profileImageBytes == null
                                          ? Icon(
                                              Icons.person,
                                              size: 110 * scale,
                                              color: const Color(0xFFFFF2DB),
                                            )
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 8 * scale),
                                  TextButton(
                                    onPressed: _pickProfileImage,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF285A98),
                                    ),
                                    child: Text(
                                      'Cambiar foto',
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  Text(
                                    'Bienvenido :',
                                    style: TextStyle(
                                      fontSize: 26 * scale,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    widget.displayName,
                                    style: TextStyle(
                                      fontSize: 30 * scale,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 18 * scale),
                                  _ProfileOption(
                                    icon: Icons.settings,
                                    label: 'Ajustes de lectura',
                                    scale: scale,
                                  ),
                                  _ProfileOption(
                                    icon: Icons.notifications,
                                    label: 'Notificaciones',
                                    scale: scale,
                                  ),
                                  _ProfileOption(
                                    icon: Icons.lock_outline,
                                    label: 'Privacidad',
                                    scale: scale,
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
                                      selected: false,
                                      scale: scale,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => HomeScreen(
                                              displayName: widget.displayName,
                                            ),
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
                                      selected: true,
                                      scale: scale,
                                      onTap: () {},
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
                                      foregroundColor: Colors.white,
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
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
                                    selected: false,
                                    scale: scale,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => HomeScreen(
                                            displayName: widget.displayName,
                                          ),
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
                                    selected: true,
                                    scale: scale,
                                    onTap: () {},
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
                                      foregroundColor: Colors.white,
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 46 * scale,
                                  height: 46 * scale,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5D7E9E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        setState(() => _sideMenuOpen = true),
                                    icon: Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 26 * scale,
                                    ),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 18 * scale,
                                    constraints: const BoxConstraints(),
                                    style: IconButton.styleFrom(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$label próximamente'))),
      borderRadius: BorderRadius.circular(14 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF285A98), size: 30 * scale),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF285A98),
              size: 30 * scale,
            ),
          ],
        ),
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
