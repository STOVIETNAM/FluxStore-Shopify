import 'package:flutter/material.dart';
import 'package:inspireui/icons/icon_picker.dart' deferred as defer_icon;
import 'package:inspireui/inspireui.dart' show DeferredWidget;
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/constants.dart';
import '../../../services/dependency_injection.dart';
import '../../../widgets/common/flux_image.dart';
import '../../../widgets/general/tool_tip.dart';
import '../config/app_config.dart';
import '../config/tab_bar_config.dart';
import '../helper/helper.dart';

class TabBarIcon extends StatelessWidget {
  final TabBarMenuConfig item;
  final int totalCart;
  final bool isEmptySpace;
  final bool isActive;
  final TabBarConfig config;

  const TabBarIcon({
    Key? key,
    required this.item,
    required this.totalCart,
    required this.isEmptySpace,
    required this.isActive,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEmptySpace) {
      return const SizedBox(
        width: 60,
        height: 2,
      );
    }

    Widget icon = Builder(
      builder: (_context) {
        var iconColor = IconTheme.of(_context).color;
        var isImage = item.icon.contains('/');
        return isImage
            ? FluxImage(
                imageUrl: item.icon,
                color: iconColor,
                width: config.iconSize,
              )
            : DeferredWidget(
                defer_icon.loadLibrary,
                () => Icon(
                  defer_icon.iconPicker(item.icon, item.fontFamily),
                  color: iconColor,
                  size: config.iconSize,
                ),
              );
      },
    );

    if (item.layout == 'cart') {
      icon = IconCart(icon: icon, totalCart: totalCart, config: config);
    }
    if (item.layout == 'category') {
      return OverlayTooltipItem(
          displayIndex: 2,
          tooltipVerticalPosition: TooltipVerticalPosition.TOP,
          tooltip: (controller) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: MTooltip(
                    nextOnTap: () {
                      controller.next();
                      injector<SharedPreferences>()
                          .setBool(LocalStorageKey.seenFortutorial, true);
                    },
                    title: 'Category',
                    subTitle: 'Explore 1000+ products in 25+ categories',
                    controller: controller),
              ),
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Tab(
              text: item.label,
              iconMargin: EdgeInsets.zero,
              icon: icon,
            ),
          ));
    }
    return Tab(
      text: item.label,
      iconMargin: EdgeInsets.zero,
      icon: icon,
    );
  }
}

class IconCart extends StatelessWidget {
  const IconCart({
    Key? key,
    required this.icon,
    required this.totalCart,
    required this.config,
  }) : super(key: key);

  final Widget icon;
  final int totalCart;
  final TabBarConfig config;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 5, right: 5),
          child: icon,
        ),
        if (totalCart > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: config.colorCart ?? Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                totalCart.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Layout.isDisplayDesktop(context) ? 14 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }
}
