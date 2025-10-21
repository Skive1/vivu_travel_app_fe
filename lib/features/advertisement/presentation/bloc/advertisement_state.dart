import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/payment_entity.dart';

abstract class AdvertisementState extends Equatable {
  const AdvertisementState();

  @override
  List<Object?> get props => [];
}

class AdvertisementInitial extends AdvertisementState {
  const AdvertisementInitial();
}

class AdvertisementLoading extends AdvertisementState {
  const AdvertisementLoading();
}

class AdvertisementLoaded extends AdvertisementState {
  final List<PackageEntity> packages;
  final List<PostEntity> posts;

  const AdvertisementLoaded({
    required this.packages,
    required this.posts,
  });

  @override
  List<Object?> get props => [packages, posts];
}

class PackagesLoaded extends AdvertisementState {
  final List<PackageEntity> packages;

  const PackagesLoaded({required this.packages});

  @override
  List<Object?> get props => [packages];
}

class PurchasedPackagesLoaded extends AdvertisementState {
  final List<PackageEntity> packages;

  const PurchasedPackagesLoaded({required this.packages});

  @override
  List<Object?> get props => [packages];
}

class PostsLoaded extends AdvertisementState {
  final List<PostEntity> posts;

  const PostsLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostDetailLoaded extends AdvertisementState {
  final PostEntity post;

  const PostDetailLoaded({required this.post});

  @override
  List<Object?> get props => [post];
}

class PostCreated extends AdvertisementState {
  final PostEntity post;

  const PostCreated({required this.post});

  @override
  List<Object?> get props => [post];
}

class PaymentCreated extends AdvertisementState {
  final PaymentEntity payment;

  const PaymentCreated({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentStatusChecked extends AdvertisementState {
  final PaymentStatusEntity status;

  const PaymentStatusChecked({required this.status});

  @override
  List<Object?> get props => [status];
}

class PaymentCancelled extends AdvertisementState {
  final PaymentStatusEntity status;

  const PaymentCancelled({required this.status});

  @override
  List<Object?> get props => [status];
}

class AdvertisementError extends AdvertisementState {
  final String message;

  const AdvertisementError({required this.message});

  @override
  List<Object?> get props => [message];
}
