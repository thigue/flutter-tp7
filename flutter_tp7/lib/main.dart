// THIAGO GUERRA SOARES

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      status: StatusLeitura.values.byName(json['status'] as String),
    );
  }

  final String titulo;
  final String autor;
  final StatusLeitura status;

  Map<String, String> toJson() {
    return {'titulo': titulo, 'autor': autor, 'status': status.name};
  }
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
  static const _chaveLivros = 'livros';

  List<Livro> _livros = [];
  bool _carregando = true;
  bool _falhaAoCarregar = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() {
      _carregando = true;
      _falhaAoCarregar = false;
    });

    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.reload();
      final dados = preferencias.getString(_chaveLivros);
      final livros = dados == null
          ? <Livro>[]
          : (jsonDecode(dados) as List<dynamic>)
                .map((item) => Livro.fromJson(item as Map<String, dynamic>))
                .toList();

      if (!mounted) return;
      setState(() {
        _livros = livros;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _falhaAoCarregar = true;
      });
    }
  }

  Future<void> _adicionarLivro() async {
    final livro = await Navigator.of(context).push<Livro>(
      MaterialPageRoute(builder: (context) => const TelaCadastroLivro()),
    );

    if (!mounted || livro == null) return;
    await _salvarLivros([..._livros, livro], 'Livro adicionado.');
  }

  Future<void> _removerLivro(Livro livro) async {
    final livros = [..._livros]..remove(livro);
    await _salvarLivros(livros, 'Livro removido.');
  }

  Future<void> _salvarLivros(List<Livro> livros, String mensagem) async {
    if (_salvando) return;
    setState(() {
      _salvando = true;
    });

    bool salvou;
    try {
      final preferencias = await SharedPreferences.getInstance();
      // Cada livro vira um objeto JSON, e a lista inteira ocupa uma única chave.
      final dados = jsonEncode(livros.map((livro) => livro.toJson()).toList());
      salvou = await preferencias.setString(_chaveLivros, dados);
    } catch (_) {
      salvou = false;
    }

    if (!mounted) return;
    setState(() {
      if (salvou) _livros = livros;
      _salvando = false;
    });
    _mostrarMensagem(salvou ? mensagem : 'Não foi possível salvar a lista.');
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
      body: _conteudoDaLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _carregando || _falhaAoCarregar || _salvando
            ? null
            : _adicionarLivro,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar livro'),
      ),
    );
  }

  Widget _conteudoDaLista() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Carregando livros'),
      );
    }

    if (_falhaAoCarregar) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível carregar a lista.'),
              TextButton(
                onPressed: _carregarLivros,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_livros.isEmpty) {
      return const Center(child: Text('Nenhum livro cadastrado.'));
    }

    return ListView.builder(
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
              onPressed: _salvando ? null : () => _removerLivro(livro),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover livro',
            ),
          ),
        );
      },
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
