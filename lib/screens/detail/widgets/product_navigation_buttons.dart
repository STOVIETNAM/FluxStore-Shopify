import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/product.dart';
import '../../../services/dependency_injection.dart';
import '../../../widgets/common/webview.dart';
import '../../../widgets/general/tool_tip.dart';
import '../ask_a_question_screen.dart';

class ProductNavigationButtons extends StatelessWidget {
  final Product product;
  const ProductNavigationButtons({required this.product, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductNavigationButton(
          title: S.of(context).askAQuestion,
          onTap: () {
            Navigator.of(context).pushNamed(RouteList.askAQuestion,
                arguments: AskAQuestionArgument(product: product));
          },
        ),
        const Divider(),
        _ProductNavigationButton(
          title: S.of(context).warrantyAndInstallation,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebView(
                    url: Configurations.warrantyUrl,
                    title: S.of(context).warrantyAndInstallation),
              ),
            );
          },
        ),
        const Divider(),
        _ProductNavigationButton(
          title: S.of(context).customerRedressal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebView(
                    url: Configurations.customerRedressalUrl,
                    title: S.of(context).customerRedressal),
              ),
            );
          },
        ),
        const Divider(),
        OverlayTooltipItem(
          displayIndex: 2,
          tooltipVerticalPosition: TooltipVerticalPosition.BOTTOM,
          tooltip: (controller) => Padding(
            padding: const EdgeInsets.only(top: 15),
            child: MTooltip(
                nextOnTap: () {
                  controller.next();
                  injector<SharedPreferences>().setBool(
                      LocalStorageKey.seenFortutorialProductDetails, true);
                },
                title: 'Return And Refund',
                subTitle:
                    'Checkout our customer first return and refund policy',
                controller: controller),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _ProductNavigationButton(
              title: S.of(context).returnsAndRefunds,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebView(
                        url: Configurations.refundsAndReturnsUrl,
                        title: S.of(context).returnsAndRefunds),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductNavigationButton extends StatelessWidget {
  final String title;
  final Function onTap;
  const _ProductNavigationButton(
      {required this.title, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as VoidCallback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
          ),
          IconButton(
              onPressed: onTap as VoidCallback,
              icon: const Icon(
                Icons.chevron_right,
                size: 28,
              ))
        ],
      ),
    );
  }
}
