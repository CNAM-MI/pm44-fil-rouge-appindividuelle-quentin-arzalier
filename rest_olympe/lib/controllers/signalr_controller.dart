import 'package:logging/logging.dart';
import 'package:rest_olympe/util/http_initialize.dart';
import 'package:rest_olympe/util/notification_setup.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRController {
  
  static const _restoSignalRHub = "$baseServerUrl/restohub";

  // If you want only to log out the message for the higer level hub protocol:
  static final _hubProtLogger = Logger("SignalR - hub");
  // If youn want to also to log out transport messages:
  static final _transportProtLogger = Logger("SignalR - transport");

  static late final HubConnection hub;

  static Future<void> initSignalRHub() async
  {
    print(_restoSignalRHub);
    // Configer the logging
    Logger.root.level = Level.ALL;
    // Writes the log messages to the console
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    final httpOptions = HttpConnectionOptions(logger: _transportProtLogger);


    // Creates the connection by using the HubConnectionBuilder.
    hub = HubConnectionBuilder()
      .withUrl(_restoSignalRHub, options: httpOptions)
      .configureLogging(_hubProtLogger)
      .build();

    hub.on("LobbyClosed", (arguments) async {
      if (arguments != null && arguments.isNotEmpty) {
        await showLocalNotification("Un salon de vote a été fermé.", "L'un de vos salons de vote a pris fin. Allez voir les résultats dès maintenant!");
      }
    });

    // When the connection is closed, print out a message to the console.
    hub.onclose(({Exception? error}) {
      print("Connection Closed");
    });

    await hub.start();
    
    if (hub.state != HubConnectionState.Connected)
    {
      print("SignalR init failed");
      print(hub.state);
      return;
    }
    print("SignalR init successful");

  }
}