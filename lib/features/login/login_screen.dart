import 'package:flutter/material.dart';
import 'package:hrgo_app/features/login/domain/auth_service.dart';
import 'package:hrgo_app/features/main_navigation_screen/bottom_main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _erpKeyController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authApi = AuthApiService();

  bool _isLoading = false;
  bool _obscure = true;
  bool _domainEntered = false;
  String _selectedLang = 'ru';

  @override
  void dispose() {
    _erpKeyController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkDomainInput(String value) {
    setState(() => _domainEntered = value.trim().isNotEmpty);
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authApi.login(
        login: _loginController.text.trim(),
        password: _passwordController.text.trim(),
        domenUrl: _erpKeyController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добро пожаловать, ${response.userName}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomMainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('AuthException: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isFormValid =>
      _domainEntered &&
      _loginController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Логотип
                Center(child: Image.asset('assets/logo_oil.png', height: 80)),
                const SizedBox(height: 20),

                Text(
                  "Вход в систему",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Домeн компании
                TextFormField(
                  controller: _erpKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Домен вашей компании',
                    hintText: 'например: yourcompany.odoo.com',
                    prefixIcon: Icon(Icons.domain),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Введите домен' : null,
                  onChanged: _checkDomainInput,
                ),
                const SizedBox(height: 16),

                // Логин (доступен только после домена)
                TextFormField(
                  enabled: _domainEntered,
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: 'Логин',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                    fillColor: _domainEntered ? null : Colors.grey.shade200,
                    filled: !_domainEntered,
                  ),
                  validator: (v) {
                    if (!_domainEntered) return null;
                    return v == null || v.isEmpty ? 'Введите логин' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Пароль (доступен только после домена)
                TextFormField(
                  enabled: _domainEntered,
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    fillColor: _domainEntered ? null : Colors.grey.shade200,
                    filled: !_domainEntered,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: _domainEntered
                          ? () => setState(() => _obscure = !_obscure)
                          : null,
                    ),
                  ),
                  validator: (v) {
                    if (!_domainEntered) return null;
                    return v == null || v.isEmpty ? 'Введите пароль' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Язык интерфейса
                DropdownButtonFormField<String>(
                  value: _selectedLang,
                  decoration: const InputDecoration(
                    labelText: 'Язык интерфейса',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) => setState(() => _selectedLang = v!),
                ),
                const SizedBox(height: 24),

                // Кнопка входа
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !_isLoading
                        ? _onLoginPressed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Войти',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),

                const Spacer(),

                Center(
                  child: Text(
                    '© 2025 HRGO',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
