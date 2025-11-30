import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'viewmodels/game_viewmodel.dart';
import 'services/localization_service.dart';
import 'screens/game_screen.dart';

void main() {
  // setHashUrlStrategy(); // Removed to fix compilation error
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameViewModel()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: MaterialApp(
        title: 'Arcana',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}
