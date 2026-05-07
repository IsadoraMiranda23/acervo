import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';

class CardAtualizacaoNavegarComponent extends StatefulWidget {
  final String nomeUsuario;
  final String? fotoUsuarioUrl;
  final String nomeLivro;
  final String nomeAutor;
  final String? imagemUrl;
  final bool estaLendo;
  final int? progressoPorcentagem;
  final double? avaliacao;
  final String descricao;
  final DateTime dataAtualizacao;
  final VoidCallback? onTap;
  // Novos callbacks para interações
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const CardAtualizacaoNavegarComponent({
    super.key,
    required this.nomeUsuario,
    this.fotoUsuarioUrl,
    required this.nomeLivro,
    required this.nomeAutor,
    this.imagemUrl,
    required this.estaLendo,
    this.progressoPorcentagem,
    this.avaliacao,
    required this.descricao,
    required this.dataAtualizacao,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  State<CardAtualizacaoNavegarComponent> createState() =>
      _CardAtualizacaoNavegarComponentState();
}

class _CardAtualizacaoNavegarComponentState
    extends State<CardAtualizacaoNavegarComponent> {
  bool _curtido = false;
  int _curtidasCount = 0; // exemplo: poderia vir do backend

  @override
  void initState() {
    super.initState();
    // Simula um número inicial de curtidas (ex: 24)
    _curtidasCount = 24;
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours} h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d atrás';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} sem atrás';
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
        estrelas.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == estrelasCheias && temMeiaEstrela) {
        estrelas.add(
            const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        estrelas.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: estrelas,
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.estaLendo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progresso",
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
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.progressoPorcentagem ?? 0}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: MyColors.abobora,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
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

  void _handleLike() {
    setState(() {
      if (!_curtido) {
        _curtido = true;
        _curtidasCount++;
      } else {
        _curtido = false;
        _curtidasCount--;
      }
    });
    if (widget.onLike != null) widget.onLike!();
  }

  void _handleComment() {
    if (widget.onComment != null) widget.onComment!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO: Avatar + Nome + Data
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: MyColors.creme,
                  backgroundImage: widget.fotoUsuarioUrl != null &&
                      widget.fotoUsuarioUrl!.isNotEmpty
                      ? NetworkImage(widget.fotoUsuarioUrl!)
                      : null,
                  child: widget.fotoUsuarioUrl == null ||
                      widget.fotoUsuarioUrl!.isEmpty
                      ? Icon(Icons.person, color: MyColors.abobora, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nomeUsuario,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: MyColors.preto,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Atualizou um livro",
                        style: TextStyle(
                          fontSize: 11,
                          color: MyColors.marromClaro,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatarData(widget.dataAtualizacao),
                  style: TextStyle(
                    fontSize: 11,
                    color: MyColors.marromClaro.withAlpha(150),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CORPO: Capa + Informações do livro
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Capa do livro
                Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: MyColors.creme,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.imagemUrl != null && widget.imagemUrl!.isNotEmpty
                      ? Image.network(
                    widget.imagemUrl!,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.book,
                        size: 50,
                        color: MyColors.abobora.withAlpha(100),
                      );
                    },
                  )
                      : Icon(
                    Icons.book,
                    size: 50,
                    color: MyColors.abobora.withAlpha(100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nomeLivro,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MyColors.preto,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.nomeAutor,
                        style: TextStyle(
                          fontSize: 13,
                          color: MyColors.marromClaro,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        widget.descricao,
                        style: TextStyle(
                          fontSize: 13,
                          color: MyColors.marromMedio,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                GestureDetector(
                  onTap: _handleLike,
                  child: Row(
                    children: [
                      Icon(
                        _curtido ? Icons.favorite : Icons.favorite_border,
                        color: _curtido ? Colors.red : MyColors.marromClaro,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_curtidasCount',
                        style: TextStyle(
                          fontSize: 13,
                          color: MyColors.marromClaro,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Botão Comentar
                GestureDetector(
                  onTap: _handleComment,
                  child: Row(
                    children: [
                      Icon(
                        Icons.mode_comment_outlined,
                        color: MyColors.marromClaro,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Comentar',
                        style: TextStyle(
                          fontSize: 13,
                          color: MyColors.marromClaro,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}