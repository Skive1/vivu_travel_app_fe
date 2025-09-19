import '../../../features/onboarding/domain/entities/onboard_entity.dart';

class OnboardingConstants {
  static const List<OnboardEntity> onboardingPages = [
    OnboardEntity(
      title: 'Khám Phá Thế Giới',
      description: 'Tìm kiếm và khám phá những địa điểm du lịch tuyệt vời trên khắp thế giới với hướng dẫn chi tiết.',
      imagePath: 'assets/images/onboard_1.png',
      backgroundColor: '#FF6B6B',
    ),
    OnboardEntity(
      title: 'Lên Kế Hoạch Dễ Dàng',
      description: 'Tạo lịch trình du lịch hoàn hảo với công cụ lập kế hoạch thông minh và gợi ý cá nhân hóa.',
      imagePath: 'assets/images/onboard_2.png',
      backgroundColor: '#4ECDC4',
    ),
    OnboardEntity(
      title: 'Chia Sẻ Trải Nghiệm',
      description: 'Lưu lại những khoảnh khắc đẹp và chia sẻ trải nghiệm du lịch với bạn bè và gia đình.',
      imagePath: 'assets/images/onboard_3.png',
      backgroundColor: '#45B7D1',
    ),
  ];
}
