import 'package:acervo/components/botao.componente.dart';
import 'package:acervo/pages/home.page.dart';
import 'package:flutter/material.dart';
import 'package:acervo/my_colors.dart';
import 'package:go_router/go_router.dart';

import 'cadastro.page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.creme, // Fundo creme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white, // Container branco
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Text(
                    'Bem-vindo',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: MyColors.marrom,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Retome sua jornada literária',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MyColors.marromClaro,
                      fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Campo de Email
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MyColors.marromClaro,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'seu@email.com',
                      prefixIcon: const Icon(Icons.email_outlined, color: MyColors.marrom),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marromClaro),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marromClaro),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marrom, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  // Campo de Senha
                  const Text(
                    'Senha',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MyColors.marromClaro,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Digite sua senha',
                      prefixIcon: const Icon(Icons.lock_outline, color: MyColors.marrom),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marromClaro),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marromClaro),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.marrom, width: 2),
                      ),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 32),


                 BotaoComponente(texto: "Entrar no Acervo", onPressed: (){context.push(HomePage.routeName);}, borderRadius: 46,corFundo: MyColors.abobora, iconeDepois: Icons.arrow_forward,),

                  const SizedBox(height: 16),


                  TextButton(
                    onPressed: () {
                      context.push(CadastroPage.routeName);
                     print("botão clicado");
                    },
                    child: Text(
                      'Não tem uma conta? Cadastre-se',
                      style: TextStyle(
                        color: MyColors.marrom,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}