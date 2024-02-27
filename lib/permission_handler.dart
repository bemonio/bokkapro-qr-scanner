import 'package:permission_handler/permission_handler.dart';

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

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    // Permisos de cámara concedidos, puedes usar el escáner de códigos QR
  } else if (status.isDenied) {
    // El usuario negó los permisos de cámara, puedes mostrar un mensaje para solicitarlos nuevamente
  } else if (status.isPermanentlyDenied) {
    // El usuario negó permanentemente los permisos de cámara, puedes redirigirlo a la configuración de la aplicación para habilitarlos manualmente
  }
}
