import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

class MTooltip extends StatelessWidget {
  final TooltipController controller;
  final String title;
  final String subTitle;
  final Function? nextOnTap;

  const MTooltip(
      {Key? key,
      required this.controller,
      required this.title,
      this.nextOnTap,
      required this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentDisplayIndex = controller.nextPlayIndex + 1;
    final totalLength = controller.playWidgetLength;

    return Container(
      width: size.width * .7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  WidgetSpan(
                    child: Opacity(
                      opacity: totalLength == 1 ? 0 : 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '$currentDisplayIndex OF $totalLength',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  )
                ])),
                InkWell(
                  onTap: controller.dismiss,
                  child: Icon(Icons.cancel_outlined,
                      color: Colors.black.withOpacity(.6), size: 18),
                )
              ],
            ),
          ),
          Divider(
            height: 32,
            thickness: 1,
            color: Colors.grey[100],
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: Text(
              subTitle,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  if (nextOnTap == null) {
                    controller.next();
                  } else {
                    nextOnTap!();
                  }
                },
                icon: const Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 30,
                ),
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
