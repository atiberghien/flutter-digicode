library digicode;

import 'package:digicode/providers/auth_provider.dart';
import 'package:digicode/connection.dart';
import 'package:digicode/passcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGuard extends ConsumerStatefulWidget {
  final Widget logo;
  final Widget target;

  const AuthGuard({super.key, required this.logo, required this.target});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthGuardState();
}

class _AuthGuardState extends ConsumerState<AuthGuard> {
  _children() {
    var auth = ref.watch(authProvider);
    return [
      Center(child: widget.logo),
      FutureBuilder(
        future: auth.getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var user = snapshot.data;
            return PassCodeScreen(user: user!, target: widget.target);
          } else {
            return const ConnectionScreen();
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print("BUILDING AUTH GUARD");
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? Column(
                  children: _children(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _children(),
                );
        },
      ),
    );
  }
}
