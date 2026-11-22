import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/booksmart_database.dart';
import '../utils/app_localization.dart';
import '../utils/platform_layout.dart';
import '../utils/profile_image_picker.dart';
import '../utils/profile_image_persistence.dart';
import '../widgets/booksmart_widgets.dart';
import '../widgets/navigation/app_sidebar.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.displayName = 'Usuario', this.userId});

  final String displayName;
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImageBytes;
  bool _sideMenuOpen = true;

  String get _accountId => widget.userId ?? widget.displayName;

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    final bytes = await loadProfileImageForUser(_accountId);
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

    await saveProfileImageForUser(_accountId, bytes);

    if (!mounted) {
      return;
    }

    setState(() {
      _profileImageBytes = bytes;
    });
  }

  Future<void> _showPersonalData() async {
    final user = kIsWeb && widget.userId != null
        ? await BooksmartDatabase.instance.loadUser(widget.userId!)
        : null;
    if (!mounted) return;

    final unavailable = localizedText(context, 'No disponible', 'Unavailable');
    String valueOrUnavailable(String? value) =>
        value == null || value.isEmpty ? unavailable : value;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          localizedText(dialogContext, 'Datos personales', 'Personal data'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PersonalDataField(
              label: localizedText(dialogContext, 'Nombre', 'Name'),
              value: user?.displayName.isNotEmpty == true
                  ? user!.displayName
                  : widget.displayName,
            ),
            _PersonalDataField(
              label: localizedText(dialogContext, 'Usuario', 'Username'),
              value: valueOrUnavailable(user?.username),
            ),
            _PersonalDataField(
              label: localizedText(
                dialogContext,
                'Correo electrónico',
                'Email address',
              ),
              value: valueOrUnavailable(user?.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizedText(dialogContext, 'Cerrar', 'Close')),
          ),
        ],
      ),
    );
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
          final sidebarScale = AppSidebar.scaleFor(width);
          final sidebarWidth = AppSidebar.widthFor(
            scale: sidebarScale,
            isPhone: isPhone,
            isOpen: _sideMenuOpen,
          );

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
                            24 * scale + sidebarWidth,
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
                                      localizedText(
                                        context,
                                        'Cambiar foto',
                                        'Change photo',
                                      ),
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  Text(
                                    localizedText(
                                      context,
                                      'Bienvenido :',
                                      'Welcome:',
                                    ),
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
                                    label: localizedText(
                                      context,
                                      'Ajustes de lectura',
                                      'Reading settings',
                                    ),
                                    scale: scale,
                                  ),
                                  _ProfileOption(
                                    icon: Icons.notifications,
                                    label: localizedText(
                                      context,
                                      'Notificaciones',
                                      'Notifications',
                                    ),
                                    scale: scale,
                                  ),
                                  _ProfileOption(
                                    icon: Icons.lock_outline,
                                    label: localizedText(
                                      context,
                                      'Privacidad',
                                      'Privacy',
                                    ),
                                    scale: scale,
                                  ),
                                  _ProfileOption(
                                    icon: Icons.badge_outlined,
                                    label: localizedText(
                                      context,
                                      'Datos personales',
                                      'Personal data',
                                    ),
                                    scale: scale,
                                    onTap: _showPersonalData,
                                  ),
                                  SizedBox(height: 24 * scale),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50 * scale,
                                    child: ElevatedButton.icon(
                                      key: const ValueKey('logout_button'),
                                      onPressed: () =>
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pushNamedAndRemoveUntil(
                                            '/login',
                                            (route) => false,
                                          ),
                                      icon: const Icon(Icons.logout),
                                      label: Text(
                                        localizedText(
                                          context,
                                          'Cerrar sesión',
                                          'Sign out',
                                        ),
                                        style: TextStyle(
                                          fontSize: 16 * scale,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFB3261E,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14 * scale,
                                          ),
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
                      selectedIndex: 3,
                      onOpenChanged: (open) =>
                          setState(() => _sideMenuOpen = open),
                      onDestinationSelected: (index) {
                        if (index == 3) return;
                        final screen = switch (index) {
                          0 => HomeScreen(
                            displayName: widget.displayName,
                            userId: _accountId,
                          ),
                          1 => CatalogScreen(
                            displayName: widget.displayName,
                            userId: _accountId,
                          ),
                          2 => LibraryScreen(
                            displayName: widget.displayName,
                            userId: _accountId,
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

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.scale,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final comingSoon = localizedText(context, 'próximamente', 'coming soon');
    return InkWell(
      onTap:
          onTap ??
          () =>
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$label $comingSoon'))),
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

class _PersonalDataField extends StatelessWidget {
  const _PersonalDataField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          SelectableText(value),
        ],
      ),
    );
  }
}
