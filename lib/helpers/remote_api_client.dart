import 'package:dio/dio.dart';
import '../utils/config.dart';

class RemoteApiClient {
  final Dio _dio;
  final String _base;

  RemoteApiClient()
      : _dio = Dio(
          BaseOptions(
            // Longer timeouts to handle Render cold starts (free tier sleeps after inactivity)
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 45),
            sendTimeout: const Duration(seconds: 30),
            // Don't throw on non-2xx; let us handle status codes
            validateStatus: (_) => true,
          ),
        ),
        _base = AppConfig.baseUrl;

  // AUTH
  Future<bool> login(String username, String password) async {
    try {
      final res = await _dio.post('$_base/auth/login', data: {
        'username': username,
        'password': password,
      });
      return res.statusCode == 200 && 
             res.data is Map && 
             res.data['ok'] == true;
    } catch (e) {
      print('Remote login exception: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final res = await _dio.post('$_base/auth/register', data: {
        'username': username,
        'password': password,
      });
      // 200 = success, 409 = user exists (fail gracefully)
      if (res.statusCode == 200 && res.data is Map && res.data['ok'] == true) {
        return true;
      }
      if (res.statusCode == 409) {
        print('Remote register: user already exists');
      }
      return false;
    } catch (e) {
      print('Remote register exception: $e');
      return false;
    }
  }

  // POINTS
  Future<int> getUserPoints(String username) async {
    final res = await _dio.get('$_base/users/$username/points');
    return (res.data['points'] as num).toInt();
  }

  Future<void> setUserPoints(String username, int points) async {
    await _dio.put('$_base/users/$username/points', data: {
      'points': points,
    });
  }

  // THEME
  Future<String?> getCurrentTheme(String username) async {
    final res = await _dio.get('$_base/users/$username/theme');
    return res.data['theme'] as String?;
  }

  Future<void> setCurrentTheme(String username, String theme) async {
    await _dio.put('$_base/users/$username/theme', data: {
      'theme': theme,
    });
  }

  Future<List<String>> getUserOwnedThemes(String username) async {
    final res = await _dio.get('$_base/users/$username/themes');
    final list = (res.data['themes'] as List<dynamic>).cast<String>();
    return list;
  }

  Future<void> purchaseTheme(String username, String theme) async {
    await _dio.post('$_base/users/$username/themes/purchase', data: {
      'theme': theme,
    });
  }

  // POWERUPS
  Future<Map<String, int>> getUserPowerups(String username) async {
    final res = await _dio.get('$_base/users/$username/powerups');
    final map = <String, int>{};
    final data = res.data['powerups'] as Map<String, dynamic>;
    data.forEach((k, v) => map[k] = (v as num).toInt());
    return map;
  }

  Future<void> purchasePowerup(String username, String powerupId) async {
    await _dio.post('$_base/users/$username/powerups/purchase', data: {
      'powerupId': powerupId,
    });
  }

  Future<void> usePowerup(String username, String powerupId) async {
    await _dio.post('$_base/users/$username/powerups/use', data: {
      'powerupId': powerupId,
    });
  }

  // IMPORTED SETS (by name)
  Future<List<Map<String, dynamic>>> getUserImportedSets(String username) async {
    final res = await _dio.get('$_base/users/$username/imported-sets');
    final list = (res.data['sets'] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<void> addImportedSet(String username, String setName, {int? studySetId}) async {
    await _dio.post('$_base/users/$username/imported-sets', data: {
      'setName': setName,
      if (studySetId != null) 'studySetId': studySetId,
    });
  }

  Future<void> removeImportedSet(String username, String setName) async {
    await _dio.delete('$_base/users/$username/imported-sets/$setName');
  }
}
