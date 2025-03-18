import 'dart:io';
import 'package:flutter/foundation.dart'; // Importa aquí, fuera de la clase
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class CSVService {
  static Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/data.csv';
  }

  static Future<List<List<dynamic>>> readCSV() async {
    try {
      final path = await getFilePath();
      final file = File(path);

      if (await file.exists()) {
        final input = await file.readAsString();
        return const CsvToListConverter().convert(input);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCSV(List<List<dynamic>> data) async {
    try {
      final path = await getFilePath();
      final file = File(path);
      final output = const ListToCsvConverter().convert(data);
      await file.writeAsString(output);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving CSV: $e'); // Solo imprime en modo debug
      }
    }
  }
}
