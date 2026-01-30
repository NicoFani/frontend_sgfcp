import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart' as month_picker_dialog;

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final colors = Theme.of(context).colorScheme;
  final locale = Localizations.localeOf(context);

  return month_picker_dialog.showMonthPicker(
    context: context,
    initialDate: DateTime(initialDate.year, initialDate.month),
    firstDate: firstDate,
    lastDate: lastDate,
    monthPickerDialogSettings: month_picker_dialog.MonthPickerDialogSettings(
      dialogSettings: month_picker_dialog.PickerDialogSettings(
        locale: locale,
        dialogRoundedCornersRadius: 28,
        dialogBackgroundColor: colors.surfaceContainerHigh,
      ),
      headerSettings: month_picker_dialog.PickerHeaderSettings(
        headerSelectedIntervalTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 24,
        ),
        headerCurrentPageTextStyle: TextStyle(
          color: colors.onSurfaceVariant,
        ),
        headerBackgroundColor: colors.surfaceContainerHigh,
        headerIconsColor: colors.onSurfaceVariant,
        headerPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      ),
      dateButtonsSettings: month_picker_dialog.PickerDateButtonsSettings(
        selectedMonthBackgroundColor: colors.secondaryContainer,
        selectedMonthTextColor: colors.onSecondaryContainer,
        unselectedMonthsTextColor: colors.onSurfaceVariant,
        currentMonthTextColor: colors.primary,
      ),
      actionBarSettings: const month_picker_dialog.PickerActionBarSettings(
        actionBarPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        confirmWidget: Text('Aceptar'),
        cancelWidget: Text('Cancelar'),
      ),
    ),
  );
}
