import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Function? onBackTap;
  final bool? isShowback;
  const HeaderWidget(
      {Key? key,
      required this.title,
      this.trailing,
      this.onBackTap,
      this.isShowback = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 5),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kColorBackCouponTitle))),
      child: Row(
        children: [
          if (isShowback ?? false)
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (onBackTap != null) {
                      onBackTap!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset(
                    arrowLeft,
                    height: 20,
                    width: 20,
                  ),
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                color: kColorCouponBackArrow,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }
}
