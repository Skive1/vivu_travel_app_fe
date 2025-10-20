import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/utils/compute_utils.dart';
import '../models/package_model.dart';
import '../models/post_model.dart';
import '../models/payment_model.dart';

abstract class AdvertisementRemoteDataSource {
  Future<List<PackageModel>> getAllPackages();
  Future<List<PackageModel>> getPurchasedPackagesByPartner(String partnerId);
  Future<List<PostModel>> getAllPosts();
  Future<PostModel> getPostById(String postId);
  Future<PostModel> createPost({
    required String title,
    required String description,
    required String packagePurchaseId,
    required List<String> mediaFiles,
    required List<int> mediaTypes,
  });
  Future<PaymentModel> createPayment({
    required String packageId,
    required int amount,
  });
  Future<PaymentStatusModel> getPaymentStatus(String transactionId);
}

class AdvertisementRemoteDataSourceImpl implements AdvertisementRemoteDataSource {
  final ApiClient apiClient;

  AdvertisementRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PackageModel>> getAllPackages() async {
    final response = await apiClient.get(Endpoints.getAllPackages);
    return await computeMapList(
      response.data as List,
      (json) => PackageModel.fromJson(json),
    );
  }

  @override
  Future<List<PackageModel>> getPurchasedPackagesByPartner(String partnerId) async {
    final response = await apiClient.get(Endpoints.getPurchasedPackagesByPartner(partnerId));
    return await computeMapList(
      response.data as List,
      (json) => PackageModel.fromJson(json),
    );
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    final response = await apiClient.get(Endpoints.getAllPosts);
    return await computeMapList(
      response.data as List,
      (json) => PostModel.fromJson(json),
    );
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await apiClient.get(Endpoints.getPostById(postId));
    return await computeParseObject(
      response.data as Map<String, dynamic>,
      (json) => PostModel.fromJson(json),
    );
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String description,
    required String packagePurchaseId,
    required List<String> mediaFiles,
    required List<int> mediaTypes,
  }) async {
    final formData = {
      'Title': title,
      'Description': description,
      'PackagePurchaseId': packagePurchaseId,
      'MediaFiles': mediaFiles,
      'MediaTypes': mediaTypes,
    };

    final response = await apiClient.post(
      Endpoints.createPost,
      data: formData,
    );
    return await computeParseObject(
      response.data as Map<String, dynamic>,
      (json) => PostModel.fromJson(json),
    );
  }

  @override
  Future<PaymentModel> createPayment({
    required String packageId,
    required int amount,
  }) async {
    final response = await apiClient.post(
      Endpoints.createPayment,
      data: {
        'packageId': packageId,
        'amount': amount,
      },
    );
    return await computeParseObject(
      response.data as Map<String, dynamic>,
      (json) => PaymentModel.fromJson(json),
    );
  }

  @override
  Future<PaymentStatusModel> getPaymentStatus(String transactionId) async {
    final response = await apiClient.get(
      '${Endpoints.getPaymentStatus}?transactionId=$transactionId',
    );
    return await computeParseObject(
      response.data as Map<String, dynamic>,
      (json) => PaymentStatusModel.fromJson(json),
    );
  }
}
