import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enums/assets_state.dart';

class AssetsProvider with ChangeNotifier {
  late String applicationDocumentsDirectory;
  AssetsState _assetsState = AssetsState.contacting;
  late DateTime? _localDate;
  late DateTime? _serverDate;
  dynamic _english;
  dynamic _arabic;
  int _received = 0, _total = 0;
  final List<int> _bytes = [];
  int _failureAttemptCount = 0;

  AssetsState get assetsState => _assetsState;

  dynamic get english => _english;

  dynamic get arabic => _arabic;

  int get received => _received;

  int get total => _total == 0 ? 1 : _total;

  int get failureAttemptCount => _failureAttemptCount;

  bool get didGiveUp => _failureAttemptCount > 5;

  AssetsProvider() {
    _instantiateAssets();
  }

  Future<void> _instantiateAssets() async {
    _localDate = await _getLocalModificationDate();
    _serverDate = await _getServerModificationDate();

    applicationDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;

    if (_serverDate != null &&
        (_localDate == null || _serverDate!.isAfter(_localDate!))) {
      _assetsState = AssetsState.updating;
      _downloadFile();
    } else if (_localDate != null) {
      _assetsState = AssetsState.noUpdateRequired;
      mountTranslations();
    } else if (_serverDate == null) {
      _assetsState = AssetsState.failedConnecting;
      _failureAttemptCount++;
      Future.delayed(const Duration(seconds: 5), () {
        if (_failureAttemptCount <= 5) {
          _instantiateAssets();
        }
      });
    }

    notifyListeners();
  }

  String getReceived() {
    if (_received == 0) {
      return '-';
    }

    double value = _received / 1024 / 1024;
    return value.toStringAsFixed(1);
  }

  String getTotal() {
    if (_total == 0) {
      return '-';
    }

    double value = _total / 1024 / 1024;
    return value.toStringAsFixed(1);
  }

  Future<DateTime?> _getLocalModificationDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('assetsModificationDate')) {
      return DateTime.parse(prefs.getString('assetsModificationDate')!);
    }

    return null;
  }

  Future<DateTime?> _getServerModificationDate() async {
    try {
      final completer = Completer<DateTime>();
      final contents = StringBuffer();
      HttpClientRequest request = await HttpClient().getUrl(Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/arabella-dcc09.appspot.com/o/assets.zip'));

      HttpClientResponse response = await request.close();
      response.transform(utf8.decoder).listen(
        (data) {
          contents.write(data);
        },
        onDone: () => completer.complete(
          DateTime.parse(json.decode(contents.toString())['updated']),
        ),
      );
      return completer.future;
    } catch (_) {
      return null;
    }
  }

  Future<void> _downloadFile() async {
    try {
      HttpClientRequest request = await HttpClient().getUrl(Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/arabella-dcc09.appspot.com/o/assets.zip?alt=media'));

      HttpClientResponse response = await request.close();

      _total = response.contentLength;

      response.listen((event) {
        _bytes.addAll(event);
        _received += event.length;
        notifyListeners();
      }).onDone(
        () async {
          final file = File('$applicationDocumentsDirectory/assets.zip');
          await file.writeAsBytes(_bytes);
          _unzipFile();
        },
      );
    } catch (_) {
      _assetsState = AssetsState.failedUpdating;
    }
  }

  Future<void> _unzipFile() async {
    final archive = ZipDecoder().decodeBytes(_bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$applicationDocumentsDirectory/assets/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$applicationDocumentsDirectory/assets/$filename')
            .create(recursive: true);
      }
    }

    _assetsState = AssetsState.finishedUpdating;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('assetsModificationDate', _serverDate.toString());
    notifyListeners();

    mountTranslations();
  }

  Future<void> mountTranslations() async {
    _english = json.decode(
        await File('$applicationDocumentsDirectory/assets/translations/en.json')
            .readAsString());
    _arabic = json.decode(
        await File('$applicationDocumentsDirectory/assets/translations/ar.json')
            .readAsString());
  }

  Future<void> precacheImages(BuildContext context) async {
    String root = '$applicationDocumentsDirectory/assets/images/';

    final images = Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .map((e) => e.path)
        .toList();

    for (var image in images) {
      precacheImage(FileImage(File(image)), context);
    }
  }

  dynamic getLanguageJson(String language) {
    if (language == 'en') {
      return _english;
    } else {
      return _arabic;
    }
  }

  String getTranslation(String text, BuildContext context, String language) {
    dynamic value = getLanguageJson(language);

    for (String level in text.split('.')) {
      value = value[level];
    }
    return value as String;
  }
}
