import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:acervo/components/carrossel.dart';
import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:acervo/db_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import '../components/card_resenha_usuario.component.dart';

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _carregando = true;

  List<Map<String, dynamic>> _livrosCarrossel = [];
  Timer? _debounce;
  bool _pesquisando = false;
  List<Map<String, dynamic>> _resultadosPesquisa = [];

  List<Map<String, dynamic>> _ultimasResenhas = [];
  bool _carregandoResenhas = true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _buscarLivrosParaCarrossel();
    _buscarUltimasResenhas();
  }

  Future<void> _buscarUltimasResenhas() async {
    try {
      final resposta = await Supabase.instance.client
          .from(DbTables.resenhas)
          .select('''
            *,
            ${DbTables.usuarios} ( ${DbUsuarios.nome}, ${DbUsuarios.avatarUrl} ),
            ${DbTables.livros} ( ${DbLivros.titulo}, ${DbLivros.autor}, ${DbLivros.capaUrl} )
          ''')
          .order(
            DbResenhas.dataResenha,
            ascending: false,
          ) // Traz as mais recentes primeiro
          .limit(10); // Limita para não pesar a memória do celular

      // Se o widget ainda estiver na tela quando o dado chegar, atualiza a UI
      if (mounted) {
        setState(() {
          _ultimasResenhas = List<Map<String, dynamic>>.from(resposta);
          _carregandoResenhas = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar resenhas: $e');
      // Mesmo dando erro, precisamos parar de mostrar a bolinha girando
      if (mounted) {
        setState(() {
          _carregandoResenhas = false;
        });
      }
    }
  }

  Future<void> _buscarLivrosParaCarrossel() async {
    try {
      final resposta = await Supabase.instance.client
          .from(DbTables.livros)
          .select()
          .limit(50);

      List<dynamic> listaSorteio = List.from(resposta);
      listaSorteio.shuffle();
      final sorteados = listaSorteio.take(20).toList();

      final livrosMapeados = sorteados.map((livro) {
        String urlCapa = livro[DbLivros.capaUrl] ?? '';

        if (urlCapa.startsWith('http://')) {
          urlCapa = urlCapa.replaceFirst('http://', 'https://');
        }
        if (urlCapa.isNotEmpty) {
          urlCapa =
              'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';
        }

        return {
          'nomeLivro': livro[DbLivros.titulo] ?? 'Sem título',
          'nomeAutor': livro[DbLivros.autor] ?? 'Autor Desconhecido',
          'imagemUrl': urlCapa,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _livrosCarrossel = livrosMapeados;
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro no Carrossel: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _realizarPesquisa(String query) async {
    final buscaLimpa = query.trim();
    if (buscaLimpa.isEmpty) return;

    setState(() {
      _pesquisando = true;
    });

    try {
      final respostaSupabase = await Supabase.instance.client
          .from(DbTables.livros)
          .select()
          .ilike(DbLivros.titulo, '%$buscaLimpa%');

      if (respostaSupabase.isNotEmpty) {
        debugPrint('Encontrado no Supabase! Ignorando o Google.');

        final resultadosLocais = respostaSupabase.map((livro) {
          String urlCapa = livro[DbLivros.capaUrl] ?? '';

          if (urlCapa.startsWith('http://')) {
            urlCapa = urlCapa.replaceFirst('http://', 'https://');
          }

          if (urlCapa.isNotEmpty) {
            urlCapa =
                'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';
          }

          return {
            'nomeLivro': livro[DbLivros.titulo] ?? 'Sem título',
            'nomeAutor': livro[DbLivros.autor] ?? 'Autor Desconhecido',
            'imagemUrl': urlCapa,
            'veioDoBanco': true,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _resultadosPesquisa = resultadosLocais;
            _pesquisando = false;
          });
        }
        return;
      }

      debugPrint('Não achou no Supabase. Buscando no Google Books...');
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
            urlCapa =
                'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlCapa)}';
            debugPrint('URL da Capa Gerada: $urlCapa');
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
        debugPrint('Erro no Google: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro na pesquisa híbrida: $e');
    } finally {
      if (mounted) {
        setState(() {
          _pesquisando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.creme,
      child: SingleChildScrollView(
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      if (value.isEmpty) _resultadosPesquisa.clear();
                    });

                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    if (value.isNotEmpty) {
                      _debounce = Timer(const Duration(milliseconds: 600), () {
                        _realizarPesquisa(value);
                      });
                    }
                  },
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
                                _resultadosPesquisa.clear();
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

            // Conteúdo baseado no estado da pesquisa
            _searchQuery.isEmpty
                ? _buildConteudoPrincipal()
                : _buildListaDoGoogle(),
          ],
        ),
      ),
    );
  }

  // Conteúdo principal quando não está pesquisando
  Widget _buildConteudoPrincipal() {
    return Column(
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
              const Text("ver mais..", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: _carregando
              ? const SizedBox(
                  height: 380,
                  child: Center(
                    child: CircularProgressIndicator(color: MyColors.abobora),
                  ),
                )
              : Carrossel(livros: _livrosCarrossel),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Últimas Críticas",
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: MyColors.preto,
              ),
            ),
          ),
        ),
        // Renderização Dinâmica das Últimas Críticas
        _carregandoResenhas
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: MyColors.abobora),
              )
            : _ultimasResenhas.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Nenhuma crítica recente encontrada.',
                  style: TextStyle(color: MyColors.marromClaro),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ultimasResenhas
                    .length, // Garantindo que o itemCount seja baseado na lista real de resenhas
                itemBuilder: (context, index) {
                  final resenha = _ultimasResenhas[index];

                  final usuario = resenha[DbTables.usuarios] ?? {};
                  final livro = resenha[DbTables.livros] ?? {};

                  // Variáveis blindadas para evitar crashes por dados quebrados
                  DateTime dataSegura = DateTime.now();

                  try {
                    String dataBruta = resenha[DbResenhas.dataResenha]
                        .toString();

                    // O Flutter confere se tem a barra. Se tiver, ele fatia e inverte.
                    if (dataBruta.contains('/')) {
                      List<String> partes = dataBruta.split('/');
                      if (partes.length >= 3) {
                        String dia = partes[0];
                        String mes = partes[1];
                        String ano = partes[2];

                        // Monta no padrão ISO: Ano-Mês-Dia (Opcional: adiciona tempo 00:00:00)
                        String dataConvertida = "$ano-$mes-$dia";
                        dataSegura = DateTime.parse(dataConvertida);
                      }
                    } else {
                      // Se por acaso já vier no formato certo
                      dataSegura = DateTime.parse(dataBruta);
                    }
                  } catch (e) {
                    debugPrint("Erro na conversão de data da resenha: $e");
                  }

                  double avaliacaoSegura = 0.0;
                  try {
                    // Se o banco mandar a nota como '4.5' em texto, ele converte em numero com segurança
                    avaliacaoSegura = double.parse(
                      resenha[DbResenhas.avaliacaoResenha].toString(),
                    );
                  } catch (e) {
                    avaliacaoSegura = 0.0;
                  }

                  return CardResenhaUsuarioComponent(
                    idResenha: resenha[DbResenhas.idResenha] ?? 0,
                    nomeUsuario:
                        usuario[DbUsuarios.nome] ?? 'Usuário Desconhecido',
                    avatarUrl: usuario[DbUsuarios.avatarUrl] ?? '',
                    tituloLivro: livro[DbLivros.titulo] ?? 'Livro Desconhecido',
                    autorLivro: livro[DbLivros.autor] ?? '',
                    resenha: resenha[DbResenhas.comentario] ?? '',
                    avaliacao: avaliacaoSegura,
                    dataResenha: dataSegura,
                    // Usando a variável blindada
                    onLike: () {
                      debugPrint("Curtiu a resenha!");
                    },
                  );
                },
              ),
        const SizedBox(height: 30), // Espaço no final
      ],
    );
  }

  // Lista de resultados do Google
  Widget _buildListaDoGoogle() {
    if (_pesquisando) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(color: MyColors.abobora),
        ),
      );
    }

    if (_resultadosPesquisa.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Nenhum livro encontrado.')),
      );
    }

    return ListView.builder(
      shrinkWrap:
          true, // Importante para funcionar dentro do SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Desativa scroll interno
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
