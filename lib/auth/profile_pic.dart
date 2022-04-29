import 'dart:io';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/auth/post_view_modal.dart';
import 'package:thaartransport/auth/register_view_modal.dart';
import 'package:thaartransport/components/custom_image.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ProfilePicture extends StatefulWidget {
  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    RegisterViewModel registerViewModel =
        Provider.of<RegisterViewModel>(context);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: LoadingOverlay(
          isLoading: viewModel.loading,
          progressIndicator: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.blueGrey[900],
              backgroundColor: Colors.blue),
          opacity: 0.2,
          color: Colors.white,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Constants.thaartheme,
              title: const Text('Add a profile picture'),
              centerTitle: true,
              leading: const Icon(Icons.arrow_back),
            ),
            body: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              children: [
                InkWell(
                  onTap: () => showImageChoices(context, viewModel),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                      border: Border.all(
                        color: Colors.green,
                      ),
                    ),
                    child: viewModel.imgLink != null
                        ? CustomImage(
                            imageUrl: viewModel.imgLink!,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width - 30,
                            fit: BoxFit.cover,
                          )
                        : viewModel.mediaUrl == null
                            ? const Center(
                                child: Text(
                                  'upload your profile picture',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.green),
                                ),
                              )
                            : Image.file(
                                viewModel.mediaUrl!,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width - 30,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        color: Color(0XFF142438),
                        textColor: Constants.btntextinactive,
                        onPressed: () async {
                          viewModel.curentUser();
                          !isOnline
                              ? showSimpleNotification(
                                  Text(
                                    text,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  slideDismiss: true,
                                  background: color,
                                )
                              : viewModel.uploadProfilePicture(context);
                        },
                        child: const Text(
                          "UPLOAD",
                          style: TextStyle(fontSize: 18),
                        ))),
              ],
            ),
          ),
        ));
  }

  showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select'.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(camera: true, context: context);
                },
              ),
              ListTile(
                leading: Icon(Icons.file_copy_rounded),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
