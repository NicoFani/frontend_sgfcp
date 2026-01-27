import 'package:flutter/foundation.dart';

// Global notifier to signal when user data needs to be refreshed
final userRefreshNotifier = ValueNotifier<int>(0);

void triggerUserRefresh() {
  userRefreshNotifier.value++;
}
