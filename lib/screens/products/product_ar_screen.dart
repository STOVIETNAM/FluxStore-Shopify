// // ignore_for_file: unnecessary_this

// import 'dart:io';
// import 'dart:math';

// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
// import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:inspireui/utils/logs.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:vector_math/vector_math_64.dart';

// class ProductARScreen extends StatefulWidget {
//   final String source;
//   final String title;

//   const ProductARScreen({required this.source, required this.title});

//   @override
//   State<ProductARScreen> createState() => _ProductARScreenState();
// }

// class _ProductARScreenState extends State<ProductARScreen> {
//   late ARSessionManager arSessionManager;
//   late ARObjectManager arObjectManager;
//   ARNode? webObjectNode;
//   ARNode? fileSystemNode;
//   late HttpClient httpClient;

//   @override
//   void dispose() {
//     super.dispose();
//     arSessionManager.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             backgroundColor: Theme.of(context).backgroundColor,
//             elevation: 1,
//             centerTitle: true,
//             title: Text(
//               widget.title,
//               style: Theme.of(context)
//                   .appBarTheme
//                   .titleTextStyle
//                   ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
//             )),
//         body: Stack(children: [
//           ARView(
//             onARViewCreated: onARViewCreated,
//             planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
//           ),
//           Align(
//               alignment: FractionalOffset.bottomCenter,
//               child:
//                   Column(mainAxisAlignment: MainAxisAlignment.end, children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                         onPressed: onWebObjectAtOriginButtonPressed,
//                         child: Text("Add/Remove Web\nObject at Origin")),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                         onPressed: onWebObjectShuffleButtonPressed,
//                         child: Text("Shuffle Web\nObject at Origin")),
//                   ],
//                 )
//               ]))
//         ]));
//   }

//   void onARViewCreated(
//       ARSessionManager arSessionManager,
//       ARObjectManager arObjectManager,
//       ARAnchorManager arAnchorManager,
//       ARLocationManager arLocationManager) {
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;

//     this.arSessionManager.onInitialize(
//           showFeaturePoints: true,
//           showPlanes: true,
//           handlePans: true,
//           showAnimatedGuide: false,
//           //   customPlaneTexturePath: "Images/triangle.png",
//           showWorldOrigin: false,
//           handleTaps: false,
//         );
//     this.arObjectManager.onInitialize();

//     //Download model to file system
//     httpClient = HttpClient();
//     _downloadFile(widget.source, "animation_file.glb");
//   }

//   Future<File> _downloadFile(String url, String filename) async {
//     var request = await httpClient.getUrl(Uri.parse(url));
//     var response = await request.close();
//     var bytes = await consolidateHttpClientResponseBytes(response);
//     var dir = (await getApplicationDocumentsDirectory()).path;
//     var file = File('$dir/$filename');
//     await file.writeAsBytes(bytes);
//     printLog('Downloading finished, path: ' + '$dir/$filename');
//     return file;
//   }

//   Future<void> onWebObjectAtOriginButtonPressed() async {
//     if (this.webObjectNode != null) {
//       this.arObjectManager.removeNode(this.webObjectNode!);
//       this.webObjectNode = null;
//     } else {
//       var newNode = ARNode(
//           type: NodeType.webGLB,
//           uri: widget.source,
//           scale: Vector3(0.2, 0.2, 0.2));
//       var didAddWebNode = await this.arObjectManager.addNode(newNode);
//       webObjectNode = ((didAddWebNode!) ? newNode : null)!;
//     }
//   }

//   Future<void> onWebObjectShuffleButtonPressed() async {
//     if (this.webObjectNode != null) {
//       var newScale = Random().nextDouble() / 3;
//       var newTranslationAxis = Random().nextInt(3);
//       var newTranslationAmount = Random().nextDouble() / 3;
//       var newTranslation = Vector3(0, 0, 0);
//       newTranslation[newTranslationAxis] = newTranslationAmount;
//       var newRotationAxisIndex = Random().nextInt(3);
//       var newRotationAmount = Random().nextDouble();
//       var newRotationAxis = Vector3(0, 0, 0);
//       newRotationAxis[newRotationAxisIndex] = 1.0;

//       final newTransform = Matrix4.identity();

//       newTransform.setTranslation(newTranslation);
//       newTransform.rotate(newRotationAxis, newRotationAmount);
//       newTransform.scale(newScale);

//       if (webObjectNode != null) {
//         this.webObjectNode!.transform = newTransform;
//       }
//     }
//   }
// }

// class ProductARArguments {
//   final String source;
//   final String title;

//   ProductARArguments({required this.source, required this.title});
// }
