import 'package:digicode/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = ChangeNotifierProvider<AuthService>((ref) => AuthService());
