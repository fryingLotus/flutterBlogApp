import 'dart:io';

import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/pick_image.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  static route({Blog? blog}) =>
      MaterialPageRoute(builder: (context) => AddNewBlogPage(blog: blog));

  final Blog? blog;

  const AddNewBlogPage({super.key, this.blog});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<String> selectedTopics = [];
  File? image;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.blog != null) {
      titleController.text = widget.blog!.title;
      contentController.text = widget.blog!.content;
      selectedTopics = widget.blog!.topics;
      // Assume you have a way to get the file from the URL for editing
      // image = File(widget.blog!.imageUrl);
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void uploadOrEditBlog() {
    if (formkey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        (image != null || widget.blog != null)) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

      if (widget.blog != null) {
        // Editing an existing blog
        context.read<BlogBloc>().add(BlogUpdate(
              blogId: widget.blog!.id,
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              image:
                  image ?? File(widget.blog!.imageUrl), // Handle existing image
              topics: selectedTopics,
            ));
      } else {
        // Creating a new blog
        context.read<BlogBloc>().add(BlogUpload(
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              image: image!,
              topics: selectedTopics,
            ));
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  uploadOrEditBlog();
                },
                icon: const Icon(Icons.done_rounded),
              ),
            ],
            elevation: 0,
          ),
        ),
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUploadSuccess || state is BlogUpdateSuccess) {
            Navigator.pushAndRemoveUntil(
                context, BlogPage.route(), (route) => false);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    image != null || widget.blog != null
                        ? GestureDetector(
                            onTap: () => selectImage(),
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: image != null
                                    ? Image.file(
                                        image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.blog!.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: DottedBorder(
                              color: AppPallete.borderColor,
                              dashPattern: const [10, 4],
                              radius: const Radius.circular(10),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 40,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Select Your Image",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Technology',
                          'Business',
                          'Programming',
                          'Entertainment',
                        ]
                            .map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedTopics.contains(e)) {
                                      selectedTopics.remove(e);
                                    } else {
                                      selectedTopics.add(e);
                                    }
                                    setState(() {});
                                  },
                                  child: Chip(
                                    label: Text(e),
                                    color: selectedTopics.contains(e)
                                        ? const WidgetStatePropertyAll(
                                            AppPallete.gradient1)
                                        : null,
                                    side: selectedTopics.contains(e)
                                        ? null
                                        : const BorderSide(
                                            color: AppPallete.borderColor),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlogEditor(
                        controller: titleController, hintText: 'Blog Title'),
                    const SizedBox(
                      height: 10,
                    ),
                    BlogEditor(
                        controller: contentController,
                        hintText: 'Blog Content...'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
