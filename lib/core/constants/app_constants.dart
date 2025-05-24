class AppConstants {
  // Google Sheets Configuration
  static const String spreadsheetId = '1jTg6xgqjNGb3T0O7cUBLGabapivgZ11g70aQ0S-se5Y'; // Replace with your Google Sheet ID
  static const String inventorySheetName = 'inventory_sheet';
  static const String compositionSheetName = 'composition_sheet';
  
  // Hive Box Names
  static const String materialsBox = 'materials';
  static const String compositionsBox = 'compositions';
  static const String manufacturingLogsBox = 'manufacturing_logs';
  
  // Sync Configuration
  static const int syncIntervalMinutes = 30;
  
  // Validation Constants
  static const double minQuantity = 0.0;
  static const double maxQuantity = 999999.99;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  
  // Error Messages
  static const String errorNoInternet = 'No internet connection available';
  static const String errorSyncFailed = 'Failed to sync with Google Sheets';
  static const String errorInvalidQuantity = 'Please enter a valid quantity';
  static const String errorBelowThreshold = 'Material quantity is below threshold';
  
  // Success Messages
  static const String successSync = 'Successfully synced with Google Sheets';
  static const String successSave = 'Successfully saved changes';
  static const String successDelete = 'Successfully deleted item';
} 