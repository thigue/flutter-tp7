import 'package:flutter/material.dart';
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

  testWidgets('Valida o cadastro e permite adicionar e remover um livro', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Adicionar livro'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar livro'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha o título e o autor.'), findsOneWidget);

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), '  Dom Casmurro  ');
    await tester.enterText(campos.at(1), 'Machado de Assis');
    await tester.tap(find.text('Quero ler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lendo').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar livro'));
    await tester.pumpAndSettle();

    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('Machado de Assis\nLendo'), findsOneWidget);
    expect(find.text('Livro adicionado.'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover livro'));
    await tester.pumpAndSettle();

    expect(find.text('Dom Casmurro'), findsNothing);
    expect(find.text('Nenhum livro cadastrado.'), findsOneWidget);
    expect(find.text('Livro removido.'), findsOneWidget);
  });
}
