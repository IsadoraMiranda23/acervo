import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:acervo/pages/home.page.dart';
import 'package:acervo/my_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Conexão com o Banco de Dados Supabase
  await Supabase.initialize(
    url: 'https://aocsoypewmyaulaagklz.supabase.co',
    anonKey: 'sb_publishable_xcExOS9YSNU5eBJGZxpdAQ_Q2OnibJy',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors.marrom),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
