import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxConfig {
  static String get accessToken => dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '';
}
