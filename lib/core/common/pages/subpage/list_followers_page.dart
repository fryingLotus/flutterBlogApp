import 'package:blogapp/core/common/pages/follower_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/core/common/widgets/navigation_tile.dart'; // Import NavigationTile

class ListFollowersPage extends StatefulWidget {
  final String otherId;
  const ListFollowersPage({super.key, required this.otherId});

  @override
  _ListFollowersPageState createState() => _ListFollowersPageState();
}

class _ListFollowersPageState extends State<ListFollowersPage> {
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _fetchFollowers();
  }

  void _fetchFollowers() {
    final cubit = context.read<FollowUserCubit>();
    cubit.getFollowers(widget.otherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: BlocConsumer<FollowUserCubit, FollowUserState>(
        listener: (context, state) {
          if (state is FollowUserError) {
            showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is FollowUserLoading) {
            return const Loader();
          } else if (state is GetFollowersSuccess) {
            final followers = state.followers;

            if (followers.isEmpty) {
              return const Center(child: Text('No followers found.'));
            }

            return ListView.builder(
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final follower = followers[index];
                print(follower.toString());

                return NavigationTile(
                  title: follower.profileName ?? 'Unknown',
                  profileImage: follower.profileAvatar != null &&
                          follower.profileAvatar!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(follower.profileAvatar!),
                        )
                      : null,
                  routeBuilder: (context) {
                    return FollowerPage(otherId: follower.followerId);
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('No data'),
            );
          }
        },
      ),
    );
  }
}

