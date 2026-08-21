import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/notifications/bloc/notifications_bloc.dart';

class DapExpressAdminApp extends StatelessWidget {
  const DapExpressAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc()..add(LoadNotifications()),
        ),
      ],
      child: MaterialApp(
        title: 'Dap-Express Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
