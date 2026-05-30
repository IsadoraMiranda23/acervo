import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Verificar se usuário está logado
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Pegar usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  // Pegar ID do usuário atual
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Pegar e-mail do usuário atual
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  // Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Fazer login
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Fazer logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}