import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../models/coupon_model.dart';

class FirstChild extends StatelessWidget {
  final CouponModel value;
  final int index;

  const FirstChild({Key? key, required this.value, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: const BoxDecoration(
          image:
              DecorationImage(image: AssetImage(couponCard), fit: BoxFit.fill)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 35, top: 0),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                '10% OFF',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: MediaQuery.of(context).size.width * 0.06,
                  right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'SEAS10',
                        style: TextStyle(
                            fontSize: 20,
                            color: kColorBackCouponTitle5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      ),
                      Spacer(),
                      Text(
                        'APPLY',
                        style: TextStyle(
                            fontSize: 14,
                            color: kColorRedCoupon,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const Text(
                    'Save more 10% extra',
                    style: TextStyle(
                        fontSize: 14,
                        color: kColorGreenCoupon,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10, bottom: 15),
                    decoration: DottedDecoration(),
                  ),
                  const Text(
                    'Use code SEAS10 & get 10% off on order value above ₹14,999.  we can also add more content ',
                    style: TextStyle(
                        fontSize: 12,
                        color: kColorBackCouponTitle6,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      value.changeValue(index);
                    },
                    child: Row(
                      children: [
                        const Text(
                          'KNOW MORE',
                          style: TextStyle(
                              fontSize: 12,
                              color: kColorBackCouponTitle7,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 15),
                        RotatedBox(
                          quarterTurns: (value.couponList[index]) ? 2 : 0,
                          child: Image.asset(
                            arrowDown,
                            height: 10,
                            width: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
