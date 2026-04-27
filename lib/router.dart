import 'package:acervo/pages/biblioteca.page.dart';
import 'package:acervo/pages/cadastro.page.dart';
import 'package:acervo/pages/login.page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:acervo/pages/home.page.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: LoginPage.routeName,
  routes: [
    GoRoute(
      path: LoginPage.routeName,
      name: LoginPage.routeName,
      pageBuilder: (contex, state) => NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: CadastroPage.routeName,
      name: CadastroPage.routeName,
      pageBuilder: (contex, state) => NoTransitionPage(child: CadastroPage()),
    ),

    GoRoute(
      path: HomePage.routeName,
      name: HomePage.routeName,
      pageBuilder: (contex, state) => NoTransitionPage(child: HomePage()),
    ),
    GoRoute(
      path: BibliotecaPage.routeName,
      name: BibliotecaPage.routeName,
      pageBuilder: (contex, state) => NoTransitionPage(child: BibliotecaPage()),
    ),
  ],
);
