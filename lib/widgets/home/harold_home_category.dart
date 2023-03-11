import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../models/entities/back_drop_arguments.dart';
import '../../modules/firebase/firebase_analytics_service.dart';
import '../../routes/flux_navigate.dart';

class HaroldMainCategory extends StatelessWidget {
  final Map<String, dynamic> config;

  const HaroldMainCategory({required this.config, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 5,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (config['catId'] != null) {
                  FluxNavigate.pushNamed(
                    RouteList.backdrop,
                    arguments: BackDropArguments(
                        cateId: config['catId'], showAppBar: false),
                  );
                }
              },
              child: Image.network(
                config['image'],
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(config['name'],
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 20, color: Colors.black)),
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: config['subCategories'].length,
                    itemBuilder: (context, index) {
                      String name = config['subCategories'][index]['name'];
                      String catId = config['subCategories'][index]['catId'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                FirebaseAnalyticsService.haroldCategory({
                                  'category': config['name'],
                                  'subCategory': name
                                });
                                FluxNavigate.pushNamed(
                                  RouteList.backdrop,
                                  arguments: BackDropArguments(
                                      cateId: catId, showAppBar: false),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color: Theme.of(context).primaryColor,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                            index != config['subCategories'].length - 1
                                ? const Divider()
                                : Container()
                          ],
                        ),
                      );
                    })
              ],
            ),
          )
        ]),
      ),
    );
  }
}
