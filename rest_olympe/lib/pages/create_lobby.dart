import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rest_olympe/components/custom_light_input.dart';
import 'package:rest_olympe/components/resto_card.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/shared/layout.dart';

class CreateLobby extends StatefulWidget {
  const CreateLobby({super.key});

  @override
  State<StatefulWidget> createState() => _CreateLobbyState();
}

class _CreateLobbyState extends State<CreateLobby> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool limitAroundPosition = false;
  bool canUseLocationLimit = false;

  @override
  void initState() {
    super.initState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    if (await Permission.locationWhenInUse.request().isGranted) {
      setState(() {
        canUseLocationLimit = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RestoLayout(
      title: "Création du salon",
      showLogo: false, 
      child: Form(
        key: _formKey,
        child: Column (
          children: [
            Expanded(
              child: RestoCard(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      CustomLightInput(
                        isNumeric: false,
                        label: "Nom du salon",
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez donner un nom au salon';
                          }
                          return null;
                        },
                        placeholder: "Entrez le nom du salon",
                        onSaved: (String? newValue) {
                          print("Le nom du salon est : $newValue");
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: CheckboxListTile(
                          title: const Text("Autour de moi"),
                          value: limitAroundPosition, 
                          activeColor: Theme.of(context).colorScheme.secondary,
                          checkColor: Theme.of(context).colorScheme.onSecondary,
                          onChanged: canUseLocationLimit ? (newValue) async {
                            setState(() {
                              limitAroundPosition = newValue != null && newValue;
                            });
                          } : null
                        ),
                      ), 
                      limitAroundPosition 
                        ? CustomLightInput(
                          isNumeric: true,
                          label: "Distance maximum (en km)",
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une valeur';
                            }
                            return null;
                          },
                          placeholder: "Distance en km",
                          onSaved: (String? newValue) {
                            print("La distance en KM est : $newValue");
                            Geolocator
                              .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
                              .then((Position position) {
                                setState(() {
                                  print("Avec pour position : ${position.longitude} ${position.latitude}");
                                });
                              }).catchError((e) {
                                print(e);
                              });
                          },
                        ) : Container(),
                    ]
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledButton(
                    isPrimary: false,
                    onPressed: () {
                      Navigator.pushNamed(context, "/");
                    }, 
                    child: const Text("Retour") 
                  ),
                  StyledButton(
                    isPrimary: true,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    }, 
                    child: const Text("Créer le salon")
                  ),
                ],
              ),
            )
          ]
        ),
      )
    );
  }
}