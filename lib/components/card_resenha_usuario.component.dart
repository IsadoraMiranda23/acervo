import 'package:acervo/my_colors.dart';
import 'package:flutter/material.dart';

class CardResenhaUsuarioComponent extends StatefulWidget {
  final String nomeUsuario;
  final String avatarUrl;
  final String tituloLivro;
  final String autorLivro;
  final String resenha;
  final double avaliacao; // 0 a 5
  final DateTime dataResenha;
  final VoidCallback? onLike;
  final VoidCallback? onComentar;
  final VoidCallback? onCompartilhar;

  const CardResenhaUsuarioComponent({
    super.key,
    required this.nomeUsuario,
    required this.tituloLivro,
    required this.autorLivro,
    required this.resenha,
    required this.avaliacao,
    required this.dataResenha,
    this.avatarUrl = '',
    this.onLike,
    this.onComentar,
    this.onCompartilhar,
  });

  @override
  State<CardResenhaUsuarioComponent> createState() => _CardResenhaUsuarioComponentState();
}

class _CardResenhaUsuarioComponentState extends State<CardResenhaUsuarioComponent> {
  bool _expandido = false;
  bool _curtido = false;
  int _numeroCurtidas = 0;

  @override
  void initState() {
    super.initState();
    _numeroCurtidas = 0; // Aqui você pode carregar do backend
  }

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
    List<Widget> estrelas = [];
    int estrelasCheias = widget.avaliacao.floor();
    bool temMeiaEstrela = widget.avaliacao - estrelasCheias >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < estrelasCheias) {
        estrelas.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == estrelasCheias && temMeiaEstrela) {
        estrelas.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        estrelas.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: estrelas,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MyColors.branco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com info do usuário e livro
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.creme,
                    border: Border.all(
                      color: MyColors.abobora,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.avatarUrl.isNotEmpty
                        ? Image.network(
                      widget.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: MyColors.abobora,
                        );
                      },
                    )
                        : Icon(
                      Icons.person,
                      size: 30,
                      color: MyColors.abobora,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nome e info do livro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nomeUsuario,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.preto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.tituloLivro,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: MyColors.abobora,
                        ),
                      ),
                      Text(
                        widget.autorLivro,
                        style: TextStyle(
                          fontSize: 12,
                          color: MyColors.marromClaro,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estrelas
                _buildEstrelas(),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: MyColors.creme,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Resenha (expansível)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _expandido
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _buildResenhaPreview(),
                  secondChild: _buildResenhaCompleta(),
                ),

                // Botão "Ver mais/menos"
                if (_resenhaPrecisaExpandir())
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _expandido = !_expandido;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: MyColors.abobora,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        _expandido ? 'Ver menos' : 'Ver mais',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Data e ações
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Data
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: MyColors.marromClaro.withAlpha(150),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatarData(widget.dataResenha),
                  style: TextStyle(
                    fontSize: 12,
                    color: MyColors.marromClaro.withAlpha(150),
                  ),
                ),
                const Spacer(),

                // Botão Curtir
                _buildActionButton(
                  icon: _curtido ? Icons.favorite : Icons.favorite_border,
                  label: _numeroCurtidas.toString(),
                  onTap: () {
                    setState(() {
                      _curtido = !_curtido;
                      _numeroCurtidas += _curtido ? 1 : -1;
                    });
                    widget.onLike?.call();
                  },
                  color: _curtido ? Colors.red : MyColors.marromClaro,
                ),

                const SizedBox(width: 16),

                // Botão Comentar
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comentar',
                  onTap: widget.onComentar,
                ),

                const SizedBox(width: 16),

                // Botão Compartilhar
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartilhar',
                  onTap: widget.onCompartilhar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResenhaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.resenha,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: MyColors.preto,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildResenhaCompleta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.resenha,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: MyColors.preto,
          ),
        ),
      ],
    );
  }

  bool _resenhaPrecisaExpandir() {
    // Verifica se a resenha tem mais de 5 linhas
    final textSpan = TextSpan(
      text: widget.resenha,
      style: const TextStyle(fontSize: 14),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 5,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    return textPainter.didExceedMaxLines;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? MyColors.marromClaro,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? MyColors.marromClaro,
            ),
          ),
        ],
      ),
    );
  }
}