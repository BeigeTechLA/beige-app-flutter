import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/report_builder.dart';
import 'cases/route_load_test.dart';
import 'cases/guard_test.dart';
import 'cases/deep_link_test.dart';
import 'cases/back_nav_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final report = ReportBuilder();

  group('Navigation Test Suite', () {
    setUpAll(() async {
      report.startSession();
    });

    tearDownAll(() async {
      await report.writeReport();
    });

    runRouteLoadTests(report);
    runGuardTests(report);
    runDeepLinkTests(report);
    runBackNavTests(report);
  });
}
