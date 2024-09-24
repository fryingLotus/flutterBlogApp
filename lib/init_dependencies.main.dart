part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  _initComment();
  _initFollower();
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnonKey,
      debug: true);

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));
  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => ThemeCubit());
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
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => UpdateUser(serviceLocator()))
    ..registerFactory(() => ResendVerificationEmail(serviceLocator()))
    ..registerFactory(() => CheckEmailVerified(serviceLocator()))
    ..registerFactory(() => SendPasswordReset(serviceLocator()))
    ..registerFactory(() => ResetPassword(serviceLocator()))
    ..registerFactory(() => UpdateProfilePicture(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userLogout: serviceLocator(),
        updateUser: serviceLocator(),
        resendVerificationEmail: serviceLocator(),
        checkEmailVerified: serviceLocator(),
        updateProfilePicture: serviceLocator(),
        resetPassword: serviceLocator(),
        sendPasswordReset: serviceLocator()));
}

void _initBlog() {
  // Datasource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<BlogLocalDataSource>(
        () => BlogLocalDataSourceImpl(serviceLocator()))
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoriesImpl(
        serviceLocator(),
        serviceLocator(),
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
    ..registerFactory(() => GetUserBlogs(serviceLocator()))
    ..registerFactory(() => GetBlogsFromFollowedUser(serviceLocator()))
    ..registerFactory(() => DeleteBlog(serviceLocator()))
    ..registerFactory(() => UpdateBlog(serviceLocator()))
    ..registerFactory(() => LikeBlog(serviceLocator()))
    ..registerFactory(() => UnlikeBlog(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
        getUserBlogs: serviceLocator(),
        getBlogsFromFollowedUser: serviceLocator(),
        deleteBlog: serviceLocator(),
        updateBlog: serviceLocator(),
        likeBlog: serviceLocator(),
        unlikeBlog: serviceLocator()));
}

void _initComment() {
  // Datasource
  serviceLocator
    ..registerFactory<CommentRemoteDataSource>(
      () => CommentRemoteDataSourceImpl(serviceLocator()),
    )
    // Repository
    ..registerFactory<CommentRepository>(
      () => CommentRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    // Usecases
    ..registerFactory(
      () => UploadComment(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetCommentsForBlog(serviceLocator()),
    )
    ..registerFactory(() => DeleteComment(serviceLocator()))
    ..registerFactory(() => UpdateComment(serviceLocator()))
    ..registerFactory(() => LikeComment(serviceLocator()))
    ..registerFactory(() => UnlikeComment(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => CommentBloc(
        uploadComment: serviceLocator(),
        getCommentsForBlog: serviceLocator(),
        deleteComment: serviceLocator(),
        updateComment: serviceLocator(),
        likeComment: serviceLocator(),
        unlikeComment: serviceLocator()));
}

void _initFollower() {
  // Registering the data source
  serviceLocator.registerFactory<FollowerRemoteDataSource>(
    () => FollowerRemoteDataSourceImpl(serviceLocator()),
  );

  // Registering the repository
  serviceLocator.registerFactory<FollowerRepository>(
    () => FollowerRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  // Registering the use cases
  serviceLocator
    ..registerFactory(() => FollowUser(serviceLocator()))
    ..registerFactory(() => UnfollowUser(serviceLocator()))
    ..registerFactory(() => GetFollowers(serviceLocator()))
    ..registerFactory(() => GetFollowingList(serviceLocator()))
    ..registerFactory(() => GetFollowerDetail(serviceLocator()));

  // Registering the cubit
  serviceLocator.registerLazySingleton(() => FollowUserCubit(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ));
}
