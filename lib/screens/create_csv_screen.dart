import 'package:flutter/material.dart';
import '../services/csv_editor.dart';

class CreateCSVScreen extends StatefulWidget {
  const CreateCSVScreen({super.key});

  @override
  CreateCSVScreenState createState() => CreateCSVScreenState();
}

class CreateCSVScreenState extends CSVEditor<CreateCSVScreen> {
  @override
  void initState() {
    super.initState();
    csvData = [
      ["Columna 1", "Columna 2", "Columna 3"],
      ["", "", ""],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nuevo CSV"),
          backgroundColor: Colors.red,
        ),
        body: _buildTable(),
        floatingActionButton: _buildFloatingButtons(),
      ),
    );
  }

  /// Construye la tabla editable.
  Widget _buildTable() {
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
                      // Actualiza el valor en csvData conforme se escribe.
                      setState(() {
                        csvData[rowIndex + 1][colIndex] = newValue;
                        isEdited = true;
                      });
                    },
                    onFieldSubmitted: (newValue) {
                      // Además, cuando se "submit" se guarda un undo state.
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

