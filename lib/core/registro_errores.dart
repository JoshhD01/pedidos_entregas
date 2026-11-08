import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Registra en Crashlytics un error inesperado como no fatal.
/// Sin Firebase inicializado (pruebas) no hace nada.
void registrarError(Object error, StackTrace stack) {
  if (Firebase.apps.isEmpty) return;
  FirebaseCrashlytics.instance.recordError(error, stack);
}
