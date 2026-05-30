import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';
import 'package:go_router/go_router.dart';

class InfoLivroPage extends StatefulWidget {
  final String? livroId;
  final String? titulo;
  final String? autor;
  final String? capaUrl;
  final String? descricao;
  final int? paginas;
  final String? genero;
  final double? avaliacao;

  const InfoLivroPage({
    super.key,
    this.livroId,
    this.titulo,
    this.autor,
    this.capaUrl,
    this.descricao,
    this.paginas,
    this.genero,
    this.avaliacao,
  });

  static const routeName = '/info-livro';

  @override
  State<InfoLivroPage> createState() => _InfoLivroPageState();
}

class _InfoLivroPageState extends State<InfoLivroPage> {
  String _statusLeitura = 'queroLer';
  bool _isFavorito = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme,
      appBar: AppBar(
        title: Text(
          widget.titulo ?? 'Detalhes do Livro',
          style: const TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: MyColors.abobora,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorito ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorito = !_isFavorito;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorito ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa e informações principais
            Container(
              decoration: BoxDecoration(
                color: MyColors.abobora.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capa do livro
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.capaUrl != null && widget.capaUrl!.isNotEmpty
                            ? Image.network(
                          widget.capaUrl!,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: MyColors.creme,
                            child: const Icon(
                              Icons.book,
                              size: 50,
                            ),
                          ),
                        )
                            : Container(
                          color: MyColors.creme,
                          child: const Icon(
                            Icons.book,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Informações básicas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titulo ?? 'Título não informado',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlayfairDisplay',
                              color: MyColors.marrom,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: MyColors.marromClaro,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.autor ?? 'Autor não informado',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: MyColors.marromClaro,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (widget.genero != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 16,
                                  color: MyColors.marromClaro,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.genero!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: MyColors.marromClaro,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          if (widget.paginas != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  size: 16,
                                  color: MyColors.marromClaro,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.paginas} páginas',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: MyColors.marromClaro,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          // Avaliação
                          if (widget.avaliacao != null)
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                      (index) => Icon(
                                    index < widget.avaliacao!.floor()
                                        ? Icons.star
                                        : index < widget.avaliacao!
                                        ? Icons.star_half
                                        : Icons.star_border,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.avaliacao!.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.marrom,
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
            ),

            const SizedBox(height: 24),

            // Status de leitura
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status de Leitura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: MyColors.marrom,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusButton('Quero Ler', 'queroLer', Icons.bookmark_border),
                      const SizedBox(width: 12),
                      _buildStatusButton('Lendo', 'lendo', Icons.menu_book),
                      const SizedBox(width: 12),
                      _buildStatusButton('Lido', 'lido', Icons.check_circle),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sinopse/Descrição
            if (widget.descricao != null && widget.descricao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sinopse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                        color: MyColors.marrom,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.descricao!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: MyColors.marromClaro,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Botões de ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _salvarProgresso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.abobora,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Salvar Progresso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MyColors.marrom,
                      side: BorderSide(color: MyColors.marromClaro),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status, IconData icon) {
    final isSelected = _statusLeitura == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _statusLeitura = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? MyColors.abobora : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? MyColors.abobora : MyColors.marromClaro,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : MyColors.marromClaro,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : MyColors.marromClaro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvarProgresso() async {
    setState(() {
      _isLoading = true;
    });

    // Simular delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status atualizado para "${_getStatusTexto()}"'),
          backgroundColor: Colors.green,
        ),
      );

      // Voltar para página anterior após salvar
      Navigator.pop(context);
    }
  }

  String _getStatusTexto() {
    switch (_statusLeitura) {
      case 'lendo':
        return 'Lendo';
      case 'lido':
        return 'Lido';
      default:
        return 'Quero Ler';
    }
  }
}