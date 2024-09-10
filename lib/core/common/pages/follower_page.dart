import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
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
    _currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _fetchFollowerDetails();
  }

  void _fetchFollowerDetails() {
    final cubit = context.read<FollowUserCubit>();
    cubit.getFollowerDetail(widget.otherId);
  }

  void _toggleFollow() async {
    final cubit = context.read<FollowUserCubit>();
    final state = cubit.state;

    if (state is GetFollowerDetailSuccess) {
      final isFollowing = state.follower.isFollowed ?? false;

      if (isFollowing) {
        await _unfollowUser();
      } else {
        await _followUser();
      }

      _fetchFollowerDetails(); // Refetch follower details to update UI
    }
  }

  Future<void> _followUser() async {
    final cubit = context.read<FollowUserCubit>();
    await cubit.followUser(widget.otherId, _currentUserId);
  }

  Future<void> _unfollowUser() async {
    final cubit = context.read<FollowUserCubit>();
    await cubit.unfollowUser(widget.otherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherId == _currentUserId ? 'My Profile' : 'Follower Details',
        ),
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
          } else if (state is GetFollowerDetailSuccess) {
            final follower = state.follower;
            final isFollowing = follower.isFollowed ?? false;
            final isOwnProfile = widget.otherId == _currentUserId;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    follower.profileName ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${follower.followingCount}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5.0),
                              const Text(
                                'User Follows',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${follower.followerCount}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5.0),
                              const Text(
                                'Follower Count',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${follower.blogCount}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5.0),
                              const Text(
                                'Blogs Count',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (!isOwnProfile) ...[
                    if (follower.isFollowingYou == true)
                      const Text('This user is following you'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _toggleFollow,
                      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                    ),
                  ],
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

