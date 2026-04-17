import 'package:acervo/components/card_indicacao_book.component.dart';
import 'package:acervo/components/carrossel.dart';
import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart'; // Importe suas cores

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.creme,
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar livros, autores...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: MyColors.abobora,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: MyColors.preto,
                      ),
                      children: const [
                        TextSpan(text: 'Tendências do \n'),
                        TextSpan(text: 'momento'),
                      ],
                    ),
                  ),
                ),
                Text("ver mais.."
                , style: TextStyle(
                    fontSize: 16
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Carrossel(
              livros: [
                {
                  'nomeLivro': 'Dom Casmurro',
                  'nomeAutor': 'Machado de Assis',
                  'imagemUrl': '',
                },
                {
                  'nomeLivro': 'O Alquimista',
                  'nomeAutor': 'Paulo Coelho',
                  'imagemUrl': '',
                },
                {
                  'nomeLivro': '1984',
                  'nomeAutor': 'George Orwell',
                  'imagemUrl': '',
                },
                {
                  'nomeLivro': 'O Pequeno Príncipe',
                  'nomeAutor': 'Antoine de Saint-Exupéry',
                  'imagemUrl': '',
                },
                {
                  'nomeLivro': 'A Culpa é das Estrelas',
                  'nomeAutor': 'John Green',
                  'imagemUrl': '',
                },
                {
                  'nomeLivro': 'Harry Potter',
                  'nomeAutor': 'J.K. Rowling',
                  'imagemUrl': '',
                },
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Busque por livros ou autores',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {

      return _buildSearchResults();
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: MyColors.abobora.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.book,
                color: MyColors.abobora,
              ),
            ),
            title: Text(
              'Resultado da busca $_searchQuery $index',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Autor do livro'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {

              },
            ),
            onTap: () {

            },
          ),
        );
      },
    );
  }
}