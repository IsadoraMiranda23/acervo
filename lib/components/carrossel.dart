// lib/widgets/carrossel.dart
import 'package:flutter/material.dart';
import 'package:acervo/components/card_indicacao_book.component.dart';

class Carrossel extends StatefulWidget {
  final List<Map<String, dynamic>> livros;

  const Carrossel({
    super.key,
    required this.livros,
  });

  @override
  State<Carrossel> createState() => _CarrosselState();
}

class _CarrosselState extends State<Carrossel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.45,
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.livros.length,
        itemBuilder: (context, index) {
          final livro = widget.livros[index];
          double scale = _currentPage == index ? 1.0 : 0.8;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Transform.scale(
              scale: scale,
              child: CardIndicacaoBookComponent(
                nomeLivro: livro['nomeLivro'],
                nomeAutor: livro['nomeAutor'],
                imagemUrl: livro['imagemUrl'],
              ),
            ),
          );
        },
      ),
    );
  }
}