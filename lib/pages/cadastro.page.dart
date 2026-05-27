import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../db_constants.dart';
import '../my_colors.dart';
import 'login.page.dart';

class CadastroPage extends StatefulWidget {
  static const String routeName = '/cadastro';
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Validação de e-mail mais robusta
  bool _isValidEmail(String email) {
    // Regex mais completo para validação de e-mail
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleCadastro() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final supabase = Supabase.instance.client;

        final email = _emailController.text.trim().toLowerCase();
        final password = _senhaController.text;

        // Verificação adicional do e-mail
        if (!_isValidEmail(email)) {
          throw Exception('Por favor, insira um e-mail válido (ex: nome@dominio.com)');
        }

        // 1. Criar usuário no Auth do Supabase
        final authResponse = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw Exception('Erro ao criar usuário');
        }

        // 2. Inserir dados do usuário na tabela Usuarios
        final userId = authResponse.user!.id;

        // Gerar username a partir do nome completo
        String username = _nomeCompletoController.text.trim().toLowerCase().replaceAll(' ', '.');
        // Remover caracteres especiais do username
        username = username.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '');
        // Adicionar números aleatórios para garantir unicidade
        username = '$username${DateTime.now().millisecondsSinceEpoch % 10000}';

        await supabase.from(DbTables.usuarios).insert({
          DbUsuarios.id: userId,
          DbUsuarios.nome: _nomeCompletoController.text.trim(),
          DbUsuarios.username: username,
          DbUsuarios.email: email,
          DbUsuarios.avatarUrl: null,
          DbUsuarios.dataNascimento: null,
          DbUsuarios.bio: null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro realizado com sucesso! Verifique seu e-mail para confirmar.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );

          // Navegar para a página de login
          context.go(LoginPage.routeName);
        }
      } catch (e) {
        print('Erro no cadastro: $e');

        String errorMessage = 'Erro ao realizar cadastro. Tente novamente.';

        if (e is AuthException) {
          if (e.message.contains('already registered')) {
            errorMessage = 'Este e-mail já está cadastrado. Faça login ou use outro e-mail.';
          } else if (e.message.contains('password')) {
            errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
          } else if (e.message.contains('email_address_invalid')) {
            errorMessage = 'E-mail inválido. Use um formato como: nome@exemplo.com';
          } else if (e.message.contains('Invalid email')) {
            errorMessage = 'E-mail inválido. Verifique o formato do seu e-mail.';
          }
        } else if (e.toString().contains('e-mail válido')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeCompletoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone
                    Icon(
                      Icons.menu_book,
                      color: MyColors.abobora,
                      size: 48,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "ACERVO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Newheader',
                        fontSize: 32,
                        color: MyColors.abobora,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "Crie seu Acervo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: MyColors.marrom,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Junte-se à nossa comunidade de leitores e organize sua jornada literária.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo Nome completo
                    TextFormField(
                      controller: _nomeCompletoController,
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        labelStyle: TextStyle(color: MyColors.marrom),
                        prefixIcon: Icon(Icons.person_outline, color: MyColors.abobora),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: MyColors.abobora, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome completo';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'Insira seu nome e sobrenome';
                        }
                        if (value.length < 3) {
                          return 'Nome muito curto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo E-mail com validação rigorosa
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'exemplo@dominio.com',
                        labelStyle: TextStyle(color: MyColors.marrom),
                        prefixIcon: Icon(Icons.email_outlined, color: MyColors.abobora),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: MyColors.abobora, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        if (!_isValidEmail(value)) {
                          return 'Insira um e-mail válido (ex: nome@email.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Mínimo 6 caracteres',
                        labelStyle: TextStyle(color: MyColors.marrom),
                        prefixIcon: Icon(Icons.lock_outline, color: MyColors.abobora),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: MyColors.abobora,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: MyColors.abobora, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Confirmar Senha
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        labelStyle: TextStyle(color: MyColors.marrom),
                        prefixIcon: Icon(Icons.lock_outline, color: MyColors.abobora),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: MyColors.abobora,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: MyColors.abobora, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _senhaController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botão Cadastrar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleCadastro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.abobora,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Criar conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Link para login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Já possui uma conta? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(LoginPage.routeName);
                          },
                          child: Text(
                            "Entre aqui",
                            style: TextStyle(
                              color: MyColors.abobora,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}