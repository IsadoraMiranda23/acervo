import 'package:flutter/material.dart';
import 'package:acervo/components/progresso_livro.component.dart';
import 'package:acervo/my_colors.dart';

class CarrosselProgresso extends StatelessWidget {
  final List<Map<String, dynamic>> livros;

  const CarrosselProgresso({
    super.key,
    required this.livros,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: livros.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final livro = livros[index];

          return Container(
            width: 160, // Largura fixa para todos
            margin: const EdgeInsets.only(right: 16),
            child: ProgressoLivroComponent(
              nomeLivro: livro['nomeLivro'] ?? 'Sem título',
              imagemUrl: livro['imagemUrl'],
              progressoPorcentagem: livro['progressoPorcentagem'] ?? 0,
              paginasLidas: livro['paginasLidas'] ?? 0,
              paginasTotais: livro['paginasTotais'] ?? 0,
            ),
          );
        },
      ),
    );
  }
}