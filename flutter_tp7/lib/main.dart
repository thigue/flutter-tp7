// THIAGO GUERRA SOARES

import 'package:flutter/material.dart';

const nomeIntegrante = 'THIAGO GUERRA SOARES';

void main() {
  runApp(const MyApp());
}

enum StatusLeitura {
  queroLer('Quero ler'),
  lendo('Lendo'),
  concluido('Concluído');

  const StatusLeitura(this.rotulo);

  final String rotulo;
}

class Livro {
  const Livro({
    required this.titulo,
    required this.autor,
    required this.status,
  });

  final String titulo;
  final String autor;
  final StatusLeitura status;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas leituras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF779DD5),
          brightness: Brightness.dark,
          surface: const Color(0xFF101722),
          surfaceContainerLow: const Color(0xFF192332),
        ),
      ),
      home: const TelaLeituras(),
    );
  }
}

class TelaLeituras extends StatefulWidget {
  const TelaLeituras({super.key});

  @override
  State<TelaLeituras> createState() => _TelaLeiturasState();
}

class _TelaLeiturasState extends State<TelaLeituras> {
  final List<Livro> _livros = [];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tema.colorScheme.primaryContainer,
        foregroundColor: tema.colorScheme.onPrimaryContainer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minhas leituras'),
            Text(
              nomeIntegrante,
              style: tema.textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _livros.isEmpty
          ? const Center(child: Text('Nenhum livro cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _livros.length,
              itemBuilder: (context, index) {
                final livro = _livros[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(livro.titulo),
                    subtitle: Text('${livro.autor}\n${livro.status.rotulo}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar livro'),
      ),
    );
  }
}
