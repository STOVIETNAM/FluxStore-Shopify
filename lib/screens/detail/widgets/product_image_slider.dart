import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common/config.dart';
import '../../../common/config/models/index.dart';
import '../../../common/constants.dart';
import '../../../common/tools/image_tools.dart';
import '../../../models/entities/index.dart';
import '../../../models/product_model.dart';
import 'image_galery.dart';
import 'video_feature.dart';

class ProductImageSlider extends StatefulWidget {
  final Product product;

  const ProductImageSlider({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();

  late final Timer _timer;
  int _lastInteraction = 0;

  Future<void> nextImage() async {
    if (!mounted || !_pageController.hasClients) {
      return;
    }

    /// Cancel if the page is scrolling.
    if (_pageController.page?.round() != _pageController.page) {
      return;
    }

    /// Cancel if user has touched the gallery within 3 seconds.
    if (DateTime.now().millisecondsSinceEpoch - 3000 <= _lastInteraction) {
      return;
    }

    /// Cancel if video is playing.
    if (hasVideo && _currentPage == 0) {
      return;
    }

    /// Next page if not ends..
    if (_currentPage + 1 < itemList.length) {
      return _pageController.goTo(_currentPage + 1);
    }

    /// Go to first page.
    return _pageController.goTo(0);
  }

  bool initialized = false;
  bool hasVideo = false;
  bool variationLoaded = false;

  late final String _videoUrl;
  final List<String> _images = [];
  final List<String> _variationImages = [];

  int _currentPage = 0;

  List<String> get itemList => {
        if (hasVideo) _videoUrl,
        ..._images,
        ..._variationImages,
      }.toList();

  List<String> get imagesList => {..._images, ..._variationImages}.toList();

  void updateVariationImages(List<String> newImages) {
    if (!widget.product.isVariableProduct ||
        _variationImages.isNotEmpty ||
        newImages.isEmpty ||
        newImages.length == _variationImages.length) {
      return;
    }
    for (var url in newImages) {
      if (!_variationImages.contains(url)) {
        _variationImages.add(url);
      }
    }
    initialized = true;
    if (!mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));

    final url = widget.product.videoUrl;
    if (url != null && url.isNotEmpty) {
      _videoUrl = url.replaceAll('http://', 'https://');
      hasVideo = true;
    }

    _images.addAll(widget.product.images);

    if (kProductDetail.autoPlayGallery) {
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) {
          nextImage();
        },
      );
    }

    if (kProductDetail.showSelectedImageVariant) {
      eventBus.on<EventChangeSelectedVariation>().listen((event) {
        if (!mounted) {
          return;
        }

        /// Skip first time when variation loaded.
        if (!variationLoaded) {
          variationLoaded = true;
          return;
        }

        final image = event.productVariation?.imageFeature;
        _pageController.goToUrl(image, itemList);
      });
    }
  }

  @override
  void dispose() {
    if (kProductDetail.autoPlayGallery) {
      _timer.cancel();
    }
    super.dispose();
  }

  void afterFirstLayout(BuildContext context) {
    if (widget.product.isVariableProduct) {
      updateVariationImages(
          context.read<ProductModel>().variationsFeatureImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      updateVariationImages(
          context.select((ProductModel _) => _.variationsFeatureImages));
    }

    if (itemList.isEmpty) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var top = constraints.biggest.height;
        return FlexibleSpaceBar(
          title: top > 71 && top < 91
              ? SizedBox(
                  width: 200,
                  child: Text(widget.product.name!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).appBarTheme.titleTextStyle),
                )
              : Container(),
          centerTitle: true,
          background: Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  onPointerDown: (_) => _updateLastInteraction(),
                  onPointerMove: (_) => _updateLastInteraction(),
                  onPointerHover: (_) => _updateLastInteraction(),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: itemList.length,
                    onPageChanged: (index) {
                      _currentPage = index;
                      setState(() {});
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (hasVideo && index == 0) {
                        return FeatureVideoPlayer(
                          url: itemList[index],
                          autoPlay: true,
                        );
                      }
                      return GestureDetector(
                        onTap: () => _onShowGallery(context, index),
                        child: Hero(
                          tag: 'slider_hero_tag_${itemList[index]}',
                          child: ImageTools.image(
                            url: itemList[index],
                            fit: ImageTools.boxFit(kProductDetail.boxFit),
                            size: kSize.large,
                            width: constraints.maxWidth,
                            hidePlaceHolder: true,
                            forceWhiteBackground:
                                kProductDetail.forceWhiteBackground,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_currentPage != 0 && kProductDetail.sliderShowGoBackButton)
                Align(
                  alignment: const Alignment(-1, 0.92),
                  child: GestureDetector(
                    onTap: () {
                      _pageController.goTo(0);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(23.0),
                          bottomRight: Radius.circular(23.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: const Icon(
                        CupertinoIcons.arrow_left,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              if (kProductDetail.sliderIndicatorType ==
                  SliderIndicatorType.number)
                Align(
                  alignment: const Alignment(0.95, 0.92),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(23.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      '${_currentPage + 1}/${itemList.length}',
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              if (kProductDetail.sliderIndicatorType == SliderIndicatorType.dot)
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  left: 16.0,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: itemList.length,
                    effect: const ScrollingDotsEffect(
                      dotWidth: 5.0,
                      dotHeight: 5.0,
                      spacing: 15.0,
                      fixedCenter: true,
                      dotColor: Colors.black45,
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateLastInteraction() {
    _lastInteraction = DateTime.now().millisecondsSinceEpoch;
  }

  void _onShowGallery(BuildContext context, [index = 0]) {
    Navigator.push(
      context,
      PageRouteBuilder(pageBuilder: (context, __, ___) {
        return ImageGalery(
          images: imagesList,
          index: hasVideo ? index - 1 : index,
          heroTagPrefix: 'slider_hero_tag_',
        );
      }),
    );
  }
}

extension on PageController {
  Future<void> goTo(int page) {
    return animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> goToUrl(String? url, List<String> urls) async {
    if (url == null || urls.isEmpty) {
      return;
    }

    final index = urls.indexOf(url);
    if (index == -1) {
      return;
    }
    return animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
