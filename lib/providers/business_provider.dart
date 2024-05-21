import 'package:invoice_maker/repository/business_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/models/business.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});



class AddBusinessController extends StateNotifier<AsyncValue<void>> {
  AddBusinessController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> addBusiness(Business business) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(businessRepositoryProvider).addBusiness(business);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for the AddBusinessController
final addBusinessControllerProvider =
StateNotifierProvider<AddBusinessController, AsyncValue<void>>((ref) {
  return AddBusinessController(ref);
});
