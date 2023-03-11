// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../generated/l10n.dart';
// import '../../models/cart/cart_base.dart';
// import '../../widgets/common/loading_body.dart';
// import '../common/header_widget.dart';

// class MyCartScreen2 extends StatelessWidget {
//   const MyCartScreen2({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFCFCFC),
//       body: Selector<CartModel, bool>(
//         selector: (_, cartModel) => cartModel.calculatingDiscount,
//         builder: (context, calculatingDiscount, child) {
//           return LoadingBody(
//             isLoading: calculatingDiscount,
//             child: child!,
//           );
//         },
//         child: SafeArea(
//           bottom: false,
//           child: Column(
//             children: [
//               HeaderWidget(title: S.of(context).myCart, isShowback: false),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 200,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                   offset: const Offset(0, 0),
//                                   blurRadius: 10,
//                                   color: Colors.black.withOpacity(.09))
//                             ]),
//                       ),
//                       if (model.totalCartQuantity == 0) EmptyCart(),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
