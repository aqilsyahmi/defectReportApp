import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  
  Future<void> submitDefectReport(List<Map<String, String>> defects, String spreadsheetId) async {
    try {
      String serviceAccountJson;
      if (kIsWeb) {
        serviceAccountJson = const String.fromEnvironment('SERVICE_ACCOUNT_JSON');
        if (serviceAccountJson.isEmpty) {
          throw Exception('SERVICE_ACCOUNT_JSON environment variable is not set');
        }
      } else {
        final serviceAccountFile = const String.fromEnvironment('SERVICE_ACCOUNT_FILE');
        if (serviceAccountFile.isEmpty) {
          throw Exception('SERVICE_ACCOUNT_FILE environment variable is not set');
        }
        final file = File(serviceAccountFile);
        if (!await file.exists()) {
          throw Exception('Service account file not found');
        }
        serviceAccountJson = await file.readAsString();
      }

      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson)
      );

      print('Authenticating with Google...');
      final client = await clientViaServiceAccount(credentials, _scopes);
      print('Authentication successful.');

      final sheetsApi = SheetsApi(client);
      print('Sheets API initialized.');

      final valueRange = ValueRange(
        values: defects.map((defect) => [
          defect['id'],
          defect['location'],
          defect['description'],
        ]).toList(),
      );

      print('Appending data to spreadsheet...');
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        'Sheet1!A1',
        valueInputOption: 'USER_ENTERED',
      );
      print('Data appended successfully.');

      client.close();
    } catch (e, stackTrace) {
      print('Error in submitDefectReport: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}