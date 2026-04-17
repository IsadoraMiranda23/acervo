import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';

class BotaoComponente extends StatefulWidget {
  final String texto;
  final VoidCallback onPressed;
  final double? largura;
  final double? altura;
  final Color? corFundo;
  final Color? corTexto;
  final double? borderRadius;
  final double? tamanhoFonte;
  final FontWeight? pesoFonte;
  final IconData? iconeAntes;
  final IconData? iconeDepois;
  final double? tamanhoIcone;
  final bool isLoading;

  const BotaoComponente({
    super.key,
    required this.texto,
    required this.onPressed,
    this.largura,
    this.altura,
    this.corFundo,
    this.corTexto,
    this.borderRadius,
    this.tamanhoFonte,
    this.pesoFonte,
    this.iconeAntes,
    this.iconeDepois,
    this.tamanhoIcone,
    this.isLoading = false,
  });

  @override
  State<BotaoComponente> createState() => _BotaoComponenteState();
}

class _BotaoComponenteState extends State<BotaoComponente> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.largura ?? double.infinity,
      height: widget.altura ?? 50,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.corFundo ?? MyColors.marrom,
          foregroundColor: widget.corTexto ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
          ),
          elevation: 0,
        ),
        child: widget.isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.corTexto ?? Colors.white,
            ),
          ),
        )
            : Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             SizedBox(width: 10,),
              if (widget.iconeAntes != null) ...[
                Icon(
                  widget.iconeAntes,
                  size: widget.tamanhoIcone ?? (widget.tamanhoFonte ?? 16) + 4,
                  color: widget.corTexto ?? Colors.white,
                ),
                const SizedBox(width: 16),
              ],

              // Texto
              Text(
                widget.texto,
                style: TextStyle(
                  fontSize: widget.tamanhoFonte ?? 17,
                  fontWeight: widget.pesoFonte ?? FontWeight.w600,
                  color: widget.corTexto ?? Colors.white,
                ),
              ),

              SizedBox(width: 10,),

              if (widget.iconeDepois != null) ...[
                const SizedBox(width: 12),
                Icon(
                  widget.iconeDepois,
                  size: widget.tamanhoIcone ?? (widget.tamanhoFonte ?? 16) + 4,
                  color: widget.corTexto ?? Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}