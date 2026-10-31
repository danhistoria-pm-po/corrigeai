import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart'; // IMPORT ADICIONADO
import 'package:corrige_ai/features/auth/presentation/pages/login_page.dart';
import 'package:corrige_ai/features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializa o Hive para persistência local
  await Hive.initFlutter();
  
  // 2. Abre a caixa onde as correções serão salvas
  await Hive.openBox('corrections');
  
  // 3. Carrega o .env
  await dotenv.load(fileName: ".env");

  runApp(const CorrigeAiApp());
}

class CorrigeAiApp extends StatelessWidget {
  const CorrigeAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CorrigeAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}