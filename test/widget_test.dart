import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/main.dart';

void main() {
  testWidgets('la app abre con el título del proyecto', (tester) async {
    await tester.pumpWidget(const PedidosEntregasApp());

    expect(find.text('Pedidos y Entregas'), findsOneWidget);
  });
}
