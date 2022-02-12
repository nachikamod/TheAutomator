import 'package:automator/screens/homeScreen.dart';
import 'package:automator/screens/loginScreen.dart';
import 'package:automator/screens/timerScreen.dart';
import 'package:automator/services/authentication_service.dart';
import 'package:automator/values/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Automator());
}

class Automator extends StatelessWidget {
  const Automator({Key? key}) : super(key: key);

  static final Map<int, Color> color = {
    50: const Color.fromRGBO(136, 14, 79, .1),
    100: const Color.fromRGBO(136, 14, 79, .2),
    200: const Color.fromRGBO(136, 14, 79, .3),
    300: const Color.fromRGBO(136, 14, 79, .4),
    400: const Color.fromRGBO(136, 14, 79, .5),
    500: const Color.fromRGBO(136, 14, 79, .6),
    600: const Color.fromRGBO(136, 14, 79, .7),
    700: const Color.fromRGBO(136, 14, 79, .8),
    800: const Color.fromRGBO(136, 14, 79, .9),
    900: const Color.fromRGBO(136, 14, 79, 1),
  };

  static final MaterialColor scaffoldColor =
      MaterialColor(CustomColors().AppTheme_dark, color);

  static final MaterialColor swatchColor =
      MaterialColor(CustomColors().Assets_dark, color);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(CustomColors().AppBar_dark),
        statusBarIconBrightness: Brightness.light));

    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
              create: (_) => AuthenticationService(FirebaseAuth.instance)),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null,
          )
        ],
        child: MaterialApp(
          title: "Automator",
          theme: ThemeData(
              primarySwatch: swatchColor,
              scaffoldBackgroundColor: scaffoldColor,
              appBarTheme: AppBarTheme(
                  backgroundColor: Color(CustomColors().AppBar_dark),
                  titleTextStyle: const TextStyle(color: Colors.white))),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthenticationWrapper(),
            '/timerScreen': (context) => const TimerScreen()
          },
        ));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    // ignore: unnecessary_null_comparison
    if (firebaseUser != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
