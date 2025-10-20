import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_packages.dart';
import '../../domain/usecases/get_all_posts.dart';
import '../../domain/usecases/get_post_by_id.dart';
import '../../domain/usecases/create_post.dart' as create_post_usecase;
import '../../domain/usecases/create_payment.dart' as create_payment_usecase;
import '../../domain/usecases/get_payment_status.dart';
import 'advertisement_event.dart';
import 'advertisement_state.dart';

class AdvertisementBloc extends Bloc<AdvertisementEvent, AdvertisementState> {
  final GetAllPackages getAllPackages;
  final GetAllPosts getAllPosts;
  final GetPostById getPostById;
  final create_post_usecase.CreatePost createPost;
  final create_payment_usecase.CreatePayment createPayment;
  final GetPaymentStatus getPaymentStatus;
  final GetPurchasedPackagesByPartner getPurchasedPackagesByPartner;

  AdvertisementBloc({
    required this.getAllPackages,
    required this.getAllPosts,
    required this.getPostById,
    required this.createPost,
    required this.createPayment,
    required this.getPaymentStatus,
    required this.getPurchasedPackagesByPartner,
  }) : super(const AdvertisementInitial()) {
    on<LoadAllPackages>(_onLoadAllPackages);
    on<LoadAllPosts>(_onLoadAllPosts);
    on<LoadPostById>(_onLoadPostById);
    on<CreatePost>(_onCreatePost);
    on<CreatePayment>(_onCreatePayment);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
    on<RefreshPosts>(_onRefreshPosts);
    on<RefreshPackages>(_onRefreshPackages);
    on<LoadPurchasedPackages>(_onLoadPurchasedPackages);
    on<RefreshPurchasedPackages>(_onRefreshPurchasedPackages);
  }

  Future<void> _onLoadAllPackages(
    LoadAllPackages event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());
    
    final result = await getAllPackages(NoParams());
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (packages) => emit(PackagesLoaded(packages: packages)),
    );
  }

  Future<void> _onLoadAllPosts(
    LoadAllPosts event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());
    
    final result = await getAllPosts(NoParams());
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (posts) => emit(PostsLoaded(posts: posts)),
    );
  }

  Future<void> _onLoadPostById(
    LoadPostById event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());
    
    final result = await getPostById(event.postId);
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (post) => emit(PostDetailLoaded(post: post)),
    );
  }

  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());
    
    final result = await createPost(create_post_usecase.CreatePostParams(
      title: event.title,
      description: event.description,
      packagePurchaseId: event.packagePurchaseId,
      mediaFiles: event.mediaFiles,
      mediaTypes: event.mediaTypes,
    ));
    
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (post) => emit(PostCreated(post: post)),
    );
  }

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());
    
    final result = await createPayment(create_payment_usecase.CreatePaymentParams(
      packageId: event.packageId,
      amount: event.amount,
    ));
    
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (payment) => emit(PaymentCreated(payment: payment)),
    );
  }

  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<AdvertisementState> emit,
  ) async {
    final result = await getPaymentStatus(event.transactionId);
    
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (status) => emit(PaymentStatusChecked(status: status)),
    );
  }

  Future<void> _onRefreshPosts(
    RefreshPosts event,
    Emitter<AdvertisementState> emit,
  ) async {
    add(const LoadAllPosts());
  }

  Future<void> _onRefreshPackages(
    RefreshPackages event,
    Emitter<AdvertisementState> emit,
  ) async {
    add(const LoadAllPackages());
  }

  Future<void> _onLoadPurchasedPackages(
    LoadPurchasedPackages event,
    Emitter<AdvertisementState> emit,
  ) async {
    emit(const AdvertisementLoading());

    final result = await getPurchasedPackagesByPartner(event.partnerId);
    result.fold(
      (failure) => emit(AdvertisementError(message: failure.message)),
      (packages) => emit(PurchasedPackagesLoaded(packages: packages)),
    );
  }

  Future<void> _onRefreshPurchasedPackages(
    RefreshPurchasedPackages event,
    Emitter<AdvertisementState> emit,
  ) async {
    add(LoadPurchasedPackages(event.partnerId));
  }
}
