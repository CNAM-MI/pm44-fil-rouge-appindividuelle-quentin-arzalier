import 'package:flutter/material.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/shared/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("username") != null) {
      if (mounted) Navigator.pushNamed(context, "/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RestoLayout(
      showLogo: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre nom d\'utilisateur',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une valeur';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    color: Colors.black
                  ),
                  onSaved: (newValue) async {
                    if (newValue != null) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString("username", newValue);
                      if (context.mounted) Navigator.pushNamed(context, "/");
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: StyledButton(
                    isPrimary: true,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    },
                    child: const Text("S'identifier"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}