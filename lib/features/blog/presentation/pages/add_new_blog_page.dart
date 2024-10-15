import 'dart:io';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/pick_image.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  final Blog? blog;

  static Route route({Blog? blog}) =>
      MaterialPageRoute(builder: (context) => AddNewBlogPage(blog: blog));

  const AddNewBlogPage({super.key, this.blog});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<Topic> selectedTopics = [];
  List<Topic> allBlogTopics = [];
  File? image;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Set existing blog data if editing
    if (widget.blog != null) {
      titleController.text = widget.blog!.title;
      contentController.text = widget.blog!.content;
      image = null; // Initialize image as null for editing
    }

    // Fetch all blog topics when initializing the page
    context.read<BlogBloc>().add(BlogFetchAllBlogTopics());
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
    if (formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        (image != null || widget.blog != null)) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

      if (widget.blog != null) {
        // Editing an existing blog
        context.read<BlogBloc>().add(BlogUpdate(
              posterId: posterId,
              blogId: widget.blog!.id,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              image: image,
              currentImageUrl: widget.blog!.imageUrl,
              topics: selectedTopics,
            ));
        // Debug log
      } else {
        // Uploading a new blog
        context.read<BlogBloc>().add(BlogUpload(
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              image: image!,
              topics: selectedTopics,
            ));
        // Debug log
      }
    } else {
      // Debug log
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
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
            showSnackBar(context, state.error, isError: true);
          } else if (state is BlogUploadSuccess || state is BlogUpdateSuccess) {
            Navigator.pushAndRemoveUntil(
                context, BlogPage.route(), (route) => false);
            showSnackBar(context,
                'Your blog "${titleController.text}" has been added successfully');
          } else if (state is BlogTopicsDisplaySuccess) {
            allBlogTopics = state.topics
                .map((topic) => Topic(id: topic.id, name: topic.name))
                .toList();

            if (widget.blog != null) {
              selectedTopics = allBlogTopics
                  .where((topic) => widget.blog!.topics.contains(topic
                      .name)) // Assuming widget.blog!.topics contains topic names
                  .toList();
            }
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
                key: formKey,
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
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
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
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: allBlogTopics // Use the fetched topics here
                            .map(
                              (topic) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedTopics.contains(topic)) {
                                      selectedTopics.remove(topic);
                                    } else {
                                      selectedTopics.add(topic);
                                    }
                                    setState(() {});
                                  },
                                  child: Chip(
                                    label:
                                        Text(topic.name), // Display topic name
                                    backgroundColor: selectedTopics
                                            .contains(topic)
                                        ? AppPallete
                                            .gradient1 // Highlight if selected
                                        : null,
                                    side: selectedTopics.contains(topic)
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
                    const SizedBox(height: 10),
                    BlogEditor(
                        controller: titleController, hintText: 'Blog Title'),
                    const SizedBox(height: 10),
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
