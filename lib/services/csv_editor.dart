import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Clase base que centraliza la lógica común para editar CSV.
abstract class CSVEditor<T extends StatefulWidget> extends State<T> {
  // Datos del CSV: cada fila es una lista.
  List<List<dynamic>> csvData = [];

  // Stacks para undo y redo.
  final List<List<List<dynamic>>> undoStack = [];
  final List<List<List<dynamic>>> redoStack = [];

  // Variables de estado.
  bool isEdited = false;
  bool isSaving = false;

  /// Guarda una copia profunda del estado actual para permitir undo.
  void pushUndoState() {
    undoStack.add(csvData.map((row) => List<dynamic>.from(row)).toList());
    redoStack.clear();
    isEdited = true;
  }

  /// Agrega una nueva fila.
  void addRow() {
    pushUndoState();
    setState(() {
      csvData.add(List.filled(csvData.first.length, ""));
    });
  }

  /// Agrega una nueva columna.
  void addColumn() {
    pushUndoState();
    setState(() {
      final newColumnNumber = csvData.first.length + 1;
      csvData[0] = List.of(csvData[0])..add("Columna $newColumnNumber");
      for (int i = 1; i < csvData.length; i++) {
        csvData[i] = List.of(csvData[i])..add("");
      }
    });
  }

  /// Normaliza el número de columnas en todas las filas.
  void normalizeColumns() {
    final maxCols = csvData.map((row) => row.length).reduce(math.max);
    for (var row in csvData) {
      while (row.length < maxCols) {
        row.add("");
      }
    }
  }

  /// Undo: revierte el último cambio.
  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(csvData));
      setState(() {
        csvData = undoStack.removeLast();
      });
    }
  }

  /// Redo: reaplica el último cambio deshecho.
  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(csvData));
      setState(() {
        csvData = redoStack.removeLast();
      });
    }
  }

  /// Guarda el CSV usando el plugin FlutterFileDialog.
  Future<void> saveCSV(String filePath) async {
    if (isSaving) return; // Evita llamadas simultáneas.
    isSaving = true;
    setState(() {});
    try {
      // **Forzamos a desenfocar todos los campos para que se guarden todos los cambios**
      FocusScope.of(context).unfocus();

      // Espera 100 ms para asegurarse de que no haya diálogos activos.
      await Future.delayed(const Duration(milliseconds: 100));
      final output = const ListToCsvConverter().convert(csvData);
      final bytes = Uint8List.fromList(output.codeUnits);
      final params = SaveFileDialogParams(data: bytes, fileName: filePath);
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Archivo guardado en: $savedPath")),
        );
        isEdited = false;
      }
    } catch (e) {
      debugPrint("Error guardando CSV: $e");
    } finally {
      isSaving = false;
      setState(() {});
    }
  }

  /// Se llama al intentar salir de la pantalla.
  Future<bool> onPop() async {
    if (!isEdited) return true;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Guardar cambios"),
          content: const Text("El archivo ha sido editado. ¿Desea guardar los cambios?"),
          actions: [
            TextButton(
              onPressed: () {
                isEdited = false;
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text("Descartar"),
            ),
            TextButton(
              onPressed: () async {
                await saveCSV("archivo.csv");
                isEdited = false;
                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text("Guardar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context);
}
