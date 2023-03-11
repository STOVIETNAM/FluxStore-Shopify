// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ProductVideos extends StatefulWidget {
  const ProductVideos({Key? key}) : super(key: key);

  @override
  State<ProductVideos> createState() => _ProductVideosState();
}

class _ProductVideosState extends State<ProductVideos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 500, child: Text('cndskc')),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 50,
                shrinkWrap: true,
                itemBuilder: ((context, index) => Container(
                      height: 300,
                      margin: const EdgeInsets.only(bottom: 30),
                      color: Colors.red,
                    )))
          ],
        ),
      ),
    );
  }
}
