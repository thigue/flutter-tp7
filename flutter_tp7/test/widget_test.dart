import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tp7/main.dart';

void main() {
  testWidgets('Mostra a tela de leituras com a lista vazia', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Minhas leituras'), findsOneWidget);
    expect(find.text('THIAGO GUERRA SOARES'), findsOneWidget);
    expect(find.text('Nenhum livro cadastrado.'), findsOneWidget);
    expect(find.text('Adicionar livro'), findsOneWidget);
  });
}
