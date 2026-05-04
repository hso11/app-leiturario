import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../auth/google_auth_service.dart';
import 'storage_service.dart';

@lazySingleton
class GoogleDriveStorage implements StorageService {
  final GoogleAuthService _authService;
  GoogleDriveStorage(this._authService);

  static const _fileName = 'booktracker_db.json';
  static const _uploadUrl =
      'https://www.googleapis.com/upload/drive/v3/files';
  static const _queryUrl =
      'https://www.googleapis.com/drive/v3/files'
      '?spaces=appDataFolder&fields=files(id,name)&q=name%3D%27booktracker_db.json%27';

  @override
  String get providerId => 'google_drive';

  @override
  Future<bool> isAuthenticated() => _authService.isSignedIn();

  Future<String?> _getAccessToken() => _authService.getAccessToken();

  Future<String?> _getFileId() async {
    final token = await _getAccessToken();
    if (token == null) return null;
    final response = await http.get(
      Uri.parse(_queryUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>;
    if (files.isEmpty) return null;
    return (files.first as Map<String, dynamic>)['id'] as String?;
  }

  @override
  Future<void> upload(Map<String, dynamic> payload) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final body = json.encode(payload);
    final existingId = await _getFileId();

    if (existingId != null) {
      // PATCH existing file
      await http.patch(
        Uri.parse('$_uploadUrl/$existingId?uploadType=media'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } else {
      // POST new file in appDataFolder
      final metadata = json.encode({
        'name': _fileName,
        'parents': ['appDataFolder'],
      });
      final boundary = 'foo_bar_baz';
      final multipartBody = '--$boundary\r\n'
          'Content-Type: application/json; charset=UTF-8\r\n\r\n'
          '$metadata\r\n'
          '--$boundary\r\n'
          'Content-Type: application/json\r\n\r\n'
          '$body\r\n'
          '--$boundary--';

      await http.post(
        Uri.parse('$_uploadUrl?uploadType=multipart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: multipartBody,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> download() async {
    final token = await _getAccessToken();
    if (token == null) return null;
    final fileId = await _getFileId();
    if (fileId == null) return null;

    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) return null;
    return json.decode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<void> deleteRemote() async {
    final token = await _getAccessToken();
    if (token == null) return;
    final fileId = await _getFileId();
    if (fileId == null) return;
    await http.delete(
      Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
