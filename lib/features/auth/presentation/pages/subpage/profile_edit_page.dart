import 'dart:io'; // For platform checks
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/core/utils/pick_image.dart';
import 'package:blogapp/core/utils/show_snackbar.dart'; // Utility for showing snackbars
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:image_cropper/image_cropper.dart'; // Image cropping package

class ProfileEditPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const ProfileEditPage());
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  File? _selectedImage;

  Future<void> _pickAndUpdateImage() async {
    final imageFile = await pickImage();
    if (imageFile != null) {
      CroppedFile? croppedFile;

      // Check if the platform supports image cropping
      if (Platform.isIOS || Platform.isAndroid) {
        // Crop the image
        croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
            // WebUiSettings not needed here if not targeting web
          ],
        );
      }

      // If cropping was successful, use the cropped file
      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile!.path); // Ensure `path` is non-null
        });
      } else {
        setState(() {
          _selectedImage = imageFile;
        });
      }

      // Dispatch the event to update the profile picture
      if (_selectedImage != null) {
        context
            .read<AuthBloc>()
            .add(AuthUpdateProfilePicture(avatarImage: _selectedImage!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile Picture"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message, isError: true);
            } else if (state is AuthSuccess) {
              showSnackBar(context, "Profile picture updated successfully!");
              // Optionally, you might want to navigate back or update UI here
              setState(() {});
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedImage != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_selectedImage!),
                    )
                  else if (avatarUrl != null && avatarUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(avatarUrl),
                    )
                  else
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickAndUpdateImage,
                    child: const Text("Pick and Update Avatar"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

