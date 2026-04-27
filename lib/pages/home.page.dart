import 'package:acervo/my_colors.dart';
import 'package:flutter/material.dart';

import 'package:acervo/pages/explorar.page.dart';
import 'package:acervo/pages/pesquisa.page.dart';  // Crie depois
import 'package:acervo/pages/biblioteca.page.dart';     // Crie depois
import 'package:acervo/pages/perfil.page.dart';    // Crie depois

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/Home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _paginas = [
    const ExplorarPage(),
    const PesquisaPage(),
    const BibliotecaPage(),
    const PerfilPage(nomeUsuario: ' Isadora Miranda', avatarUrl: '',),
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
            fontFamily: 'Newheader',
            color: MyColors.abobora,
          ),
        ),
      ),


      body: _paginas[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: MyColors.creme,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:  MyColors.abobora,
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
            label: "Biblioteca",
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