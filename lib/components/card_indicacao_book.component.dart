import 'package:flutter/material.dart';

class CardIndicacaoBookComponent extends StatefulWidget {
  final String nomeLivro;
  final String nomeAutor;
  final String? imagemUrl;

  const CardIndicacaoBookComponent({
    super.key,
    required this.nomeLivro,
    required this.nomeAutor,
    this.imagemUrl,
  });

  @override
  State<CardIndicacaoBookComponent> createState() => _CardIndicacaoBookComponentState();
}

class _CardIndicacaoBookComponentState extends State<CardIndicacaoBookComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: 160,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.imagemUrl != null && widget.imagemUrl!.isNotEmpty
                ? Image.network(
              widget.imagemUrl!,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Se falhar ao carregar imagem da URL, usa a genérica
                return Image.asset(
                  'assets/images/livroGenerico.jpg',
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              'assets/images/livroGenerico.jpg',
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.nomeLivro,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.nomeAutor,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}