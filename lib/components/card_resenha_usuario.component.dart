import 'package:acervo/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:acervo/db_constants.dart';

class CardResenhaUsuarioComponent extends StatefulWidget {
  // Parâmetros recebidos da página anterior (Explorar)
  final int idResenha;
  final String nomeUsuario;
  final String avatarUrl;
  final String tituloLivro;
  final String autorLivro;
  final String resenha;
  final double avaliacao; // Pode ser 4.5, 5.0, etc.
  final DateTime dataResenha;

  // Callbacks (Funções passadas por quem chamou o card, caso precisem reagir)
  final VoidCallback? onLike;
  final VoidCallback? onComentar;
  final VoidCallback? onCompartilhar;

  const CardResenhaUsuarioComponent({
    super.key,
    required this.idResenha,
    required this.nomeUsuario,
    required this.tituloLivro,
    required this.autorLivro,
    required this.resenha,
    required this.avaliacao,
    required this.dataResenha,
    this.avatarUrl = '',
    this.onLike,
    this.onComentar,
    this.onCompartilhar,
  });

  @override
  State<CardResenhaUsuarioComponent> createState() =>
      _CardResenhaUsuarioComponentState();
}

class _CardResenhaUsuarioComponentState
    extends State<CardResenhaUsuarioComponent> {
  // [ESTADO DE AUTENTICAÇÃO MOCKADO]
  // Em um app real, pegaríamos o ID do usuário através da sessão do Supabase Auth.
  // Aqui ficou fixo para testar as validações de exclusão e edição.
  final int meuIdLogado = 1;

  // [VARIÁVEIS DE ESTADO VISUAL]
  bool _expandido =
      false; // Controla se o texto da resenha está cortado ou inteiro
  bool _curtido =
      false; // Controla a cor do coração da resenha (Não do comentário)
  int _numeroCurtidas = 0; // Contador de likes da resenha
  int _qtdComentarios = 0; // Controlador de quantos comentários existem

  // [CONTROLES DO CAMPO DE TEXTO]
  bool _mostrandoCampoComentario = false; // Mostra/Esconde a barrinha inline
  final TextEditingController _comentarioController = TextEditingController();

  // CICLO DE VIDA DO WIDGET

  @override
  void initState() {
    super.initState();
    _numeroCurtidas = 0; // Zera as curtidas ao nascer
    // Assim que o card aparece na tela, ele pede pro banco contar os comentários
    _buscarContagemComentarios();
  }

  @override
  void dispose() {
    // PREVENÇÃO DE MEMORY LEAK: Sempre que abrir um 'Controller', deve-se fechá-lo
    // quando o widget for destruído (ex: ao mudar de tela).
    _comentarioController.dispose();
    super.dispose();
  }

  // LÓGICA DE BANCO DE DADOS (SUPABASE CRUD)

  // READ (Ler quantidade): Busca leve só para preencher o "Ver todos os X comentários"
  Future<void> _buscarContagemComentarios() async {
    try {
      final res = await Supabase.instance.client
          .from(DbTables.comentarios)
          .select(
            DbComentarios.idComentario,
          ) // Puxar apenas o ID economiza banda de rede
          .eq(DbComentarios.idResenha, widget.idResenha); // Filtro (WHERE)

      if (mounted) {
        setState(() {
          _qtdComentarios =
              res.length; // O tamanho da lista é o número de comentários
        });
      }
    } catch (e) {
      debugPrint("Erro ao contar comentários: $e");
    }
  }

  // DELETE (Apagar comentário)
  Future<void> _deletarComentario(int idCom) async {
    try {
      // 1. Vai na internet e apaga
      await Supabase.instance.client
          .from(DbTables.comentarios)
          .delete()
          .eq(DbComentarios.idComentario, idCom);

      if (!mounted) return;

      // 2. Atualiza o número de comentários
      setState(() {
        _qtdComentarios--;
      });

      // 3. Apenas fecha a gaveta com uma animação suave. Fim do lag.
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Comentário removido com sucesso',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: MyColors.marrom, // Cor sóbria da sua paleta
          behavior: SnackBarBehavior.floating, // Faz o popup flutuar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20), // Afasta das bordas da tela
        ),
      );
    } catch (e) {
      debugPrint("Erro ao deletar comentário: $e");
    }
  }

  Future<void> _curtirComentario(int idCom) async {
    try {
      final checagem = await Supabase.instance.client
          .from('Curtidas_Comentarios')
          .select()
          .eq('id_comentario', idCom)
          .eq('id_usuario', meuIdLogado);

      if (checagem.isEmpty) {
        await Supabase.instance.client.from('Curtidas_Comentarios').insert({
          'id_comentario': idCom,
          'id_usuario': meuIdLogado,
        });
      } else {
        await Supabase.instance.client
            .from('Curtidas_Comentarios')
            .delete()
            .eq('id_comentario', idCom)
            .eq('id_usuario', meuIdLogado);
      }

      if (!mounted) return;

      // Fecha a gaveta suavemente sem tentar reabrir
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Erro ao processar curtida: $e");
    }
  }

  // FUNÇÕES DE LÓGICA VISUAL E FORMATAÇÃO

  // Converte DateTime do formato de máquina para leitura humana fluida
  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) return 'agora';
        return '${difference.inMinutes} minutos atrás';
      }
      return '${difference.inHours} horas atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} semanas atrás'; // Divisão inteira
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

  // Lógica Matemática para renderizar estrelas cheias e meias estrelas
  Widget _buildEstrelas() {
    List<Widget> estrelas = [];
    int estrelasCheias = widget.avaliacao
        .floor(); // Arredonda para baixo (ex: 4.8 vira 4)
    bool temMeiaEstrela = widget.avaliacao - estrelasCheias >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < estrelasCheias) {
        estrelas.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == estrelasCheias && temMeiaEstrela) {
        estrelas.add(
          const Icon(Icons.star_half, color: Colors.amber, size: 18),
        );
      } else {
        estrelas.add(
          const Icon(Icons.star_border, color: Colors.amber, size: 18),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: estrelas);
  }

  // Padronização dos botões maiores do Card (Rodapé)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color ?? MyColors.marromClaro),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? MyColors.marromClaro,
            ),
          ),
        ],
      ),
    );
  }

  // Padronização dos botões menores de dentro da gaveta (Micro-Interações)
  Widget _botaoMicroAcao({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color ?? MyColors.marromClaro),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? MyColors.marromClaro,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CONSTRUTOR PRINCIPAL DA TELA (ÁRVORE DE WIDGETS)

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MyColors.branco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // AnimatedSize suaviza o layout quando a resenha expande ou o campo inline abre
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [CABEÇALHO] - Foto, Nome do Usuário e Informações do Livro
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColors.creme,
                      border: Border.all(color: MyColors.abobora, width: 2),
                    ),
                    child: ClipOval(
                      // Renderização condicional para tratar erro se a URL da imagem falhar
                      child: widget.avatarUrl.isNotEmpty
                          ? Image.network(
                              widget.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: MyColors.abobora,
                                  ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 30,
                              color: MyColors.abobora,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nomeUsuario,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.preto,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.tituloLivro,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MyColors.abobora,
                          ),
                        ),
                        Text(
                          widget.autorLivro,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MyColors.marromClaro,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildEstrelas(),
                ],
              ),
            ),

            Container(
              height: 1,
              color: MyColors.creme,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // [CORPO DO TEXTO] - O texto da resenha com controle de colapso
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Troca de estado suave entre o texto cortado (maxLines: 5) e o completo
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _expandido
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      widget.resenha,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: MyColors.preto,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      widget.resenha,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: MyColors.preto,
                      ),
                    ),
                  ),
                  // Renderiza o botão "Ver mais" apenas se o texto for muito grande
                  if (_resenhaPrecisaExpandir())
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _expandido = !_expandido),
                        style: TextButton.styleFrom(
                          foregroundColor: MyColors.abobora,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          _expandido ? 'Ver menos' : 'Ver mais',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // [LINK DA GAVETA] - Só mostra se houverem comentários
            if (_qtdComentarios > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: GestureDetector(
                  onTap: () => _abrirGavetaComentarios(context),
                  child: Text(
                    'Ver todos os $_qtdComentarios comentários',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MyColors.marromClaro.withAlpha(200),
                    ),
                  ),
                ),
              ),

            // [RODAPÉ] - Ações principais do Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: MyColors.marromClaro.withAlpha(150),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatarData(widget.dataResenha),
                    style: TextStyle(
                      fontSize: 12,
                      color: MyColors.marromClaro.withAlpha(150),
                    ),
                  ),
                  const Spacer(),
                  _buildActionButton(
                    icon: _curtido ? Icons.favorite : Icons.favorite_border,
                    label: _numeroCurtidas.toString(),
                    onTap: () {
                      setState(() {
                        _curtido = !_curtido;
                        _numeroCurtidas += _curtido ? 1 : -1;
                      });
                      widget.onLike?.call();
                    },
                    color: _curtido ? Colors.red : MyColors.marromClaro,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: 'Comentar',
                    onTap: () {
                      // Oculta/Exibe a barrinha de texto
                      setState(
                        () => _mostrandoCampoComentario =
                            !_mostrandoCampoComentario,
                      );
                      widget.onComentar?.call();
                    },
                    color: _mostrandoCampoComentario
                        ? MyColors.abobora
                        : MyColors.marromClaro,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Compartilhar',
                    onTap: widget.onCompartilhar,
                  ),
                ],
              ),
            ),

            // [BARRINHA INLINE] - Campo para escrever comentário novo
            if (_mostrandoCampoComentario)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: MyColors.creme.withAlpha(100),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: MyColors.creme),
                        ),
                        child: TextField(
                          controller: _comentarioController,
                          decoration: InputDecoration(
                            hintText: 'Adicione um comentário...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: MyColors.marromClaro.withAlpha(150),
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: MyColors.abobora,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final textoDigitado = _comentarioController.text
                              .trim();
                          if (textoDigitado.isNotEmpty) {
                            final textoParaSalvar = textoDigitado;

                            // Lógica Otimista: Limpa UI primeiro para o usuário sentir resposta imediata
                            _comentarioController.clear();
                            setState(() => _mostrandoCampoComentario = false);

                            try {
                              // INSERT: Salva o novo registro na tabela
                              await Supabase.instance.client
                                  .from(DbTables.comentarios)
                                  .insert({
                                    DbComentarios.idResenha: widget.idResenha,
                                    DbComentarios.idUsuario: meuIdLogado,
                                    DbComentarios.texto: textoParaSalvar,
                                  });

                              setState(() => _qtdComentarios++);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Seu comentário foi publicado!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: MyColors
                                        .abobora, // A cor principal do Acervo
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(20),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      textColor: MyColors.creme,
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint("Erro ao salvar comentário: $e");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // COMPONENTES AUXILIARES E GAVETA DE COMENTÁRIOS (BOTTOM SHEET)
  // ============================================================================

  // Verifica matematicamente se o texto cabe em 5 linhas. Se exceder, pedimos
  // para renderizar o botão "Ver mais".
  bool _resenhaPrecisaExpandir() {
    final textSpan = TextSpan(
      text: widget.resenha,
      style: const TextStyle(fontSize: 14),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 5,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      maxWidth: MediaQuery.of(context).size.width - 32,
    ); // 32 = padding horizontal
    return textPainter.didExceedMaxLines;
  }

  void _abrirGavetaComentarios(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que a gaveta suba além do limite padrão
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.65, // Ocupa 65% da tela
          decoration: const BoxDecoration(
            color: MyColors.branco,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Elemento visual de 'Puxador' (Notch)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Comentários',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),

              // FutureBuilder controla a requisição Assíncrona, mostrando um Loader
              // enquanto a internet está buscando os dados.
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  // QUERY RELACIONAL MÚLTIPLA: Traz dados da tabela principal e de duas Foreign Keys de uma vez
                  future: Supabase.instance.client
                      .from(DbTables.comentarios)
                      .select(
                        '*, ${DbTables.usuarios}(${DbUsuarios.nome}, ${DbUsuarios.avatarUrl}), Curtidas_Comentarios(id_usuario)',
                      )
                      .eq(DbComentarios.idResenha, widget.idResenha)
                      .order(DbComentarios.data, ascending: false),
                  builder: (context, snapshot) {
                    // Estado 1: Carregando
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: MyColors.abobora,
                        ),
                      );
                    }
                    // Estado 2: Vazio / Erro
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Nenhum comentário encontrado.'),
                      );
                    }

                    // Estado 3: Renderizar Lista
                    final comentarios = snapshot.data!;
                    return ListView.builder(
                      itemCount: comentarios.length,
                      itemBuilder: (context, index) {
                        final com = comentarios[index];
                        final usuario =
                            com[DbTables.usuarios] ?? {}; // Trata nulos do Join
                        final idCom = com[DbComentarios.idComentario];

                        // [VERIFICAÇÃO DE AUTORIA] Para bloquear ou liberar os botões de edição
                        bool isMeuComentario =
                            com[DbComentarios.idUsuario] == meuIdLogado;

                        // [PROCESSAMENTO DAS CURTIDAS]
                        final listaCurtidas =
                            com['Curtidas_Comentarios'] as List<dynamic>? ?? [];
                        final int quantidadeCurtidas = listaCurtidas.length;

                        // Se meu ID estiver dentro da lista que o banco retornou, a variável fica verdadeira
                        bool euCurti = listaCurtidas.any(
                          (curtida) => curtida['id_usuario'] == meuIdLogado,
                        );

                        // [CONVERSÃO DE FUSO HORÁRIO (UTC PARA LOCAL)]
                        DateTime dataDoComentario;
                        try {
                          dataDoComentario = DateTime.parse(
                            com[DbComentarios.data].toString(),
                          ).toLocal();
                        } catch (e) {
                          dataDoComentario =
                              DateTime.now(); // Fallback de segurança
                        }

                        // Desenha o item individual da lista
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: MyColors.creme,
                                    backgroundImage:
                                        usuario[DbUsuarios.avatarUrl] != null
                                        ? NetworkImage(
                                            usuario[DbUsuarios.avatarUrl],
                                          )
                                        : null,
                                    child: usuario[DbUsuarios.avatarUrl] == null
                                        ? const Icon(
                                            Icons.person,
                                            color: MyColors.abobora,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              usuario[DbUsuarios.nome] ??
                                                  'Usuário',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatarData(dataDoComentario),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: MyColors.marromClaro
                                                    .withAlpha(150),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(com[DbComentarios.texto] ?? ''),
                                        Row(
                                          children: [
                                            _botaoMicroAcao(
                                              icon: euCurti
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: euCurti
                                                  ? Colors.red
                                                  : MyColors.marromClaro,
                                              label: quantidadeCurtidas
                                                  .toString(),
                                              onTap: () =>
                                                  _curtirComentario(idCom),
                                            ),
                                            const SizedBox(width: 16),

                                            // Botões controlados por condicional (Só o dono vê)
                                            if (isMeuComentario)
                                              _botaoMicroAcao(
                                                icon: Icons.edit_outlined,
                                                label: 'Editar',
                                                onTap: () =>
                                                    _mostrarDialogoEditar(
                                                      context,
                                                      idCom,
                                                      com[DbComentarios.texto],
                                                    ),
                                              ),
                                            const SizedBox(width: 16),
                                            if (isMeuComentario)
                                              _botaoMicroAcao(
                                                icon: Icons.delete_outline,
                                                label: 'Excluir',
                                                color: Colors.red[300],
                                                onTap: () =>
                                                    _deletarComentario(idCom),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // UPDATE (Editar comentário)
  // Abre um AlertDialog no centro da tela sobreposto à gaveta.
  void _mostrarDialogoEditar(
    BuildContext context,
    int idCom,
    String textoAtual,
  ) {
    final controller = TextEditingController(text: textoAtual);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Comentário', style: TextStyle(fontSize: 16)),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // UPDATE: Atualiza a coluna texto ONDE o ID bater. (O banco manterá a data intacta)
              await Supabase.instance.client
                  .from(DbTables.comentarios)
                  .update({DbComentarios.texto: controller.text})
                  .eq(DbComentarios.idComentario, idCom);

              Navigator.pop(context); // Fecha o AlertDialog
              Navigator.pop(context); // Fecha a Gaveta debaixo
              _abrirGavetaComentarios(
                context,
              ); // Reabre a gaveta com o texto atualizado
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
