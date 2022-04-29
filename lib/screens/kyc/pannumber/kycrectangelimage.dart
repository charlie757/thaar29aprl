// ignore_for_file: file_names, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:thaartransport/screens/kyc/pannumber/rectangelimage.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

class KycRectangelImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;
  KycRectangelImage({required this.onFileChanged});

  @override
  _KycRectangelImageState createState() => _KycRectangelImageState();
}

class _KycRectangelImageState extends State<KycRectangelImage> {
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          InkWell(
              onTap: () => _selectPhoto(),
              child: Container(
                  height: 150,
                  width: 300,
                  alignment: Alignment.center,
                  decoration: DottedDecoration(
                    shape: Shape.box,
                    borderRadius: BorderRadius.circular(
                        10), //remove this to get plane rectange
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt),
                      SizedBox(
                        height: 5,
                      ),
                      Text("UPLOAD")
                    ],
                  ))),
        if (imageUrl != null)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _selectPhoto(),
            child: RectangelImage.url(imageUrl!, width: 300, height: 150),
          ),
      ],
    );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {},
            builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.camera),
                      title: Text("Camera"),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.filter),
                      title: Text("Pick a files"),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    )
                  ],
                )));
  }

  Future _pickImage(ImageSource source) async {
    setState(() {
      loading = true;
    });
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile == null) {
        return;
      }
      var file = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          // CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          // CropAspectRatioPreset.original,
          // CropAspectRatioPreset.ratio4x3,

          // CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          hideBottomControls: true,

          // cropFrameColor: Colors.blue,
          toolbarColor: Constants.lightAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: true,
        ),
        // iosUiSettings: IOSUiSettings(
        //   minimumAspectRatio: 1.0,
        // ),
        compressQuality: 80,
        maxWidth: 200,
      );
      if (file == null) {
        return;
      }
      file = await compressImage(file.path, 35);
      await _uploadFile(file.path);
    } catch (e) {
      setState(() {
        loading = false;
      });

      showInSnackBar('Cancelled', context);
    }
    // await _UploadImageFirestore();
  }

  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);
    return result!;
  }

  Future _uploadFile(String path) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('PANCard')
        .child('${DateTime.now().toIso8601String() + p.basename(path)}');

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    setState(() {
      imageUrl = fileUrl;
      imageUrl = fileUrl;
    });
    widget.onFileChanged(fileUrl);
  }

  Future _UploadImageFirestore() async {
    Map<String, dynamic> data = {'img': imageUrl};
    await usersRef.add(data);
  }
}

void showInSnackBar(String value, context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
    value,
    style: TextStyle(fontSize: 16),
  )));
}
