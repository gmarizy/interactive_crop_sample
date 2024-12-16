import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'interactive_crop.dart';


class PictureCropScreen extends StatelessWidget {
  const PictureCropScreen({super.key});

  Future<Uint8List> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/sample.jpg');
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CropController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Picture"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 4,
            ),
            child: IconButton(
              icon: const Icon(Icons.check),
              onPressed: controller.crop,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading image'));
            }
            return InteractiveCrop(
              controller: controller,
              image: snapshot.data!,
              aspectRatio: 9 / 16,
              onCropped: (picture) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Cropped Picture"),
                      content: Image.memory(picture),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}