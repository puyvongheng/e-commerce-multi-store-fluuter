import 'package:dio/dio.dart';
import 'api_client.dart';

class GameService {
  static Future<Map<String, dynamic>> claimReward({
    String? gameName,
    int? score,
    int? coins,
  }) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post(
        '/games/claim-reward',
        data: {
          'gameName': gameName,
          'score': score,
          'coins': coins,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to claim reward: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to claim reward: ${e.response!.data}');
      } else {
        throw Exception('Failed to claim reward: ${e.message}');
      }
    }
  }
}
