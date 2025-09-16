import 'package:equatable/equatable.dart';

class OnboardEntity extends Equatable {
  final String title;
  final String description;
  final String imagePath;
  final String backgroundColor;

  const OnboardEntity({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });

  @override
  List<Object> get props => [title, description, imagePath, backgroundColor];
}
