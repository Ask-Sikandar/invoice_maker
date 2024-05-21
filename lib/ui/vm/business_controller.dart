// import 'package:invoice_maker/providers/business_provider.dart';
// import 'package:invoice_maker/models/business.dart';
//
// class BusinessLogic{
//   BusinessLogic(this._read);
//   get businessProvider => null;
//
//   Future<bool> clickAddBusiness(String name, String address, String phoneNumber, String email, String abn){
//     // Create a Business object with the entered data
//     Business newBusiness = Business(
//       name: name,
//       address: address,
//       phoneNumber: phoneNumber,
//       email: email,
//       abn: abn,
//     );
//     context.read(addBusinessControllerProvider.notifier).addBusiness(newBusiness);
//
//     // Do something with the newBusiness object, like saving it to a database
//     print(newBusiness);
//     businessProvider.addBusiness(newBusiness);
//
//   }
// }