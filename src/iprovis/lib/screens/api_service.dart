import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String apiUrl = "http://127.0.0.1:5000/upload"; // Replace with your backend URL

  // Upload image to backend and return response
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      return {'error': 'Image upload failed'};
    }
  }
}
