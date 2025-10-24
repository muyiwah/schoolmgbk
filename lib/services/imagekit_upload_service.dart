import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:schmgtsystem/models/imagekit_model.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class ImageKitUploadService {
  final ClassRepo _classRepo = locator<ClassRepo>();

  /// Upload file to ImageKit using authenticated requests
  ///
  /// [fileBytes] - The file bytes to upload
  /// [fileName] - The name for the file in ImageKit
  /// [folder] - The folder path in ImageKit (optional)
  ///
  /// Returns the uploaded file URL on success, null on failure
  Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String folder = '/uploads',
  }) async {
    try {
      // Get authentication parameters from backend
      final authResponse = await _classRepo.getImageKitAuth();

      if (!HTTPResponseModel.isApiCallSuccess(authResponse)) {
        throw Exception('Failed to get ImageKit auth: ${authResponse.message}');
      }

      final authData = ImageKitAuthModel.fromJson(authResponse.data!);

      if (!authData.success || authData.data == null) {
        throw Exception('Invalid auth response: ${authData.message}');
      }

      // ImageKit API endpoint
      final uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';

      // Create form data
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

      // Add authenticated ImageKit parameters
      request.fields['fileName'] = fileName;
      request.fields['folder'] = folder;
      request.fields['publicKey'] = AppConstants.imagekitpublic;
      request.fields['token'] = authData.data!.token;
      request.fields['expire'] = authData.data!.expire.toString();
      request.fields['signature'] = authData.data!.signature;

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
        return jsonResponse['url'] as String?;
      } else {
        throw Exception(
          'ImageKit upload failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('ImageKit upload error: $e');
    }
  }

  /// Check if ImageKit authentication is working
  Future<bool> isAuthenticationWorking() async {
    try {
      final authResponse = await _classRepo.getImageKitAuth();

      if (!HTTPResponseModel.isApiCallSuccess(authResponse)) {
        return false;
      }

      final authData = ImageKitAuthModel.fromJson(authResponse.data!);
      return authData.success && authData.data != null;
    } catch (e) {
      return false;
    }
  }
}
