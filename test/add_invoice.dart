import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart'; // Replace with your actual path

// Create a mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Create a mock class for User
class MockUser extends Mock implements User {}

// Define your FirebaseAuth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  throw UnimplementedError();
});

final mockUser = MockUser();

// Mock initialization function
Future<void> initializeFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

void main() {
  setUp(() {
    // Mock the current user
    when(mockUser.email).thenReturn('test@test.com');
    when(mockUser.uid).thenReturn('123456');
  });

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

  testWidgets('AddInvoiceScreen displays correctly and validates form', (WidgetTester tester) async {
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
    expect(find.text('Client Details'), findsOneWidget);
    expect(find.text('Business Details'), findsOneWidget);
    expect(find.text('Item Details'), findsOneWidget);

    // Fill out the form
    await tester.enterText(find.byKey(const Key('Add Invoice')), 'Test Client');
    await tester.enterText(find.byKey(const Key('Add Invoice')), 'Test Business');
    await tester.enterText(find.byKey(const Key('Add Invoice')), 'Test Item');
    await tester.enterText(find.byKey(const Key('Add Invoice')), 'Description of the item');
    await tester.enterText(find.byKey(const Key('Add Invoice')), '100'); // Unit Price
    await tester.enterText(find.byKey(const Key('Add Invoice')), '1'); // Quantity
    await tester.enterText(find.byKey(const Key('Add Invoice')), '0'); // Discount

    // Interact with the widget
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump(); // Rebuild the widget

    // Verify the state after interaction
    expect(find.text('Please fill all item fields'), findsNothing); // Assuming successful submission does not show this message

    // Add Invoice Button
    await tester.tap(find.byKey(const Key('Add Invoice')));
    await tester.pump(); // Rebuild the widget

    // Verify that a SnackBar is shown
    expect(find.text('Please add at least one item'), findsOneWidget);
  });
}
