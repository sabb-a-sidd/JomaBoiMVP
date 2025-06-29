import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jomaboi/constants.dart';
import 'package:jomaboi/models/user_model.dart';
import 'package:jomaboi/providers/authentication_provider.dart';
import 'package:jomaboi/utilities/global_methods.dart';
import 'package:jomaboi/widgets/app_bar_back_button.dart';
import 'package:jomaboi/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    await cropImage(finalFileImage?.path);
    popContext();
  }

  void popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text('User Information'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              DisplayUserImage(
                finalFileImage: finalFileImage,
                radius: 60,
                onPressed: () {
                  showBottomSheet();
                },
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: MaterialButton(
                  onPressed: context.read<AuthenticationProvider>().isLoading
                      ? null
                      : () {
                          if (_nameController.text.isEmpty ||
                              _nameController.text.length < 3) {
                            showSnackBar(context, 'Please enter your name');
                            return;
                          }
                          saveUserDataToFireStore();
                        },
                  child: context.watch<AuthenticationProvider>().isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using JomaBoi Co-Operative',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        await authProvider.saveUserDataToSharedPreferences();
        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.mainScreen,
      (route) => false,
    );
  }
}
