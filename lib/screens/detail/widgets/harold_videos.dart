import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../models/entities/product.dart';
import '../../../models/harold_product_model.dart';
import '../../../widgets/common/index.dart';
import 'short_product_info.dart';
import 'video_items.dart';

class HaroldProductVideos extends StatefulWidget {
  final Product product;
  const HaroldProductVideos({required this.product, Key? key})
      : super(key: key);

  @override
  State<HaroldProductVideos> createState() => _HaroldProductVideosState();
}

class _HaroldProductVideosState extends State<HaroldProductVideos> {
  final videoPlayerController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

// await videoPlayerController.initialize();

  Future<void> initialize() async {
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    playerWidget = Chewie(
      controller: chewieController,
    );
  }

  var chewieController;

  var playerWidget;

  @override
  void initState() {
    // initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HaroldProductModel(product: widget.product)
          ..getDetailedHaroldProductModel(),
        child: getScaffold(context));
  }

  Scaffold getScaffold(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
          title: Text(
            'Video',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        body: Consumer<HaroldProductModel>(builder: (context, snapshot, _) {
          if (snapshot.isLoading) {
            return const LoadingWidget();
          }

          // if (!snapshot.isLoading && snapshot.videoError) {
          //   return Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text('We couldn\'t find any videos for this product.',
          //             textAlign: TextAlign.center,
          //             style: Theme.of(context).textTheme.titleLarge),
          //         TextButton(
          //             onPressed: () {
          //               snapshot.getDetailedHaroldProductModel();
          //             },
          //             child: Text('Refresh',
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .bodyText1!
          //                     .copyWith(color: Colors.blue[800])))
          //       ],
          //     ),
          //   );
          // }

          var haroldVideos = snapshot.getVideoUrlsFromHaroldProduct();
          // if (haroldVideos.isEmpty) {
          //   return Center(
          //     child: Text(
          //       ':( There are no videos for this product.',
          //       textAlign: TextAlign.center,
          //       style: Theme.of(context).textTheme.titleLarge,
          //     ),
          //   );
          // }

          return SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        '${widget.product.name}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        // 'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before final copy is available. It is also used to temporarily replace text in a process called greeking, which allows designers to consider the form of a webpage or publication, without the meaning of the text influencing the design.',
                        'We always go the extra mile for you to take a well-informed decision & that is what makes us india\'s most-rated lighting brand.',textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          launch(
                              'https://wa.me/919971772611?text=Hi%2C%20i%20am%20interested%20in%20${widget.product.name}.%20Can%20you%20show%20the%20product%20over%20video%20call%20%3F%20');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff44c0c0)),
                        child: const Text(
                          'Live Video Call',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    ShortProductInfo(
                      product: widget.product,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    getVideoColumn(haroldVideos, snapshot),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
                // CarouselSlider(
                //     options: CarouselOptions(
                //         scrollDirection: Axis.vertical,
                //         height:
                //             haroldVideos.isEmpty || haroldVideos.length == 1
                //                 ? MediaQuery.of(context).size.height * .6
                //                 : MediaQuery.of(context).size.height * .7,
                //         viewportFraction: 0.7,
                //         enableInfiniteScroll: false,
                //         pauseAutoPlayOnTouch: false),
                //     items: haroldVideos
                //         .map((e) => Padding(
                //               padding: const EdgeInsets.only(right: 16.0),
                //               child: GestureDetector(
                //                 onLongPress: () {
                //                   Navigator.push(
                //                       context,
                //                       MaterialPageRoute(
                //                         builder: (context) =>
                //                             FeatureVideoPlayer(
                //                           autoPlay: true,
                //                           control: true,
                //                           url: e,
                //                         ),
                //                       ));
                //                 },
                //                 child: FeatureVideoPlayer(
                //                   autoPlay: false,
                //                   control: true,
                //                   url: e,
                //                 ),
                //               ),
                //             ))
                //         .toList()),

                //  getVideoColumn(haroldVideos),
                // const SizedBox(
                //   height: 30,
                // )
              ],
            ),
          );
        }));
  }

  Widget getVideoColumn(
      List<String> haroldVideos, HaroldProductModel snapshot) {
    if (haroldVideos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        width: double.infinity,
        color: Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('We couldn\'t find any videos for this product.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            TextButton(
                onPressed: () {
                  snapshot.getDetailedHaroldProductModel();
                },
                child: Text('Refresh',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.blue[800])))
          ],
        ),
      );
    }
    return Container(
      // height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Video: ${haroldVideos.length}',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: haroldVideos.length,
              itemBuilder: ((context, index) => Container(
                    height: 300,
                    //color: Colors.red,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: VideoItems(
                      autoplay: false,
                      looping: true,
                      videoPlayerController:
                          VideoPlayerController.network(haroldVideos[index]),
                    ),
                  ))),
        ],
      ),
    );
  }
}
