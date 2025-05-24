import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/core/error/failures.dart';

class GoogleSheetsService {
  final sheets.SheetsApi _sheetsApi;
  final String _spreadsheetId;

  GoogleSheetsService(this._sheetsApi, this._spreadsheetId);

  static Future<GoogleSheetsService> create() async {
    try {
      // Load the credentials file from assets
      final String credentialsJson = await rootBundle.loadString('assets/service_account_credentials.json');
      
      final credentials = ServiceAccountCredentials.fromJson(
        Map<String, dynamic>.from(
          const JsonDecoder().convert(credentialsJson),
        ),
      );

      final client = await clientViaServiceAccount(
        credentials,
        [sheets.SheetsApi.spreadsheetsScope],
      );

      final sheetsApi = sheets.SheetsApi(client);
      return GoogleSheetsService(sheetsApi, AppConstants.spreadsheetId);
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to initialize Google Sheets service',
        code: e.toString(),
      );
    }
  }

  Future<List<List<String>>> getSheetData(String range) async {
    try {
      final response = await _sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        range,
      );

      return response.values?.map((row) {
        return row.map((cell) => cell.toString()).toList();
      }).toList() ?? [];
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to fetch data from Google Sheets',
        code: e.toString(),
      );
    }
  }

  Future<void> updateSheetData(
    String range,
    List<List<dynamic>> values,
  ) async {
    try {
      await _sheetsApi.spreadsheets.values.update(
        sheets.ValueRange(values: values),
        _spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to update data in Google Sheets',
        code: e.toString(),
      );
    }
  }

  Future<void> appendSheetData(
    String range,
    List<List<dynamic>> values,
  ) async {
    try {
      await _sheetsApi.spreadsheets.values.append(
        sheets.ValueRange(values: values),
        _spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to append data to Google Sheets',
        code: e.toString(),
      );
    }
  }

  Future<void> clearSheetData(String range) async {
    try {
      await _sheetsApi.spreadsheets.values.clear(
        sheets.ClearValuesRequest(),
        _spreadsheetId,
        range,
      );
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to clear data in Google Sheets',
        code: e.toString(),
      );
    }
  }
} 