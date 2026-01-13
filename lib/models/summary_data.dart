import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Summary status used across the app
/// Labels are in Spanish per product copy.
enum SummaryStatus {
  approved,
  pendingApproval,
  calculationError,
  draft,
  calculationPending,
}

extension SummaryStatusX on SummaryStatus {
  String get label {
    switch (this) {
      case SummaryStatus.approved:
        return 'Aprobado';
      case SummaryStatus.pendingApproval:
        return 'Pendiente de aprobación';
      case SummaryStatus.calculationError:
        return 'Error durante el cálculo';
      case SummaryStatus.draft:
        return 'Borrador';
      case SummaryStatus.calculationPending:
        return 'Cálculo pendiente';
    }
  }

  /// Material icon for this status.
  IconData get icon {
    switch (this) {
      case SummaryStatus.approved:
        return Icons.check_circle_outlined;
      case SummaryStatus.pendingApproval:
        return Icons.pending_outlined;
      case SummaryStatus.calculationError:
        return Icons.error_outline;
      case SummaryStatus.draft:
        return Symbols.draft_orders;
      case SummaryStatus.calculationPending:
        return Icons.pause_circle_outline;
    }
  }

  /// Theme color associated with this status.
  /// Uses ColorScheme keys provided by the app theme.
  Color color(ColorScheme colors) {
    switch (this) {
      case SummaryStatus.approved:
        return colors.secondaryContainer;
      case SummaryStatus.pendingApproval:
        return colors.onSurfaceVariant;
      case SummaryStatus.calculationError:
        return colors.error;
      case SummaryStatus.draft:
        return colors.onPrimaryContainer;
      case SummaryStatus.calculationPending:
        return colors.tertiary;
    }
  }
}
