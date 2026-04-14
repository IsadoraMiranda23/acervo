import 'package:acervo/my_colors.dart';
import 'package:flutter/material.dart';

// Importe suas páginas aqui
import 'package:acervo/pages/explorar.page.dart';
import 'package:acervo/pages/pesquisa.page.dart';  // Crie depois
import 'package:acervo/pages/lendo.page.dart';     // Crie depois
import 'package:acervo/pages/perfil.page.dart';    // Crie depois

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Lista de páginas que serão exibidas
  final List<Widget> _paginas = [
    const ExplorarPage(),   // Índice 0
    const PesquisaPage(),   // Índice 1 - Crie esta página
    const LendoPage(),      // Índice 2 - Crie esta página
    const PerfilPage(),     // Índice 3 - Crie esta página
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme,
      appBar: AppBar(
        backgroundColor: MyColors.creme,
        leading: IconButton(
          icon: Icon(
            Icons.menu_book,
            color: MyColors.abobora,
          ),
          onPressed: () {},
        ),
        title: Text(
          "ACERVO",
          style: TextStyle(
            fontFamily: 'newheader',
            color: MyColors.abobora,
          ),
        ),
      ),

      // ✅ Aqui está a mágica - o body muda conforme o índice
      body: _paginas[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: MyColors.creme,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: MyColors.marromClaro,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: "Explorar",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Pesquisa",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Lendo",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}