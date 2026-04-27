import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';

class CardAtualizacaoComponent extends StatefulWidget {
  final String nomeLivro;
  final String nomeAutor;
  final String? imagemUrl;
  final bool estaLendo; // true = lendo, false = já leu
  final int? progressoPorcentagem; // Para livros em leitura (0-100)
  final double? avaliacao; // Para livros já lidos (0-5)
  final String descricao;
  final DateTime dataAtualizacao;
  final VoidCallback? onTap;

  const CardAtualizacaoComponent({
    super.key,
    required this.nomeLivro,
    required this.nomeAutor,
    this.imagemUrl,
    required this.estaLendo,
    this.progressoPorcentagem,
    this.avaliacao,
    required this.descricao,
    required this.dataAtualizacao,
    this.onTap,
  });

  @override
  State<CardAtualizacaoComponent> createState() => _CardAtualizacaoComponentState();
}

class _CardAtualizacaoComponentState extends State<CardAtualizacaoComponent> {
  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutos atrás';
      }
      return '${difference.inHours} horas atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} semanas atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

  Widget _buildEstrelas() {
    if (widget.avaliacao == null) return const SizedBox.shrink();

    List<Widget> estrelas = [];
    int estrelasCheias = widget.avaliacao!.floor();
    bool temMeiaEstrela = widget.avaliacao! - estrelasCheias >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < estrelasCheias) {
        estrelas.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == estrelasCheias && temMeiaEstrela) {
        estrelas.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        estrelas.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: estrelas,
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.estaLendo) {
      // Status de leitura (progresso)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progresso de leitura",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MyColors.marromClaro,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (widget.progressoPorcentagem ?? 0) / 100,
                    backgroundColor: MyColors.marromClaro.withAlpha(50),
                    color: MyColors.abobora,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.progressoPorcentagem ?? 0}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: MyColors.abobora,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Status de concluído (avaliação)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Avaliação",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MyColors.marromClaro,
            ),
          ),
          const SizedBox(height: 4),
          _buildEstrelas(),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa do livro
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: MyColors.creme,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.imagemUrl != null && widget.imagemUrl!.isNotEmpty
                  ? Image.network(
                widget.imagemUrl!,
                width: 80,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.book,
                    size: 40,
                    color: MyColors.abobora.withAlpha(100),
                  );
                },
              )
                  : Icon(
                Icons.book,
                size: 40,
                color: MyColors.abobora.withAlpha(100),
              ),
            ),

            const SizedBox(width: 12),

            // Informações do livro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.nomeLivro,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.preto,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Autor
                  Text(
                    widget.nomeAutor,
                    style: TextStyle(
                      fontSize: 12,
                      color: MyColors.marromClaro,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Status (progresso ou avaliação)
                  _buildStatusIndicator(),

                  const SizedBox(height: 8),

                  // Descrição da experiência
                  Text(
                    widget.descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: MyColors.marromMedio,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Data
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: MyColors.marromClaro.withAlpha(150),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatarData(widget.dataAtualizacao),
                        style: TextStyle(
                          fontSize: 10,
                          color: MyColors.marromClaro.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}