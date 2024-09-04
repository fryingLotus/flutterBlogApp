import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

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
  Box<bool>? _followBox; // Make it nullable
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _openFollowBox();
  }

  Future<void> _openFollowBox() async {
    setState(() {
      _isInitialized = false;
    });
    try {
      _followBox = await Hive.box<bool>(name: 'followBox');
      _fetchFollowerDetails();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print("Error opening follow box: $e");
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _fetchFollowerDetails() {
    final cubit = context.read<FollowUserCubit>();
    cubit.getFollowerDetail(widget.otherId);
  }

  void _toggleFollow() async {
    if (_followBox == null || !_isInitialized) return;

    final isFollowing =
        _followBox!.get(widget.otherId, defaultValue: false) ?? false;

    if (isFollowing) {
      await _unfollowUser();
    } else {
      await _followUser();
    }

    // Update the follow status in Hive
    _followBox!.put(widget.otherId, !isFollowing);
    setState(() {});
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
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final isFollowing =
        _followBox?.get(widget.otherId, defaultValue: false) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Follower Details'),
      ),
      body: BlocConsumer<FollowUserCubit, FollowUserState>(
        listener: (context, state) {
          if (state is FollowUserError) {
            showSnackBar(context, state.message, isError: true);
          } else if (state is UnfollowUserSuccess) {
            _fetchFollowerDetails();
          } else if (state is FollowUserSuccess) {
            _fetchFollowerDetails();
          }
        },
        builder: (context, state) {
          if (state is FollowUserLoading) {
            return const Loader();
          } else if (state is GetFollowerDetailSuccess) {
            final follower = state.follower;

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
                  ElevatedButton(
                    onPressed: _toggleFollow,
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
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
