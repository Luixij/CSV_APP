import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import '../services/csv_editor.dart';
import 'dart:typed_data';

class OpenCSVScreen extends StatefulWidget {
  final String filePath;
  const OpenCSVScreen({super.key, required this.filePath});

  @override
  State<OpenCSVScreen> createState() => _OpenCSVScreenState();
}

class _OpenCSVScreenState extends CSVEditor<OpenCSVScreen> {
  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final input = await file.readAsString();
        if (mounted) {
          setState(() {
            csvData = CsvToListConverter().convert(input);
            normalizeColumns();
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Abrir CSV"),
          backgroundColor: Colors.blue,
        ),
        body: _buildTable(),
        floatingActionButton: _buildFloatingButtons(), // Sin argumentos
      ),
    );
  }

  Widget _buildTable() {
    // 1. Verificamos si csvData está vacío o no tiene filas
    if (csvData.isEmpty || csvData.first.isEmpty) {
      // Mostramos un indicador de carga o un texto temporal
      return const Center(
        child: Text("Cargando datos..."),
        // O un CircularProgressIndicator()
      );
    }

    // 2. Si ya tenemos datos, construimos la tabla
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: List.generate(csvData.first.length, (colIndex) {
            return DataColumn(
              label: Text(csvData.first[colIndex].toString()),
            );
          }),
          rows: List.generate(csvData.length - 1, (rowIndex) {
            return DataRow(
              cells: List.generate(csvData.first.length, (colIndex) {
                return DataCell(
                  TextFormField(
                    initialValue: csvData[rowIndex + 1][colIndex].toString(),
                    onChanged: (newValue) {
                      setState(() {
                        csvData[rowIndex + 1][colIndex] = newValue;
                        isEdited = true;
                      });
                    },
                    onFieldSubmitted: (newValue) {
                      pushUndoState();
                      setState(() {
                        csvData[rowIndex + 1][colIndex] = newValue;
                        isEdited = true;
                      });
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  /// Construye los botones flotantes.
  Widget _buildFloatingButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05), // 5% de la altura de la pantalla
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: undo, child: const Icon(Icons.undo)),
          const SizedBox(height: 12),
          FloatingActionButton(onPressed: redo, child: const Icon(Icons.redo)),
          const SizedBox(height: 12),
          FloatingActionButton(onPressed: addRow, child: const Icon(Icons.add)),
          const SizedBox(height: 12),
          FloatingActionButton(onPressed: addColumn, child: const Icon(Icons.view_column)),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: isSaving ? null : () => saveCSV("nuevo.csv"),
            child: const Icon(Icons.save),
            backgroundColor: isSaving ? Colors.grey : Colors.red,
          ),
        ],
      ),
    );
  }
}