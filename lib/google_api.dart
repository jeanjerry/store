import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as sign_in;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleHelper {
  static sign_in.GoogleSignInAccount? _account;
  static GoogleAuthClient? _authenticatedClient;

  static Future<void> signIn() async {
    final googleSignIn = sign_in.GoogleSignIn.standard(
        scopes: [drive.DriveApi.driveScope, gmail.GmailApi.gmailReadonlyScope]);
    _account = await googleSignIn.signIn();
    final authHeaders = await _account?.authHeaders;
    _authenticatedClient = GoogleAuthClient(authHeaders!);
  }

  // 獲得 Google 帳戶
  static Future<String?> getAccount() async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }
    if (kDebugMode) {
      print("getAccount: ${_account?.email}");
    }
    return _account?.email;
  }

  static Future<void> driveDownloadMenu(
      String folderId, String destinationPath) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      var driveApi = drive.DriveApi(_authenticatedClient!);

      // 取得共享資料夾的檔案清單
      var files = await driveApi.files.list(q: "'$folderId' in parents");

      // 確認目標夾子存在
      await Directory(destinationPath).create(recursive: true);

      // 下載每個檔案
      for (final file in files.files!) {
        if (file.mimeType != 'application/vnd.google-apps.document' &&
            file.mimeType != 'application/vnd.google-apps.spreadsheet' &&
            file.mimeType != 'application/vnd.google-apps.presentation') {
          final drive.Media fileData = await driveApi.files.get(file.id!,
              downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
          final Stream<List<int>> stream = fileData.stream;
          final localFile = File('$destinationPath/${file.name}');
          final IOSink sink = localFile.openWrite();

          await for (final chunk in stream) {
            sink.add(chunk);
          }
          await sink.close();
        } else {
          if (kDebugMode) {
            print('跳過 Google 文件：${file.name}');
          }
        }
      }

      if (kDebugMode) {
        print('所有檔案下載完成');
      }
    } finally {
      // 不要在這裡關閉 authenticatedClient
    }
  }

  static Future<void> driveDownloadImage(
      String fileId, String destinationPath, String rename) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      var driveApi = drive.DriveApi(_authenticatedClient!);
      // 確認目標夾子存在
      await Directory(destinationPath).create(recursive: true);

      // 下載檔案
      final drive.Media fileData = await driveApi.files.get(fileId,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final Stream<List<int>> stream = fileData.stream;
      final localFile = File('$destinationPath/$rename');
      final IOSink sink = localFile.openWrite();

      await for (final chunk in stream) {
        sink.add(chunk);
      }
      await sink.close();
    } finally {
      // 不要在這裡關閉 authenticatedClient
    }
  }

  static Future<void> gmailGetMessage(String contract, String id, String type) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      var gmailApi = gmail.GmailApi(_authenticatedClient!);

      // 取得收件夾中的所有信件
      var response = await gmailApi.users.messages.list('me');

      if (response.messages != null) {
        for (var message in response.messages!) {
          // 透過 messageId 取得信件詳細資訊
          var messageDetails =
              await gmailApi.users.messages.get('me', message.id!);

          // if (kDebugMode) {
          //   print("messageDetails: ${messageDetails.payload?.toJson()}");
          // }

          // 提取主題
          var subject = messageDetails.payload?.headers
              ?.firstWhere((header) => header.name == 'Subject',
                  orElse: () => gmail.MessagePartHeader(name: '', value: ''))
              .value;

          if (kDebugMode) {
            print('主題: $subject');
          }

          // 提取內文
          var body = messageDetails.snippet;

          if (kDebugMode) {
            print('內文: $body');
          }

          if (subject == "Blofood" && body!.contains("店家合約:$contract") && body.contains("訂單編號:$id") && body.contains(type)) {
            // 提取附件
            List<String> attachmentIdList = [];
            for (var i = 0; i < messageDetails.payload!.parts!.length; i++) {
              if (messageDetails.payload!.parts?[i].filename != "" &&
                  messageDetails.payload!.parts?[i].filename != null) {
                var attachmentId =
                    messageDetails.payload!.parts?[i].body?.attachmentId;
                attachmentIdList.add(attachmentId!);
              }
            }
            if (kDebugMode) {
              print("attachmentIdList: $attachmentIdList");
            }

            for (var i = 0; i < attachmentIdList.length; i++) {
              // 透過 attachmentId 取得附件
              var attachment = await gmailApi.users.messages.attachments
                  .get('me', message.id!, attachmentIdList[i]);

              // 解碼附件
              var data = base64.decode(attachment.data!);

              // 如果沒有資料夾就建一個
              await Directory(
                      '/data/data/com.hpds.blofood_consumer/confirm_picture')
                  .create(recursive: true);

              // 將附件寫入檔案
              var file = File(
                  '/data/data/com.hpds.blofood_consumer/confirm_picture/$contract-$id-$type-$i');
              file.writeAsBytesSync(data);
            }
          }
        }
      }
    } finally {
      // 不要在這裡關閉 authenticatedClient
    }
  }
}