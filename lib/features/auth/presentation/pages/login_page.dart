import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController _controller;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AuthController(AuthRepositoryImpl());
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (_controller.isLoginTab) {
      success = await _controller.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await _controller.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_turned_in, size: 72, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  'CorrigeAI',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Correção Inteligente de Provas Discursivas',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Alternador entre Entrar e Cadastrar
                ToggleButtons(
                  isSelected: [_controller.isLoginTab, !_controller.isLoginTab],
                  onPressed: (index) => _controller.toggleTab(index == 0),
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
                  children: const [
                    Text('Entrar'),
                    Text('Cadastrar'),
                  ],
                ),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_controller.isLoginTab) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe sua senha';
                          if (v.length < 6) return 'Mínimo de 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      if (_controller.errorMessage != null) ...[
                        Text(
                          _controller.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: _controller.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _controller.isLoginTab ? 'Entrar' : 'Criar Conta',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
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