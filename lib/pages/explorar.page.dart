import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:acervo/components/card_indicacao_book.component.dart';
import 'package:acervo/components/carrossel.dart';
import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';
// ADIÇÃO: Importamos o motor do Supabase para o Flutter conseguir ir até a nuvem.
import 'package:supabase_flutter/supabase_flutter.dart';
// ADIÇÃO: Importamos o nosso "gabarito" para não errarmos o nome das colunas do banco.
import 'package:acervo/db_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async'; // Necessário para o Timer do Debounce

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  // Controle da barra de pesquisa (ainda vamos conectar isso ao banco no futuro)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // VARIÁVEIS DE ESTADO

  // Começa como 'true' porque assim que a tela abre, nós ainda não temos os dados, então ela precisa mostrar a bolinha girando.
  bool _carregando = true;

  // Array pra guardar a lista de livros quando ela chegar do Supabase.
  List<Map<String, dynamic>> _livrosCarrossel = [];
  // Variáveis para a Pesquisa do Google

  Timer? _debounce; //realiza a pesquisa assim que o usuario para de digitar
  bool _pesquisando = false;
  List<Map<String, dynamic>> _resultadosPesquisa = [];

  @override
  void dispose() {
    // Quando o usuário sai dessa tela, desligamos o "ouvinte" da barra de pesquisa para liberar a memória RAM do celular (evita Memory Leak).
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // O initState é o "nascimento" da tela. Assim que ela nasce, executa a busca na nuvem imediatamente.
    _buscarLivrosParaCarrossel();
  }

  // 1. MOTOR DO SUPABASE (obras aleatórias no carrossel)
  Future<void> _buscarLivrosParaCarrossel() async {
    try {
      // 1. Busca um lote de livros (sem tentar ordenar por colunas que não conhecemos)
      final resposta = await Supabase.instance.client
          .from(DbTables.livros)
          .select()
          .limit(50); // Puxa até 50 livros que você tem no banco

      // 2. Transforma a resposta em uma lista normal que o Dart aceita modificar
      List<dynamic> listaSorteio = List.from(resposta);

      // 3. Embaralha a lista aleatoriamente
      listaSorteio.shuffle();

      // 4. Pega apenas os 20 primeiros da lista que acabou de ser misturada
      final sorteados = listaSorteio.take(20).toList();

      // 5. Faz a tradução para o formato do Carrossel (igual já fazíamos)
      final livrosMapeados = sorteados.map((livro) {
        String urlCapa = livro[DbLivros.capaUrl] ?? '';

        if (urlCapa.startsWith('http://')) {
          urlCapa = urlCapa.replaceFirst('http://', 'https://');
        }
        if (urlCapa.isNotEmpty) {
          // O Bypass definitivo usando o AllOrigins (Proxy Livre pra aparecer as capas sem bloqueio de CORS)
          urlCapa =
              'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';
        }

        return {
          'nomeLivro': livro[DbLivros.titulo] ?? 'Sem título',
          'nomeAutor': livro[DbLivros.autor] ?? 'Autor Desconhecido',
          'imagemUrl': urlCapa,
        };
      }).toList();

      // Atualiza a tela
      if (mounted) {
        setState(() {
          _livrosCarrossel = livrosMapeados;
          _carregando = false;
        });
      }
    } catch (e) {
      print('Erro no Carrossel: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  // MOTOR DE BUSCA HÍBRIDO (Local-First com Fallback no Google)

  Future<void> _realizarPesquisa(String query) async {
    final buscaLimpa = query.trim();
    if (buscaLimpa.isEmpty) return;

    setState(() {
      _pesquisando = true; // Liga a bolinha de carregamento
    });

    try {
      // Usamos '.ilike' para buscar o texto ignorando se é maiúscula ou minúscula.
      // Os '%' em volta indicam que a palavra pode estar em qualquer parte do título.
      final respostaSupabase = await Supabase.instance.client
          .from(DbTables.livros)
          .select()
          .ilike(DbLivros.titulo, '%$buscaLimpa%');

      // Se achou alguma coisa no Supabase, preenche a tela e ENCERRA a busca!
      if (respostaSupabase.isNotEmpty) {
        print(' Encontrado no Supabase! Ignorando o Google.');

        final resultadosLocais = respostaSupabase.map((livro) {
          String urlCapa = livro[DbLivros.capaUrl] ?? '';

          if (urlCapa.startsWith('http://')) {
            urlCapa = urlCapa.replaceFirst('http://', 'https://');
          }

          if (urlCapa.isNotEmpty) {
            // O Bypass definitivo usando o AllOrigins (Proxy Livre)
            urlCapa =
                'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';
          }

          return {
            'nomeLivro': livro[DbLivros.titulo] ?? 'Sem título',
            'nomeAutor': livro[DbLivros.autor] ?? 'Autor Desconhecido',
            'imagemUrl': urlCapa,
            // Podemos adicionar uma flag para saber de onde veio (opcional)
            'veioDoBanco': true,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _resultadosPesquisa = resultadosLocais;
            _pesquisando = false;
          });
        }
        return; // O 'return' expulsa a gente da função. O Google nem fica sabendo dessa pesquisa!
      }

      // FALLBACK NO GOOGLE BOOKS (Se o Supabase retornou vazio)
      print('Não achou no Supabase. Buscando no Google Books...');
      // PUXANDO DO COFRE:
      final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? 'API não encontrada';

      final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': 'intitle:$buscaLimpa',
        'maxResults': '10',
        'key': apiKey,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        final resultadosGoogle = items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          String urlCapa = volumeInfo['imageLinks']?['thumbnail'] ?? '';

          if (urlCapa.startsWith('http://')) {
            urlCapa = urlCapa.replaceFirst('http://', 'https://');
          }

          if (urlCapa.isNotEmpty) {
            // O Bypass definitivo usando o AllOrigins (Proxy Livre)
            urlCapa =
                'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';

            print('URL da Capa Gerada: $urlCapa');
          }

          final autores = volumeInfo['authors'] as List<dynamic>?;
          final nomeAutor = autores != null && autores.isNotEmpty
              ? autores[0]
              : 'Autor Desconhecido';

          return {
            'nomeLivro': volumeInfo['title'] ?? 'Sem título',
            'nomeAutor': nomeAutor,
            'imagemUrl': urlCapa,
            'veioDoBanco': false,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _resultadosPesquisa = resultadosGoogle;
          });
        }
      } else {
        print('Erro no Google: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na pesquisa híbrida: $e');
    } finally {
      if (mounted) {
        setState(() {
          _pesquisando = false;
        });
      }
    }
  }

  //(UI)
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.creme,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                // A MÁGICA DO TEMPO REAL ACONTECE AQUI:
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    // Se o usuário apagar tudo, limpamos a lista antiga
                    if (value.isEmpty) _resultadosPesquisa.clear();
                  });

                  // Cancela o cronômetro anterior se o usuário ainda estiver digitando
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  // Se a caixa não estiver vazia, inicia um novo cronômetro de 600ms
                  if (value.isNotEmpty) {
                    _debounce = Timer(const Duration(milliseconds: 600), () {
                      _realizarPesquisa(value);
                    });
                  }
                },
                // Mantém o Enter para quem prefere usar o teclado
                onSubmitted: (value) {
                  _realizarPesquisa(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar livros, autores...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: MyColors.abobora),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _resultadosPesquisa.clear(); // Limpa os resultados ao clicar no 'X'
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          // --- O CONTROLADOR DE TRÁFEGO ---
          Expanded(
            child: _searchQuery.isEmpty
                // MODO 1: BARRA VAZIA (Mostra Carrossel do Supabase)
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'PlayfairDisplay',
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: MyColors.preto,
                                  ),
                                  children: [
                                    TextSpan(text: 'Tendências do \n'),
                                    TextSpan(text: 'momento'),
                                  ],
                                ),
                              ),
                            ),
                            const Text(
                              "ver mais..",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _carregando
                            ? const SizedBox(
                                height: 340,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: MyColors.abobora,
                                  ),
                                ),
                              )
                            : Carrossel(livros: _livrosCarrossel),
                      ),
                    ],
                  )
                // MODO 2: USUÁRIO PESQUISOU ALGO (Mostra Lista do Google)
                : _buildListaDoGoogle(),
          ),
        ],
      ),
    );
  }

  // --- LISTA DE RESULTADOS DO GOOGLE ---
  Widget _buildListaDoGoogle() {
    if (_pesquisando) {
      return const Center(
        child: CircularProgressIndicator(color: MyColors.abobora),
      );
    }

    if (_resultadosPesquisa.isEmpty) {
      return const Center(
        child: Text('Nenhum livro encontrado ou aperte Enter para buscar.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _resultadosPesquisa.length,
      itemBuilder: (context, index) {
        final livro = _resultadosPesquisa[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: livro['imagemUrl'].toString().isNotEmpty
                  ? Image.network(
                      livro['imagemUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.book, color: MyColors.abobora),
                    )
                  : const Icon(Icons.book, color: MyColors.abobora),
            ),
            title: Text(
              livro['nomeLivro'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              livro['nomeAutor'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: MyColors.abobora,
              ),
              onPressed: () {
                // Futuro: Adicionar livro ao banco
              },
            ),
          ),
        );
      },
    );
  }
}
