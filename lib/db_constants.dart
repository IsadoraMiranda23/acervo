class DbTables {
  static const String livros = 'Livros';
  static const String resenhas = 'Resenhas';
  static const String usuarios = 'Usuarios';
  static const String seguidores = 'Seguidores';
  static const String livrosLidos = 'Livros_Lidos';
  // CORREÇÃO 1: Adicionado o "Db" no início para bater com o Supabase
  static const String comentarios = 'DbComentarios';
}

class DbComentarios {
  static const String idComentario = 'ID_Comentario';
  // CORREÇÃO 2: Alterado para "r" minúsculo para bater com o Supabase
  static const String idResenha = 'ID_resenha';
  static const String idUsuario = 'ID_Usuario';
  static const String texto = 'Texto';
  static const String data = 'Data';
}

class DbUsuarios {
  static const String id = 'ID_Usuario';
  static const String nome = 'Nome';
  static const String username = 'Username';
  static const String avatarUrl = 'Avatar_URL';
  static const String email = 'Email';
  static const String dataNascimento = 'Data_Nascimento';
  static const String bio = 'Bio';
}

class DbLivros {
  static const String id = 'ID_Livro';
  static const String titulo = 'Titulo';
  static const String autor = 'Autor';
  static const String genero = 'Genero';
  static const String anoPublicacao = 'Ano_Publicacao';
  static const String descricao = 'Descricao';
  static const String avaliacao = 'Avaliacao';
  static const String isbn = 'ISBN';
  static const String capaUrl = 'Capa_URL';
  static const String idioma = 'Idioma';
}

class DbResenhas {
  static const String idLivro = 'ID_Livro';
  static const String idUsuario = 'ID_Usuario';
  static const String comentario = 'Comentario';
  static const String dataResenha = 'Data';
  static const String avaliacaoResenha = 'Avaliacao_Resenha';
  static const String ritmo = 'Ritmo';
  static const String idResenha = 'ID_resenha';
}

class DbSeguidores {
  static const String followerId = 'Follower_ID';
  static const String followingId = 'Following_ID';
}

class DbLivrosLidos {
  static const String idUsuario = 'ID_Usuario';
  static const String idLivro = 'ID_Livro';
  static const String status = 'Status';
}
