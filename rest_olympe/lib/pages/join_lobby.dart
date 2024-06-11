import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/controllers/api_controller.dart';
import 'package:rest_olympe/shared/layout.dart';
import 'package:rest_olympe/util/helpers.dart';

class JoinLobby extends StatefulWidget {
  const JoinLobby({super.key});

  @override
  State<StatefulWidget> createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby> with WidgetsBindingObserver  {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    formats: [
      BarcodeFormat.all
    ]
  );
  StreamSubscription<Object?>? _subscription;
  bool showScanner = false;


  String? codeFieldErrorMessage = 'Veuillez renseigner un code';

  String? validateCodeField(String? value) 
  {
    return codeFieldErrorMessage;
  }

  Future<void> validateCodeFieldAsync(String? value) async
  {
    if (value == null || value.isEmpty) {
      codeFieldErrorMessage = 'Veuillez renseigner un code';
      return;
    }
    try {
      var uuid = Helpers.parseUuidWithoutHyphens(value);
      var lobby = await ApiController.getLobby(uuid);
      if (lobby == null)
      {
        codeFieldErrorMessage = "Le salon n'existe pas";
      }
      else {
        codeFieldErrorMessage = null;
      }
    }
    catch (_) {
      codeFieldErrorMessage = "Le code renseigné est incorrect";
    }
    _formKey.currentState?.validate();
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _tryJoinLobby(String lobbyId) async {
    final joined = await ApiController.joinLobby(lobbyId);
    if (joined && mounted)
    {
      Navigator.pushNamed(context, "/lobby", arguments: lobbyId);
    }
    else {
      print("Error while trying to join lobby!");
    }
  }



  void _handleBarcode(BarcodeCapture capture)
  {
    final item = capture.barcodes.firstOrNull?.rawValue;
    if (item != null) {
      unawaited(_tryJoinLobby(item));
      _stopScanner();
    }
  }

  void toggleQrCodeScanner(bool isActive)
  {
    if (isActive)
    {
      _startScanner();
    }
    else {
      _stopScanner();
    }
    setState(() {
      showScanner = isActive;
    });
  }

  void _startScanner()
  {
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  void _stopScanner()
  {
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(controller.stop());
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _startScanner();
        return;
      case AppLifecycleState.inactive:
        _stopScanner();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RestoLayout(
      showLogo: false, 
      title: "Rejoindre un salon", 
      child: Column(children: [
        Form(
          key: _formKey,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                validator: validateCodeField,
                onChanged: (value) => unawaited(validateCodeFieldAsync(value)),
                decoration: const InputDecoration(
                  hintText: "Entrez un code de salon.",
                ),
                style: const TextStyle(
                  color: Colors.black
                ),
                onSaved: (String? newValue) async {
                  if (newValue == null) {
                    print("Null newValue");
                    return;
                  }
                  var uuid = Helpers.parseUuidWithoutHyphens(newValue);
                  _tryJoinLobby(uuid);
                },
              ),
            ),
            StyledButton(
              isPrimary: true, 
              child: const Text("Rejoindre à l'aide d'un code."),
              onPressed: ()
              {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              }
            ),]   
          )
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: MobileScanner(
              controller: controller,
            ),
          )
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StyledButton(
            isPrimary: true, 
            onPressed: () => toggleQrCodeScanner(!showScanner), 
            child: Text(!showScanner ? "Scanner un QR code" : "Fermer le scanner")
          ),
        ),

        StyledButton(
          isPrimary: true, 
          onPressed: ()
          {
            Navigator.pushNamed(context, "/");
          }, 
          child: const Text("Retourner au menu principal.")
        ),
      ],)
    );
  }


  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }
}