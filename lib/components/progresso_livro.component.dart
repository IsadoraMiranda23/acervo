import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:acervo/my_colors.dart';

class ProgressoLivroComponent extends StatefulWidget {
  final String nomeLivro;
  final String? imagemUrl;
  final int progressoPorcentagem;
  final int paginasLidas;
  final int paginasTotais;

  const ProgressoLivroComponent({
    super.key,
    required this.nomeLivro,
    this.imagemUrl,
    this.progressoPorcentagem = 0,
    this.paginasLidas = 0,
    this.paginasTotais = 0,
  });

  @override
  State<ProgressoLivroComponent> createState() => _ProgressoLivroComponentState();
}

class _ProgressoLivroComponentState extends State<ProgressoLivroComponent> {
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                // CORREÇÃO AQUI - Use o enum corretamente
                SizedBox(
                  width: 144,
                  child: LinearProgressBar(
                    maxSteps: 100,
                    currentStep: widget.progressoPorcentagem,
                    progressType: ProgressType.linear, // ← Use ProgressType.linear
                    progressColor: MyColors.abobora,
                    backgroundColor: MyColors.marromClaro.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.progressoPorcentagem}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: MyColors.marromMedio,
                      ),
                    ),
                    if (widget.paginasTotais > 0)
                      Text(
                        '${widget.paginasLidas}/${widget.paginasTotais} págs',
                        style: TextStyle(
                          fontSize: 10,
                          color: MyColors.marromClaro,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}