import 'dart:async';
import 'package:http/http.dart' as http;

import 'eb_graber.dart';
import '../exception/app_exception.dart';

class HttpEbGraber extends AbstractEbGraber {
  final String _url;

  HttpEbGraber(this._url) {
    if (_url.isEmpty) {
      throw AppException('URL不能为空');
    }
  }

  @override
  Future<EbData?> grab() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) return null;
    return await extractData(response);
  }

  Future<EbData?> extractData(http.Response response) async {
    throw UnimplementedError();
  }
}