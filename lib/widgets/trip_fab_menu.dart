import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class TripFabMenu extends StatefulWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onEditTrip;

  const TripFabMenu({
    super.key,
    required this.onAddExpense,
    required this.onEditTrip,
  });

  @override
  State<TripFabMenu> createState() => _TripFabMenuState();
}

class _TripFabMenuState extends State<TripFabMenu> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);
  void _close() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // --- Secondary FABs (animated) ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _open
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  key: const ValueKey('fab_open_menu'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FloatingActionButton.extended(
                        heroTag: null,
                        onPressed: () {
                          _close();
                          widget.onAddExpense();
                        },
                        icon: const Icon(Symbols.garage_money),
                        label: const Text('Cargar gasto'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FloatingActionButton.extended(
                        heroTag: null,
                        onPressed: () {
                          _close();
                          widget.onEditTrip();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar viaje'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // --- Main FAB ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _open
              ? Material(
                  key: const ValueKey('fab_open'),
                  elevation: 6,
                  color: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: _toggle,
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: AnimatedRotation(
                        turns: 0.125,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.add, color: colors.onPrimary),
                      ),
                    ),
                  ),
                )
              : FloatingActionButton(
                  key: const ValueKey('fab_closed'),
                  heroTag: 'fab_main',
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  onPressed: _toggle,
                  child: const Icon(Icons.add),
                ),
        ),
      ],
    );
  }
}
