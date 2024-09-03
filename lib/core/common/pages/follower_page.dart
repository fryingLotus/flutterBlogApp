import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart'; // Ensure these are public
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowerPage extends StatefulWidget {
  final String otherId;

  const FollowerPage({super.key, required this.otherId});

  static MaterialPageRoute route({required String id}) =>
      MaterialPageRoute(builder: (context) => FollowerPage(otherId: id));

  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    // Initialize _currentUserId here
    _currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _fetchFollowerDetails();
  }

  void _fetchFollowerDetails() {
    final cubit = context.read<FollowUserCubit>();
    cubit.getFollowerDetail(widget.otherId);
  }

  void _followUser() {
    final cubit = context.read<FollowUserCubit>();
    cubit.followUser(widget.otherId, _currentUserId);
  }

  void _unfollowUser() {
    final cubit = context.read<FollowUserCubit>();
    cubit.unfollowUser(widget.otherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follower Details'),
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
          } else if (state is FollowUserSuccess) {
            final follower = state.follower;
            final isFollowing = follower.followedAt != null;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: follower.profileAvatar != null &&
                            follower.profileAvatar!.isNotEmpty
                        ? NetworkImage(follower.profileAvatar!)
                        : null,
                    child: follower.profileAvatar == null ||
                            follower.profileAvatar!.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Follower: ${follower.profileName ?? 'Unknown'}'),
                  Text('Follower Count: ${follower.followerCount}'),
                  Text(
                      'Followed At: ${follower.followedAt != null ? formatDateBydMMMYYYY(follower.followedAt!) : 'Not followed'}'),
                  const SizedBox(height: 20),
                  if (isFollowing)
                    ElevatedButton(
                      onPressed: _unfollowUser,
                      child: const Text('Unfollow'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _followUser,
                      child: const Text('Follow'),
                    ),
                ],
              ),
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
