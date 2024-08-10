import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/core/secrets/app_secrets.dart';
import 'package:blogapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blogapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:blogapp/features/auth/domain/usecases/current_user.dart';
import 'package:blogapp/features/auth/domain/usecases/user_login.dart';
import 'package:blogapp/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blogapp/features/blog/data/repositories/blog_repositories_impl.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:blogapp/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/upload_blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl, anonKey: AppSecrets.supabaseAnonKey);
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory(() => InternetConnection());
  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()));
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    // Usecases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => AuthBloc(
          userSignUp: serviceLocator(),
          userLogin: serviceLocator(),
          currentUser: serviceLocator(),
          appUserCubit: serviceLocator(),
        ));
}

void _initBlog() {
  // Datasource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoriesImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(() =>
        BlogBloc(uploadBlog: serviceLocator(), getAllBlogs: serviceLocator()));
}
