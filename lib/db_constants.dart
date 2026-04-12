// Gabarito do arquivo de constantes do banco de dados. 

class DbTables {
  static const String livros = 'Livros';
  static const String resenhas = 'Resenhas';
  static const String usuarios = 'Usuarios';
}

class DbUsuarios {
  static const String id = 'ID_Usuario'; 
  static const String nome = 'Nome'; 
  static const String username = 'Username'; 
  static const String avatarUrl ='Avatar_URL'; 
}

class DbLivros {
  static const String id = 'ID_Livro';
  static const String titulo = 'Titulo';
  static const String autor = 'Autor';
  static const String ano = 'Ano';
  static const String editora = 'Editora';
  static const String paginas = 'Total_paginas';
  static const String capaUrl = 'Capa_URL';
}

class DbResenhas {
  static const String id = 'ID_Resenha';
  static const String idLivro = 'ID_Livro'; 
  static const String idUsuario = 'ID_Usuario'; 
  static const String nota = 'Nota'; 
  static const String texto = 'Texto_Resenha';
  static const String data = 'Data_Publicacao';
}
