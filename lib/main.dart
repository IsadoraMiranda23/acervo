import 'package:acervo/router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:acervo/my_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 1. Garante que o motor do Flutter está rodando antes de ler arquivos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carrega a env com as credenciais do banco de dados e API
  await dotenv.load(fileName: ".env");

  // 1. Conexão com o Banco de Dados Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Acervo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors.marrom),
        useMaterial3: true,

        // Definindo fontes globais
        fontFamily: 'Manrope', // Fonte padrão para texto
        textTheme: const TextTheme(
          // Títulos usando Newsreader
          displayLarge: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
          ),

          // Texto corporal usando Manrope
          bodyLarge: TextStyle(fontFamily: 'Manrope'),
          bodyMedium: TextStyle(fontFamily: 'Manrope'),
          bodySmall: TextStyle(fontFamily: 'Manrope'),

          // Botões e labels usando Manrope
          labelLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
          ),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Newsreader',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
