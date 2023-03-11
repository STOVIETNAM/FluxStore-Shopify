import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inspireui/widgets/platform_error/platform_error.dart';

import '../../common/constants.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class WebViewInApp extends StatefulWidget {
  final String url;
  final String? title;
  final Function(String?)? onUrlChanged;

  const WebViewInApp(
      {Key? key, required this.url, this.title, this.onUrlChanged})
      : super(key: key);

  @override
  _WebViewInAppState createState() => _WebViewInAppState();
}

class _WebViewInAppState extends State<WebViewInApp> {
  final GlobalKey webViewKey = GlobalKey();
  bool isLoaded = false;
  bool isDone = false;
  String addListingUrl = '';
  late var authUrl;
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  late PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.black45),
      onRefresh: () async {
        // var url = webViewController?.getUrl().toString();
        printLog('[WebView InApp] Pull to Refresh');
        if (isAndroid) {
          await webViewController?.reload();
        } else if (isIos) {
          await webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || isDesktop) {
      return const PlatformError(
        enablePop: false,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        title: Text(
          widget.title ?? '',
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(
          url: Uri.parse(widget.url),
        ),
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        gestureRecognizers: <Factory<VerticalDragGestureRecognizer>>{}..add(
            const Factory<VerticalDragGestureRecognizer>(
                VerticalDragGestureRecognizer.new),
          ),
        initialOptions: options,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        onLoadError: (controller, url, code, message) {
          pullToRefreshController.endRefreshing();
        },
        onProgressChanged: (_, progress) {
          if (progress == 100) {
            pullToRefreshController.endRefreshing();
          }
        },
        onUpdateVisitedHistory: (_, uri, androidIsReload) {
          if (widget.onUrlChanged != null) {
            widget.onUrlChanged!(uri?.toString());
          }
        },
      ),
    );
  }
}
