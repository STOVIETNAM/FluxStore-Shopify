import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/theme/colors.dart';
import '../../generated/l10n.dart';
import '../../models/coupon_model.dart';
import '../common/header_widget.dart';
import 'widgets/first_child.dart';
import 'widgets/second_child.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HeaderWidget(
                  title: S.of(context).applyCoupon,
                  trailing: const Text(
                    'Your Cart: ₹38,997.00',
                    style: TextStyle(
                        fontSize: 12,
                        color: kColorBackCouponTitle2,
                        fontFamily: 'Poppins'),
                  ),
                ),
                _textField(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                        top: 15, left: 0, right: 0, bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              S.of(context).bestCoupon,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: kColorBackCouponTitle5,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Consumer<CouponModel>(
                            builder: (context, value, child) {
                              return ListView.separated(
                                  padding: const EdgeInsets.only(top: 0),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return AnimatedCrossFade(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      crossFadeState: value.couponList[index]
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      firstChild: FirstChild(
                                          value: value, index: index),
                                      secondChild: SecondChild(
                                          value: value, index: index),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: 0,
                                    );
                                  },
                                  itemCount: value.couponList.length);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Padding _textField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Have any other coupon code',
          hintStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: kColorBackCouponTitle3,
              fontFamily: 'Poppins'),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                width: 0, style: BorderStyle.solid, color: Colors.black),
          ),
          alignLabelWithHint: true,
          suffixIconConstraints: const BoxConstraints(maxHeight: 50),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.solid,
                color: kColorBackCouponTitle3),
          ),
          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                S.of(context).apply.toUpperCase(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: kColorBackCouponTitle4,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
