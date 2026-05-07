import 'package:acervo/my_colors.dart';
import 'package:flutter/material.dart';

class LivroBiblioteca {
  final String id;
  final String titulo;
  final String autor;
  final String? capaUrl;
  final String status;
  late final bool isFavorito;

  LivroBiblioteca({
    required this.id,
    required this.titulo,
    required this.autor,
    this.capaUrl,
    required this.status,
    this.isFavorito = false,
  });
}

class BibliotecaPage extends StatefulWidget {
  const BibliotecaPage({super.key});
  static const routeName = '/Biblioteca';

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  String _filtroSelecionado = 'Todos';
  List<LivroBiblioteca> _todosLivros = [];
  List<LivroBiblioteca> _livrosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  void _carregarLivros() {
    _todosLivros = [
      LivroBiblioteca(
        id: '1',
        titulo: 'O Poder do Hábito',
        autor: 'Charles Duhigg',
        capaUrl: 'https://m.media-amazon.com/images/I/81YkqllaFdL._AC_UF1000,1000_QL80_.jpg',
        status: 'lendo',
        isFavorito: true,
      ),
      LivroBiblioteca(
        id: '2',
        titulo: 'Como Fazer Amigos e Influenciar Pessoas',
        autor: 'Dale Carnegie',
        capaUrl: 'https://m.media-amazon.com/images/I/81S0-H8jz5L._AC_UF1000,1000_QL80_.jpg',
        status: 'lido',
        isFavorito: true,
      ),
      LivroBiblioteca(
        id: '3',
        titulo: 'Rápido e Devagar',
        autor: 'Daniel Kahneman',
        capaUrl: 'https://m.media-amazon.com/images/I/81P0GuZaqgL._AC_UF1000,1000_QL80_.jpg',
        status: 'queroLer',
        isFavorito: false,
      ),
      LivroBiblioteca(
        id: '4',
        titulo: 'Mindset: A Nova Psicologia do Sucesso',
        autor: 'Carol S. Dweck',
        capaUrl: 'https://m.media-amazon.com/images/I/81YcWvJ1w0L._AC_UF1000,1000_QL80_.jpg',
        status: 'lido',
        isFavorito: false,
      ),
      LivroBiblioteca(
        id: '5',
        titulo: 'A Arte da Guerra',
        autor: 'Sun Tzu',
        capaUrl: 'https://m.media-amazon.com/images/I/71cGt9pLr-L._AC_UF1000,1000_QL80_.jpg',
        status: 'queroLer',
        isFavorito: true,
      ),
    ];
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    setState(() {
      switch (_filtroSelecionado) {
        case 'Todos':
          _livrosFiltrados = List.from(_todosLivros);
          break;
        case 'Lendo':
          _livrosFiltrados = _todosLivros.where((livro) => livro.status == 'lendo').toList();
          break;
        case 'Lidos':
          _livrosFiltrados = _todosLivros.where((livro) => livro.status == 'lido').toList();
          break;
        case 'Quero Ler':
          _livrosFiltrados = _todosLivros.where((livro) => livro.status == 'queroLer').toList();
          break;
        case 'Favoritos':
          _livrosFiltrados = _todosLivros.where((livro) => livro.isFavorito).toList();
          break;
        default:
          _livrosFiltrados = List.from(_todosLivros);
      }
    });
  }

  void _alternarFavorito(LivroBiblioteca livro) {
    setState(() {
      final index = _todosLivros.indexWhere((l) => l.id == livro.id);
      if (index != -1) {
        _todosLivros[index].isFavorito = !_todosLivros[index].isFavorito;
      }
      _aplicarFiltro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme,
      appBar: AppBar(
        title: const Text('Biblioteca'),
        backgroundColor: MyColors.abobora,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Explorar livros')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SUA BIBLIOTECA PARTICULAR",
                  style: TextStyle(color: MyColors.abobora, fontSize: 14),
                ),
                Text(
                  "Minha Coleção",
                  style: TextStyle(
                    color: MyColors.marrom,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filtroChip('Todos'),
                _filtroChip('Lendo'),
                _filtroChip('Lidos'),
                _filtroChip('Quero Ler'),
                _filtroChip('Favoritos'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _livrosFiltrados.isEmpty
                ? const Center(
              child: Text(
                'Nenhum livro encontrado.\nAdicione livros à sua coleção!',
                textAlign: TextAlign.center,
                style: TextStyle(color: MyColors.marromClaro),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _livrosFiltrados.length,
              itemBuilder: (context, index) {
                final livro = _livrosFiltrados[index];
                return _bookCard(livro);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String label) {
    final isSelected = _filtroSelecionado == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _filtroSelecionado = label;
              _aplicarFiltro();
            });
          }
        },
        backgroundColor: Colors.white,
        selectedColor: MyColors.abobora.withAlpha(30),
        checkmarkColor: MyColors.abobora,
        labelStyle: TextStyle(
          color: isSelected ? MyColors.abobora : MyColors.marromClaro,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? MyColors.abobora : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _bookCard(LivroBiblioteca livro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 80,
              height: 110,
              color: MyColors.creme,
              child: livro.capaUrl != null && livro.capaUrl!.isNotEmpty
                  ? Image.network(
                livro.capaUrl!,
                width: 80,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.book,
                  size: 40,
                  color: MyColors.abobora,
                ),
              )
                  : Icon(Icons.book, size: 40, color: MyColors.abobora),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livro.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.preto,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    livro.autor,
                    style: TextStyle(
                      fontSize: 13,
                      color: MyColors.marromClaro,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(livro.status).withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusTexto(livro.status),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(livro.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          livro.isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: livro.isFavorito ? Colors.red : MyColors.marromClaro,
                          size: 20,
                        ),
                        onPressed: () => _alternarFavorito(livro),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'lendo':
        return Colors.blue;
      case 'lido':
        return Colors.green;
      case 'queroLer':
        return MyColors.abobora;
      default:
        return MyColors.marromClaro;
    }
  }

  String _getStatusTexto(String status) {
    switch (status) {
      case 'lendo':
        return 'Lendo';
      case 'lido':
        return 'Lido';
      case 'queroLer':
        return 'Quero ler';
      default:
        return status;
    }
  }
}