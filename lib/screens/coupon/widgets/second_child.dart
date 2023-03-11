import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../models/coupon_model.dart';
import 'first_child.dart';

class SecondChild extends StatelessWidget {
  final CouponModel value;
  final int index;

  const SecondChild({Key? key, required this.value, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 17, right: 17, top: 200),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kColorBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions apply',
                style: TextStyle(
                    fontSize: 12,
                    color: kColorBackCouponTitle8,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              const Text(
                '•  Offers is valid only on selected articlas',
                style: TextStyle(
                    fontSize: 12,
                    color: kColorBackCouponTitle6,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '•  ',
                    style: TextStyle(
                        fontSize: 12,
                        color: kColorBackCouponTitle6,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: Text(
                      'Coupon code can be applicable on order value above ₹14,999',
                      style: TextStyle(
                          fontSize: 12,
                          color: kColorBackCouponTitle6,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                '•  Other T&Cs may apply',
                style: TextStyle(
                    fontSize: 12,
                    color: kColorBackCouponTitle6,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
        FirstChild(value: value, index: index),
      ],
    );
  }
}
