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

  Future<void> _adicionarLivro() async {
    final livro = await Navigator.of(context).push<Livro>(
      MaterialPageRoute(builder: (context) => const TelaCadastroLivro()),
    );

    if (!mounted || livro == null) return;

    setState(() {
      _livros.add(livro);
    });
    _mostrarMensagem('Livro adicionado.');
  }

  void _removerLivro(Livro livro) {
    setState(() {
      _livros.remove(livro);
    });
    _mostrarMensagem('Livro removido.');
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

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
                    trailing: IconButton(
                      onPressed: () => _removerLivro(livro),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remover livro',
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarLivro,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar livro'),
      ),
    );
  }
}

class TelaCadastroLivro extends StatefulWidget {
  const TelaCadastroLivro({super.key});

  @override
  State<TelaCadastroLivro> createState() => _TelaCadastroLivroState();
}

class _TelaCadastroLivroState extends State<TelaCadastroLivro> {
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  StatusLeitura _status = StatusLeitura.queroLer;

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  void _cadastrarLivro() {
    final titulo = _tituloController.text.trim();
    final autor = _autorController.text.trim();

    if (titulo.isEmpty || autor.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Preencha o título e o autor.')),
        );
      return;
    }

    Navigator.of(context)
        .pop(Livro(titulo: titulo, autor: autor, status: _status));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tema.colorScheme.primaryContainer,
        foregroundColor: tema.colorScheme.onPrimaryContainer,
        title: const Text('Adicionar livro'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _tituloController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _autorController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Autor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Status da leitura',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StatusLeitura>(
                  value: _status,
                  isExpanded: true,
                  isDense: true,
                  items: [
                    for (final status in StatusLeitura.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.rotulo),
                      ),
                  ],
                  onChanged: (status) {
                    if (status == null) return;
                    setState(() {
                      _status = status;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _cadastrarLivro,
              child: const Text('Salvar livro'),
            ),
          ],
        ),
      ),
    );
  }
}
