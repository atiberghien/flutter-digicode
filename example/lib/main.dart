import 'dart:io';

import 'package:digicode/digicode.dart';
import 'package:digicode/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(authProvider.notifier).disconnect();
            exit(0);
          },
          child: Text("Disconnect"),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: AuthGuard(
          logo: FlutterLogo(size: 400),
          target: Home(),
          color: Colors.pink,
        ),
      ),
    );
  }
}
