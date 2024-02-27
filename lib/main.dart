import 'package:flutter/material.dart';
import 'package:app/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/qr_scanner_screen.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            // Icono a la izquierda del título
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: ImageIcon(
                AssetImage('assets/icon.png'),
                size: 40,
              ),
            ),
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
                    DataColumn(label: Text('Latitud')),
                    DataColumn(label: Text('Longitud')),
                    DataColumn(label: Text('QR')),
                  ],
                  rows: dataList
                      .map((data) => DataRow(cells: [
                            DataCell(Text(data['datetime'])),
                            DataCell(Text(data['latitude'])),
                            DataCell(Text(data['longitude'])),
                            DataCell(Text(data['qr'])),
                          ]))
                      .toList(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scanQR(context);
        },
        tooltip: 'Scan QR',
        child: const Icon(Icons.camera_alt),
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
}
