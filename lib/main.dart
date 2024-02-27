import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/qr_scanner_screen.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.initDb();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Brinks Caribe App - QR Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permisos concedidos, puedes acceder a la ubicación
      // print('Permisos de ubicación concedidos');
    } else if (status.isDenied) {
      // El usuario negó los permisos, puedes mostrar un mensaje para solicitarlos nuevamente
      // print('Permisos de ubicación denegados');
    } else if (status.isPermanentlyDenied) {
      // El usuario negó permanentemente los permisos, puedes redirigirlo a la configuración de la aplicación para habilitarlos manualmente
      // print('Permisos de ubicación denegados permanentemente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Row(
          children: [
            // const Padding(
            //   padding: EdgeInsets.only(right: 8.0),
            //   child: ImageIcon(
            //     AssetImage('assets/icon.png'),
            //     size: 40,
            //   ),
            // ),
            Text(widget.title),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _databaseHelper.getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final dataList = snapshot.data!;
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Fecha y hora')),
                    DataColumn(label: Text('QR')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Latitud')),
                    DataColumn(label: Text('Longitud')),
                    DataColumn(label: Text('Dispositivo')),
                  ],
                  rows: dataList
                      .map((data) => DataRow(cells: [
                            DataCell(Text(data['datetime'])),
                            DataCell(Text(data['qr_data'])),
                            DataCell(Text(data['qr_type'])),
                            DataCell(Text(data['latitude'])),
                            DataCell(Text(data['longitude'])),
                            DataCell(Text(data['device'])),
                          ]))
                      .toList(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _databaseHelper.resetDatabase();
              setState(() {});
            },
            tooltip: 'Reset Database',
            child: const Icon(Icons.delete),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () async {
              await _sendDatabaseByEmail()
                  .then((text) => showSnackBar(context, text));
            },
            tooltip: 'Send Database',
            child: const Icon(Icons.email),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              _scanQR(context);
            },
            tooltip: 'Scan QR',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  void _scanQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }

  Future<String> _sendDatabaseByEmail() async {
    try {
      // Obtener los datos de la tabla qr_data
      List<Map<String, dynamic>> qrDataList = await _databaseHelper.getData();

      // Convertir los datos a formato CSV
      List<List<dynamic>> csvData = [];
      for (var row in qrDataList) {
        csvData.add([
          row['datetime'],
          row['latitude'],
          row['longitude'],
          row['qr_data'],
          row['qr_type'],
        ]);
      }
      String csv = const ListToCsvConverter().convert(csvData);

      // Guardar el archivo CSV en el sistema de archivos temporal
      Directory tempDir = await getTemporaryDirectory();
      String csvFilePath = '${tempDir.path}/qr_data.csv';
      File csvFile = File(csvFilePath);
      await csvFile.writeAsString(csv);

      // Obtener la fecha y hora actual formateada
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Configurar el correo electrónico
      final subject = 'Datos de QR en formato CSV - $formattedDate';
      final body =
          'Adjunto el archivo CSV con los datos de la tabla qr_data.\nFecha y hora: $formattedDate';
      final email = Email(
        body: body,
        subject: subject,
        recipients: ['bemonio@gmail.com'],
        attachmentPaths: [csvFilePath],
        isHTML: false,
      );

      // Enviar el correo electrónico
      await FlutterEmailSender.send(email);

      // Eliminar el archivo CSV después de enviar el correo electrónico
      await csvFile.delete();

      return 'Correo electrónico enviado correctamente';
    } catch (error) {
      return 'Error al enviar el correo electrónico: $error';
    }
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
