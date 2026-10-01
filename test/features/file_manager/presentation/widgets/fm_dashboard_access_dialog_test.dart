import 'package:dio/dio.dart';
import 'package:beige/features/file_manager/data/repositories/workspace_access_repository.dart';
import 'package:beige/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige/features/file_manager/presentation/widgets/fm_share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late WorkspaceAccessRepository repository;
  late List<RequestOptions> requests;
  setUp(() {
    requests = [];
    final clients = <Map<String, dynamic>>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          dynamic data;
          if (request.method == 'POST') {
            expect(request.data, {
              'externalId': 'f-123',
              'email': 'test.client@example.com',
            });
            final client = {
              'email': request.data['email'],
              'name': null,
              'pending': true,
            };
            clients.add({...client, 'accessId': 42});
            data = {
              'success': true,
              'message': 'Email invited. Access will appear after signup.',
              'data': {...client, 'emailSent': true},
            };
          } else if (request.method == 'DELETE') {
            expect(request.path, 'external-file-manager/workspace-access/42');
            expect(request.data, isNull);
            clients.clear();
            data = {'success': true, 'message': 'Client access removed'};
          } else {
            expect(request.queryParameters, {'externalId': 'f-123'});
            data = {
              'success': true,
              'data': {
                'owner': {'name': 'Owner', 'email': 'owner@example.com'},
                'access': List.of(clients),
              },
            };
          }
          handler.resolve(
            Response(requestOptions: request, data: data, statusCode: 200),
          );
        },
      ),
    );
    repository = WorkspaceAccessRepository(dio);
  });
  const target = FmShareTarget(
    key: FmFolderKey(externalId: 'f-123'),
    name: 'Event - New Common',
  );

  testWidgets('opens Dashboard Access as a bottom sheet', (tester) async {
    await tester.pumpProviderApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => FmShareSheet.show(context, target: target),
            child: const Text('Open sharing'),
          ),
        ),
      ),
      overrides: [
        workspaceAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await tester.tap(find.text('Open sharing'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    // Verify Title and Folder Name via RichText
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Dashboard Access') &&
            w.text.toPlainText().contains('(Event - New Common)'),
      ),
      findsOneWidget,
    );

    // Verify Subtitle
    expect(
      find.text(
        'Invite people by email to access this entire workspace in their client dashboard.',
      ),
      findsOneWidget,
    );

    // Verify Email Field & Invite Button
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    expect(find.byIcon(Icons.person_add_alt), findsOneWidget);

    // Verify Note Text
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Note:-') &&
            w.text.toPlainText().contains(
              'To view this workspace in their dashboard, the recipient must log in or sign up with the same email address.',
            ),
      ),
      findsOneWidget,
    );

    // Verify "Shared With" section and empty state
    expect(find.text('Shared With'), findsOneWidget);
    expect(find.text('No extra client access yet.'), findsOneWidget);
  });

  testWidgets('allows inviting and revoking a client', (tester) async {
    await tester.pumpProviderApp(
      const Scaffold(body: FmDashboardAccessDialog(target: target)),
      overrides: [
        workspaceAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );

    await tester.pumpAndSettle();

    // Enter email
    await tester.enterText(find.byType(TextField), 'test.client@example.com');
    await tester.pump();

    // Tap Invite
    await tester.tap(find.text('Invite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 4)); // dismiss top message

    // Verify client appears in Shared With list
    expect(find.text('test.client@example.com'), findsOneWidget);
    expect(find.text('Pending signup'), findsOneWidget);
    expect(find.text('No extra client access yet.'), findsNothing);

    // Revoke access
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 4));

    // Verify list goes back to empty state
    expect(requests.map((r) => r.method), ['GET', 'POST', 'GET', 'DELETE']);
    expect(find.text('test.client@example.com'), findsNothing);
    expect(find.text('No extra client access yet.'), findsOneWidget);
  });
}
