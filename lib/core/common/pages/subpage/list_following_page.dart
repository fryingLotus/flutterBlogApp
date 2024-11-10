import 'package:blogapp/core/common/pages/follower_page.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/core/common/widgets/navigation_tile.dart'; // Import NavigationTile
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';

class ListFollowingPage extends StatefulWidget {
  final String otherId;
  const ListFollowingPage({super.key, required this.otherId});

  @override
  State<ListFollowingPage> createState() => _ListFollowingPageState();
}

class _ListFollowingPageState extends State<ListFollowingPage> {
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _fetchFollowing();
  }

  void _fetchFollowing() {
    final cubit = context.read<FollowUserCubit>();
    cubit.getFollowingList(widget.otherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following list'),
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
          } else if (state is GetFollowingListSuccess) {
            final followingList = state.followers;

            if (followingList.isEmpty) {
              return const Center(child: Text('Not following anyone.'));
            }

            return ListView.builder(
              itemCount: followingList.length,
              itemBuilder: (context, index) {
                final following = followingList[index];
                print(following.toString());

                return NavigationTile(
                  title: following.profileName ?? 'Unknown',
                  profileImage: following.profileAvatar != null &&
                          following.profileAvatar!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(following.profileAvatar!),
                        )
                      : null,
                  routeBuilder: (context) {
                    return FollowerPage(otherId: following.followedId);
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
