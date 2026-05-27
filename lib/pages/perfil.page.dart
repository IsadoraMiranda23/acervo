import 'dart:io';
import 'package:acervo/components/card_atualizacao.component.dart';
import 'package:acervo/components/carrossel.progresso.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:acervo/services/auth_service.dart';
import 'package:acervo/services/upload_service.dart';
import '../my_colors.dart';
import 'biblioteca.page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, required String nomeUsuario, required String avatarUrl});
  static const routeName = '/perfil';

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final AuthService _auth = AuthService();
  final UploadService _upload = UploadService();

  String _nomeUsuario = '';
  String _avatarUrl = '';
  String _bio = '';
  int _livrosLidos = 0;
  int _paginasLidas = 0;
  int _diasSeguidos = 0;
  bool _isLoading = true;
  bool _isUploading = false;

  final List<Map<String, dynamic>> _livrosEmAndamento = [
    {
      'nomeLivro': 'O Guia do Mochileiro das Galáxias',
      'imagemUrl': 'https://m.media-amazon.com/images/I/51cUQ4WqepL.jpg',
      'progressoPorcentagem': 65,
      'paginasLidas': 150,
      'paginasTotais': 328,
    },
    {
      'nomeLivro': '1984',
      'imagemUrl': 'https://m.media-amazon.com/images/I/71kxa1-0mfL.jpg',
      'progressoPorcentagem': 42,
      'paginasLidas': 137,
      'paginasTotais': 326,
    },
    {
      'nomeLivro': 'Dom Casmurro',
      'imagemUrl': 'https://m.media-amazon.com/images/I/81XxXxXxXxL.jpg',
      'progressoPorcentagem': 80,
      'paginasLidas': 400,
      'paginasTotais': 500,
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  Future<void> _carregarDadosPerfil() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = _auth.currentUserId;

      print('Carregando perfil para userId: $userId');

      if (userId != null) {
        final response = await supabase
            .from('Usuarios')
            .select()
            .eq('ID_Usuario', userId);

        print('Resposta: ${response.length} registros');

        if (response.isNotEmpty) {
          final userData = response[0];
          setState(() {
            _nomeUsuario = userData['Nome'] ?? _auth.currentUserEmail?.split('@').first ?? 'Usuário';
            _avatarUrl = userData['Avatar_URL'] ?? '';
            _bio = userData['Bio'] ?? '';
          });
          print('Dados carregados: nome=$_nomeUsuario, avatar=${_avatarUrl.isNotEmpty}');
        } else {
          print('Usuário não encontrado na tabela');
          setState(() {
            _nomeUsuario = _auth.currentUserEmail?.split('@').first ?? 'Usuário';
          });
        }
      }

      _livrosLidos = 12;
      _paginasLidas = 3450;
      _diasSeguidos = 15;

    } catch (e) {
      print('Erro ao carregar perfil: $e');
      setState(() {
        _nomeUsuario = _auth.currentUserEmail?.split('@').first ?? 'Usuário';
        _avatarUrl = '';
        _bio = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _escolherImagem() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: MyColors.abobora),
                title: const Text('Escolher da galeria'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _upload.pickImageFromGallery();
                  if (image != null) {
                    await _fazerUploadImagem(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: MyColors.abobora),
                title: const Text('Tirar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _upload.pickImageFromCamera();
                  if (image != null) {
                    await _fazerUploadImagem(image);
                  }
                },
              ),
              if (_avatarUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _removerFoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fazerUploadImagem(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;

      final imageUrl = await _upload.uploadProfileImage(imageFile, userId);

      if (imageUrl != null) {
        final supabase = Supabase.instance.client;
        await supabase
            .from('Usuarios')
            .update({'Avatar_URL': imageUrl})
            .eq('ID_Usuario', userId);

        setState(() {
          _avatarUrl = imageUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Falha no upload');
      }
    } catch (e) {
      print('Erro ao fazer upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _removerFoto() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;

      final supabase = Supabase.instance.client;
      await supabase
          .from('Usuarios')
          .update({'Avatar_URL': null})
          .eq('ID_Usuario', userId);

      setState(() {
        _avatarUrl = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erro ao remover foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: MyColors.creme,
        body: Center(
          child: CircularProgressIndicator(color: MyColors.abobora),
        ),
      );
    }

    return Container(
      color: MyColors.creme,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Avatar
            // No método build, substitua a seção do Avatar por esta:

// Avatar com botão de editar
            Center(
              child: GestureDetector(
                onTap: _isUploading ? null : _escolherImagem,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Foto de perfil
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.creme,
                        border: Border.all(color: MyColors.abobora, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _avatarUrl.isNotEmpty
                            ? Image.network(
                          _avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 100,
                              color: MyColors.abobora,
                            );
                          },
                        )
                            : Icon(Icons.person, size: 100, color: MyColors.abobora),
                      ),
                    ),

                    // Overlay escuro quando passa o mouse (opcional)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(_isUploading ? 150 : 0),
                        ),
                      ),
                    ),

                    // Ícone de câmera para editar
                    if (!_isUploading)
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MyColors.abobora,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Loading indicator
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nome do usuário
            Center(
              child: Text(
                _nomeUsuario,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: MyColors.marromMedio,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bio do usuário
            if (_bio.isNotEmpty)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _bio,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColors.marromClaro,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Cards de estatísticas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 50,
                            color: MyColors.abobora,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _livrosLidos.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromMedio,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "LIVROS LIDOS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromClaro,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.description,
                            size: 50,
                            color: MyColors.abobora,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _paginasLidas.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromMedio,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "PÁGINAS LIDAS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MyColors.marromClaro,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: MyColors.abobora,
                  borderRadius: BorderRadius.circular(45),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.abobora.withAlpha(60),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 55,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _diasSeguidos.toString(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: MyColors.creme,
                          ),
                        ),
                        const Text(
                          "DIAS SEGUIDOS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.creme,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Leituras atuais",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                        fontStyle: FontStyle.italic,
                        color: MyColors.preto,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.push(BibliotecaPage.routeName);
                    },
                    child: const Text("Ver tudo "),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            CarrosselProgresso(
              livros: _livrosEmAndamento,
            ),

            const SizedBox(height: 30),

            const Text("Atualizações recentes"),

            CardAtualizacaoComponent(
              nomeLivro: "O Guia do Mochileiro das Galáxias",
              nomeAutor: "Douglas Adams",
              imagemUrl: "https://exemplo.com/capa.jpg",
              estaLendo: true,
              progressoPorcentagem: 65,
              descricao: "Estou adorando esse livro! A mistura de humor com ficção científica é sensacional. Recomendo demais para quem gosta de uma leitura leve e criativa.",
              dataAtualizacao: DateTime.now().subtract(const Duration(days: 2)),
              onTap: () {
                print("Card clicado!");
              },
            ),

            CardAtualizacaoComponent(
              nomeLivro: "1984",
              nomeAutor: "George Orwell",
              imagemUrl: "https://exemplo.com/capa2.jpg",
              estaLendo: false,
              avaliacao: 4.5,
              descricao: "Uma obra-prima! Terminei esse livro impactado. A crítica social é atemporal e assustadoramente atual. Leitura obrigatória para todos.",
              dataAtualizacao: DateTime.now().subtract(const Duration(days: 15)),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildGeneroChip("Ficção Científica"),
                    _buildGeneroChip("Fantasia"),
                    _buildGeneroChip("Romance"),
                    _buildGeneroChip("Aventura"),
                    _buildGeneroChip("Suspense"),
                    _buildGeneroChip("Terror"),
                    _buildGeneroChip("Biografia"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroChip(String genero) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: MyColors.creme,
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: MyColors.abobora.withAlpha(80), width: 1.5),
      ),
      child: Text(
        genero,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: MyColors.marromMedio,
        ),
      ),
    );
  }
}