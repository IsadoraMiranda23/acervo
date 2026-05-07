import 'package:flutter/material.dart';
import 'package:acervo/components/card_atualizacao_navegar.component.dart';

import '../my_colors.dart';

class NavegarPage extends StatefulWidget {
  const NavegarPage({super.key});

  @override
  State<NavegarPage> createState() => _NavegarPageState();
}

class _NavegarPageState extends State<NavegarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme,
      body: ListView(
        children: [
          CardAtualizacaoNavegarComponent(
            nomeUsuario: "Ana Carolina",
            fotoUsuarioUrl: "https://exemplo.com/foto-ana.jpg", // opcional
            nomeLivro: "O Poder do Hábito",
            nomeAutor: "Charles Duhigg",
            imagemUrl: "https://exemplo.com/capa-poder-habito.jpg",
            estaLendo: true,
            progressoPorcentagem: 65,
            descricao:
            "Estou adorando a forma como o autor explica a ciência por trás dos hábitos. Muito prático!",
            dataAtualizacao: DateTime.now().subtract(const Duration(hours: 5)),
            onTap: () {
              print("Card clicado!");
            },
          ),

          CardAtualizacaoNavegarComponent(
            nomeUsuario: "Ricardo Mendes",

            nomeLivro: "1984",
            nomeAutor: "George Orwell",
            estaLendo: false,
            avaliacao: 5.0,
            descricao: "Uma obra-prima atemporal. Leitura obrigatória!",
            dataAtualizacao: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    );
  }
}