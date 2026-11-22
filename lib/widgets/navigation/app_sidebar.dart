import 'package:flutter/material.dart';

import '../../utils/app_localization.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.scale,
    required this.isPhone,
    required this.isOpen,
    required this.selectedIndex,
    required this.onOpenChanged,
    required this.onDestinationSelected,
    this.onHorizontalDragDelta,
    super.key,
  });

  final double scale;
  final bool isPhone;
  final bool isOpen;
  final int selectedIndex;
  final ValueChanged<bool> onOpenChanged;
  final ValueChanged<int> onDestinationSelected;
  final ValueChanged<double>? onHorizontalDragDelta;

  static double scaleFor(double availableWidth) {
    return (availableWidth / 430).clamp(0.72, 1.0);
  }

  static double widthFor({
    required double scale,
    required bool isPhone,
    required bool isOpen,
  }) {
    if (isPhone) {
      return (isOpen ? 92.0 : 56.0) * scale;
    }
    return (isOpen ? 130.0 : 54.0) * scale;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    if (onHorizontalDragDelta != null) {
      onHorizontalDragDelta!(delta);
      return;
    }

    if (delta > 0 && !isOpen) {
      onOpenChanged(true);
    } else if (delta < 0 && isOpen) {
      onOpenChanged(false);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (onHorizontalDragDelta != null) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 180) {
      onOpenChanged(true);
    } else if (velocity < -180) {
      onOpenChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      (Icons.home, localizedText(context, 'Inicio', 'Home')),
      (Icons.business_center, localizedText(context, 'Catalogo', 'Catalog')),
      (Icons.menu_book, localizedText(context, 'Mi Biblioteca', 'My Library')),
      (Icons.person, localizedText(context, 'Perfil', 'Profile')),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: isPhone ? _handleDragUpdate : null,
      onHorizontalDragEnd: isPhone ? _handleDragEnd : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: widthFor(scale: scale, isPhone: isPhone, isOpen: isOpen),
        padding: EdgeInsets.fromLTRB(
          8 * scale,
          12 * scale,
          8 * scale,
          12 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFDCC9AA),
          border: Border.all(color: const Color(0xFF2F6C9A), width: 3 * scale),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(18 * scale),
            bottomRight: Radius.circular(18 * scale),
          ),
        ),
        child: Column(
          children: [
            if (isOpen)
              ...List<Widget>.generate(destinations.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return SizedBox(height: 14 * scale);
                }
                final destinationIndex = index ~/ 2;
                final destination = destinations[destinationIndex];
                return _SidebarItem(
                  icon: destination.$1,
                  label: destination.$2,
                  selected: selectedIndex == destinationIndex,
                  scale: scale,
                  onTap: () => onDestinationSelected(destinationIndex),
                );
              }),
            const Spacer(),
            _SidebarToggle(
              scale: scale,
              isOpen: isOpen,
              onPressed: () => onOpenChanged(!isOpen),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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

class _SidebarToggle extends StatelessWidget {
  const _SidebarToggle({
    required this.scale,
    required this.isOpen,
    required this.onPressed,
  });

  final double scale;
  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = isOpen ? 44.0 : 52.0;
    final color = isOpen ? const Color(0xFF28639B) : Colors.white;
    return SizedBox(
      width: size * scale,
      height: size * scale,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isOpen ? Icons.chevron_left : Icons.menu,
          color: color,
          size: (isOpen ? 30.0 : 28.0) * scale,
        ),
        style: IconButton.styleFrom(
          backgroundColor: isOpen
              ? const Color(0xFFEFE4CF)
              : const Color(0xFF5D7E9E),
          foregroundColor: Colors.white,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
