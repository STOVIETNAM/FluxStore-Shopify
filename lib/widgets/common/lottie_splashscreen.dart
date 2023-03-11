import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieSplashScreen extends StatefulWidget {
  final String imageUrl;
  final int duration;
  final Function? onSuccess;
  const LottieSplashScreen({
    required this.imageUrl,
    this.duration = 1000,
    this.onSuccess,
  });

  @override
  _StateLottieSplashScreen createState() => _StateLottieSplashScreen();
}

class _StateLottieSplashScreen extends State<LottieSplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: widget.duration), () {
        widget.onSuccess?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: widget.imageUrl.startsWith('http')
            ? Lottie.network(
                widget.imageUrl,
                errorBuilder: (_, __, ___) {
                  return const SizedBox();
                },
              )
            : Lottie.asset(
                widget.imageUrl,
                errorBuilder: (_, __, ___) {
                  return const SizedBox();
                },
              ),
      ),
    );
  }
}
