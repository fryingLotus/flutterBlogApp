import 'package:blogapp/core/common/pages/follower_page.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/common/widgets/navigation_tile.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_drawer.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:blogapp/core/themes/app_pallete.dart';

class BlogSearchPage extends StatefulWidget {
  const BlogSearchPage({super.key});

  @override
  State<BlogSearchPage> createState() => _BlogSearchPageState();
}

class _BlogSearchPageState extends State<BlogSearchPage> {
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            BlogEditor(
              controller: usernameController,
              hintText: 'Search..',
              suffixIcon: const Icon(Icons.search),
              onSuffixIconPressed: () {
                context.read<AuthBloc>().add(
                    AuthSearchUser(username: usernameController.text.trim()));
              },
            ),
            const SizedBox(height: 20),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  showSnackBar(context, state.message, isError: true);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Loader();
                } else if (state is AuthSearchSuccess) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        print("userId" + user.id);
                        return NavigationTile(
                          title: user.name, // Display user name
                          routeBuilder: (context) {
                            return FollowerPage(
                              otherId: user.id,
                            );
                          },
                          profileImage: CircleAvatar(
                            backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox
                    .shrink(); // Return empty space if no search performed
              },
            ),
          ],
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}
