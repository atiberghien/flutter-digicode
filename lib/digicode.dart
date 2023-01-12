library digicode;

import 'package:digicode/providers/auth_provider.dart';
import 'package:digicode/connection.dart';
import 'package:digicode/passcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGuard extends ConsumerStatefulWidget {
  final Widget logo;
  final Widget target;
  final Color color;

  const AuthGuard({super.key, required this.logo, required this.target, required this.color});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthGuardState();
}

class _AuthGuardState extends ConsumerState<AuthGuard> {
  _children() {
    var auth = ref.watch(authProvider);
    return [
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(child: widget.logo),
      ),
      FutureBuilder(
        future: auth.getUser(),
        builder: (context, snapshot) {
          var user = snapshot.hasData && snapshot.data!.id != -1 ? snapshot.data : null;
          if (user != null) {
            return PassCodeScreen(user: user, target: widget.target, color: widget.color);
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
    return OrientationBuilder(
      builder: (context, orientation) {
        return SingleChildScrollView(
          child: orientation == Orientation.portrait
              ? SafeArea(
                  child: Column(
                    children: _children(),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _children(),
                ),
        );
      },
    );
  }
}
