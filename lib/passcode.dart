import 'package:digicode/models/user.dart';
import 'package:digicode/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PassCodeScreen extends ConsumerStatefulWidget {
  final User user;
  final Widget target;

  const PassCodeScreen({Key? key, required this.user, required this.target}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PassCodeScreenState();
}

class _PassCodeScreenState extends ConsumerState<PassCodeScreen> {
  String digits = '';

  Widget key({String? text, Icon? icon, action}) {
    return InkWell(
      onTap: action,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: digits.length == 4 ? Colors.black26 : Colors.black12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: text != null
              ? Text(
                  text,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : icon ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.user.username, style: const TextStyle(fontSize: 20)),
                IconButton(
                  onPressed: () {
                    ref.read(authProvider).disconnect();
                  },
                  icon: const FaIcon(FontAwesomeIcons.rotate),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Saisissez votre code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: index < digits.length ? Colors.lightGreen[400] : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 300,
            child: GridView.count(
              primary: false,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 3,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: List.generate(10, (index) {
                    return key(
                        text: '$index',
                        action: digits.length <= 4
                            ? () {
                                setState(() {
                                  digits += '$index';
                                });
                                if (digits.length == 4) {
                                  if (int.parse(digits) == widget.user.code) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Code correct'),
                                      duration: Duration(seconds: 2),
                                    ));
                                    Future.delayed(const Duration(seconds: 2)).then((value) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
                                        return widget.target;
                                      }));
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Code incorrect'),
                                      duration: Duration(seconds: 2),
                                    ));
                                    Future.delayed(const Duration(seconds: 2)).then((value) {
                                      setState(() {
                                        digits = '';
                                      });
                                    });
                                  }
                                }
                              }
                            : null);
                  }) +
                  [
                    key(
                      icon: const Icon(FontAwesomeIcons.deleteLeft, size: 20),
                      action: digits.isNotEmpty ? () => setState(() => digits = digits.substring(0, digits.length - 1)) : null,
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }
}
