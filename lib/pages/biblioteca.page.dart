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
      LivroBiblioteca(
        id: '6',
        titulo: 'O Pequeno Príncipe',
        autor: 'Antoine de Saint-Exupéry',
        capaUrl: 'https://m.media-amazon.com/images/I/81AOzrM1BHL._AC_UF1000,1000_QL80_.jpg',
        status: 'lendo',
        isFavorito: false,
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
        title: const Text(
          'Biblioteca',
          style: TextStyle(
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
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscar livros')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: MyColors.abobora.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SUA BIBLIOTECA PARTICULAR",
                  style: TextStyle(
                    color: MyColors.abobora,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Minha Coleção",
                  style: TextStyle(
                    color: MyColors.marrom,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_livrosFiltrados.length} livros",
                  style: TextStyle(
                    color: MyColors.marromClaro,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 80,
                    color: MyColors.marromClaro,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum livro encontrado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MyColors.marromMedio,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicione livros à sua coleção!',
                    style: TextStyle(
                      color: MyColors.marromClaro,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 colunas para cards maiores e mais bonitos
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              itemCount: _livrosFiltrados.length,
              itemBuilder: (context, index) {
                final livro = _livrosFiltrados[index];
                return _bookCardGrid(livro);
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
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? MyColors.abobora : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _bookCardGrid(LivroBiblioteca livro) {
    return GestureDetector(
      onTap: () {
        print('Livro clicado: ${livro.titulo}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Capa do livro com efeito de sombra
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    color: MyColors.creme,
                    child: livro.capaUrl != null && livro.capaUrl!.isNotEmpty
                        ? Image.network(
                      livro.capaUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: MyColors.creme,
                        child: Icon(
                          Icons.book,
                          size: 60,
                          color: MyColors.abobora.withAlpha(100),
                        ),
                      ),
                    )
                        : Container(
                      color: MyColors.creme,
                      child: Icon(
                        Icons.book,
                        size: 60,
                        color: MyColors.abobora.withAlpha(100),
                      ),
                    ),
                  ),
                  // Badge de status no canto superior direito
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(livro.status),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusTexto(livro.status),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informações do livro
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    livro.titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: MyColors.preto,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: MyColors.marromClaro,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          livro.autor,
                          style: TextStyle(
                            fontSize: 11,
                            color: MyColors.marromClaro,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barra de progresso para livros em leitura
                  if (livro.status == 'lendo') ...[
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: MyColors.marromClaro.withAlpha(30),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 0.65, // Progresso exemplo
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.abobora,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '65% concluído',
                      style: TextStyle(
                        fontSize: 9,
                        color: MyColors.abobora,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
        return 'LENDO';
      case 'lido':
        return 'LIDO';
      case 'queroLer':
        return 'QUERO LER';
      default:
        return status.toUpperCase();
    }
  }
}