// lib/widgets/carrossel.dart
import 'package:flutter/material.dart';
import 'package:acervo/components/card_indicacao_book.component.dart';
import 'package:acervo/my_colors.dart';

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
      viewportFraction: 0.55,
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
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.livros.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final livro = widget.livros[index];

          double scale = 1.0;
          if (_pageController.position.hasContentDimensions) {
            double pageOffset = _pageController.page! - index;
            scale = (1.0 - (pageOffset.abs() * 0.25)).clamp(0.75, 1.0);
          } else {
            scale = _currentPage == index ? 1.0 : 0.8;
          }
          double opacity = scale;

          double elevation = scale == 1.0 ? 8.0 : 2.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: scale == 1.0 ? 0 : 10,
            ),
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  elevation: elevation,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: MyColors.abobora.withAlpha(40),
                  child: CardIndicacaoBookComponent(
                    nomeLivro: livro['nomeLivro'],
                    nomeAutor: livro['nomeAutor'],
                    imagemUrl: livro['imagemUrl'],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}