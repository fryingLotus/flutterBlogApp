import 'package:blogapp/core/common/cubits/app_follower_cubit/follower_cubit.dart';
import 'package:blogapp/core/common/cubits/app_theme/theme_cubit.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/core/secrets/app_secrets.dart';
import 'package:blogapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blogapp/features/auth/data/datasources/follower_remote_data_source.dart';
import 'package:blogapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blogapp/features/auth/data/repositories/follower_remote_data_source_impl.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:blogapp/features/auth/domain/usecases/change_password.dart';
import 'package:blogapp/features/auth/domain/usecases/check_email_verified.dart';
import 'package:blogapp/features/auth/domain/usecases/current_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/follow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_follower_detail.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_followers.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_following_list.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/unfollow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/resend_verification_email.dart';
import 'package:blogapp/features/auth/domain/usecases/reset_password.dart';
import 'package:blogapp/features/auth/domain/usecases/search_users.dart';
import 'package:blogapp/features/auth/domain/usecases/send_password_reset.dart';
import 'package:blogapp/features/auth/domain/usecases/update_profile_picture.dart';
import 'package:blogapp/features/auth/domain/usecases/update_user.dart';
import 'package:blogapp/features/auth/domain/usecases/user_google_signin.dart';
import 'package:blogapp/features/auth/domain/usecases/user_login.dart';
import 'package:blogapp/features/auth/domain/usecases/user_logout.dart';
import 'package:blogapp/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blogapp/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blogapp/features/blog/data/datasources/comment_remote_data_source.dart';
import 'package:blogapp/features/blog/data/repositories/blog_repositories_impl.dart';
import 'package:blogapp/features/blog/data/repositories/comment_repository_impl.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/delete_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blog_topics.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_blogs_from_followed_user.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_bookmarked_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_user_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/like_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/search_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/unlike_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/update_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/upload_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/delete_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/get_comments_for_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/like_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/unlike_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/update_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/upload_comment.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/bloc/comment_bloc/comment_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'
    if (dart.library.html) 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
part 'init_dependencies.main.dart';
