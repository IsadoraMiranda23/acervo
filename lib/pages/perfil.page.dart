import 'package:acervo/components/card_atualizacao.component.dart';
import 'package:acervo/components/carrossel.progresso.dart';
import 'package:flutter/material.dart';
import '../components/card_atualizacao.component.dart';
import '../my_colors.dart';

class PerfilPage extends StatefulWidget {
  final String nomeUsuario;
  final String avatarUrl;
  final int livrosLidos;
  final int paginasLidas;
  final int diasSeguidos;
  final String? bio;

  const PerfilPage({
    super.key,
    required this.nomeUsuario,
    this.avatarUrl = '',
    this.livrosLidos = 0,
    this.paginasLidas = 0,
    this.diasSeguidos = 0,
    this.bio,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Dados de exemplo para os livros em andamento
  // Depois você pode buscar esses dados do Supabase
  final List<Map<String, dynamic>> _livrosEmAndamento = [
    {
      'nomeLivro': 'O Guia do Mochileiro das Galáxias',
      'imagemUrl': 'https://m.media-amazon.com/images/I/51cUQ4WqepL.jpg',
      'progressoPorcentagem': 65,
      'paginasLidas': 150,
      'paginasTotais': 328,
    },
    {
      'nomeLivro': '1984',
      'imagemUrl': 'https://m.media-amazon.com/images/I/71kxa1-0mfL.jpg',
      'progressoPorcentagem': 42,
      'paginasLidas': 137,
      'paginasTotais': 326,
    },
    {
      'nomeLivro': 'Dom Casmurro',
      'imagemUrl': 'https://m.media-amazon.com/images/I/81XxXxXxXxL.jpg',
      'progressoPorcentagem': 80,
      'paginasLidas': 400,
      'paginasTotais': 500,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.creme,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Avatar
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.creme,
                  border: Border.all(color: MyColors.abobora, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.avatarUrl.isNotEmpty
                      ? Image.network(
                    widget.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 100,
                        color: MyColors.abobora,
                      );
                    },
                  )
                      : Icon(Icons.person, size: 100, color: MyColors.abobora),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nome do usuário
            Center(
              child: Text(
                widget.nomeUsuario,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: MyColors.marromMedio,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bio do usuário (só mostra se tiver bio)
            if (widget.bio != null && widget.bio!.isNotEmpty)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.bio!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColors.marromClaro,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Cards de estatísticas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card Livros Lidos
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 50,
                            color: MyColors.abobora,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.livrosLidos.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromMedio,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "LIVROS LIDOS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromClaro,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Card Páginas Lidas
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.description,
                            size: 50,
                            color: MyColors.abobora,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.paginasLidas.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromMedio,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "PÁGINAS LIDAS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromClaro,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Card Dias Seguidos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: MyColors.abobora,
                  borderRadius: BorderRadius.circular(45),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.abobora.withAlpha(60),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 55,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.diasSeguidos.toString(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: MyColors.creme,
                          ),
                        ),
                        const Text(
                          "DIAS SEGUIDOS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.creme,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Leituras atuais",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                        fontStyle: FontStyle.italic,
                        color: MyColors.preto,
                      ),
                    ),
                  ),
                  InkWell(child: Text("Ver tudo ")),
                ],
              ),
            ),

            const SizedBox(height: 16),


            CarrosselProgresso(
              livros: _livrosEmAndamento,
            ),

            const SizedBox(height: 30),

            Text("Atualizações recentes"),

            CardAtualizacaoComponent(
              nomeLivro: "O Guia do Mochileiro das Galáxias",
              nomeAutor: "Douglas Adams",
              imagemUrl: "https://exemplo.com/capa.jpg",
              estaLendo: true,
              progressoPorcentagem: 65,
              descricao: "Estou adorando esse livro! A mistura de humor com ficção científica é sensacional. Recomendo demais para quem gosta de uma leitura leve e criativa.",
              dataAtualizacao: DateTime.now().subtract(const Duration(days: 2)),
              onTap: () {
                print("Card clicado!");
              },
            ),

            CardAtualizacaoComponent(
              nomeLivro: "1984",
              nomeAutor: "George Orwell",
              imagemUrl: "https://exemplo.com/capa2.jpg",
              estaLendo: false,
              avaliacao: 4.5,
              descricao: "Uma obra-prima! Terminei esse livro impactado. A crítica social é atemporal e assustadoramente atual. Leitura obrigatória para todos.",
              dataAtualizacao: DateTime.now().subtract(const Duration(days: 15)),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildGeneroChip("Ficção Científica"),
                    _buildGeneroChip("Fantasia"),
                    _buildGeneroChip("Romance"),
                    _buildGeneroChip("Aventura"),
                    _buildGeneroChip("Suspense"),
                    _buildGeneroChip("Terror"),
                    _buildGeneroChip("Biografia"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroChip(String genero) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: MyColors.creme,
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: MyColors.abobora.withAlpha(80), width: 1.5),
      ),
      child: Text(
        genero,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: MyColors.marromMedio,
        ),
      ),
    );
  }
}