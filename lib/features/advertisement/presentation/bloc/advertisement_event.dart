import 'package:equatable/equatable.dart';

abstract class AdvertisementEvent extends Equatable {
  const AdvertisementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllPackages extends AdvertisementEvent {
  const LoadAllPackages();
}

class LoadAllPosts extends AdvertisementEvent {
  const LoadAllPosts();
}

class LoadPostById extends AdvertisementEvent {
  final String postId;

  const LoadPostById(this.postId);

  @override
  List<Object?> get props => [postId];
}

class CreatePost extends AdvertisementEvent {
  final String title;
  final String description;
  final String packagePurchaseId;
  final List<String> mediaFiles;
  final List<int> mediaTypes;

  const CreatePost({
    required this.title,
    required this.description,
    required this.packagePurchaseId,
    required this.mediaFiles,
    required this.mediaTypes,
  });

  @override
  List<Object?> get props => [title, description, packagePurchaseId, mediaFiles, mediaTypes];
}

class CreatePayment extends AdvertisementEvent {
  final String packageId;
  final int amount;

  const CreatePayment({
    required this.packageId,
    required this.amount,
  });

  @override
  List<Object?> get props => [packageId, amount];
}

class CheckPaymentStatus extends AdvertisementEvent {
  final String transactionId;

  const CheckPaymentStatus(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class RefreshPosts extends AdvertisementEvent {
  const RefreshPosts();
}

class RefreshPackages extends AdvertisementEvent {
  const RefreshPackages();
}
