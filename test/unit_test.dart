import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart'; // Replace with your actual path

// Create a mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Create a mock class for User
class MockUser extends Mock implements User {}

// Define your FirebaseAuth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  throw UnimplementedError();
});

// Mock initialization function
Future<void> initializeFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

void main() {
  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        // Add more overrides for other Firebase services if needed
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('MyWidget displays correctly', (WidgetTester tester) async {
    await initializeFirebase(); // Initialize Firebase for the test environment

    final container = createProviderContainer();

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: AddInvoiceScreen(), // Replace with your actual widget
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Add Invoice'), findsOneWidget);

    // Interact with the widget
    await tester.tap(find.byKey(Key('Add Invoice')));
    await tester.pump(); // Rebuild the widget

    // Verify the state after interaction
    expect(find.text('Please add at least one item'), findsOneWidget);
  });
}
