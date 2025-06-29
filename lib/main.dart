import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jomaboi/authentication/landing_screen.dart';
import 'package:jomaboi/authentication/login_screen.dart';
import 'package:jomaboi/authentication/opt_screen.dart';
import 'package:jomaboi/authentication/user_information_screen.dart';
import 'package:jomaboi/constants.dart';
import 'package:jomaboi/firebase_options.dart';
import 'package:jomaboi/main_screen.dart';
import 'package:jomaboi/main_screen/chat_screen.dart';
import 'package:jomaboi/main_screen/friend_requests_screen.dart';
import 'package:jomaboi/main_screen/friends_screen.dart';
import 'package:jomaboi/main_screen/group_information_screen.dart';
import 'package:jomaboi/main_screen/group_settings_screen.dart';
import 'package:jomaboi/main_screen/home_screen.dart';
import 'package:jomaboi/main_screen/profile_screen.dart';
import 'package:jomaboi/providers/authentication_provider.dart';
import 'package:jomaboi/providers/chat_provider.dart';
import 'package:jomaboi/providers/group_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jomaboi/bloc/cubit/app_cubit.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final appState = await AppState.getState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        BlocProvider<AppCubit>(create: (_) => AppCubit(appState)),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JomaBoi',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(),
          Constants.mainScreen: (context) => const MainScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) =>
              const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.groupSettingsScreen: (context) =>
              const GroupSettingsScreen(),
          Constants.groupInformationScreen: (context) =>
              const GroupInformationScreen(),
        },
      ),
    );
  }
}
