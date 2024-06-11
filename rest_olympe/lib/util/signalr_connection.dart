import 'package:logging/logging.dart';
import 'package:rest_olympe/util/http_initialize.dart';
import 'package:rest_olympe/util/notification_setup.dart';
import 'package:signalr_netcore/signalr_client.dart';


const restoSignalRHub = "$baseServerUrl/restohub";

// If you want only to log out the message for the higer level hub protocol:
final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
final transportProtLogger = Logger("SignalR - transport");



Future<void> initSignalRHub() async
{
  // Configer the logging
  Logger.root.level = Level.ALL;
  // Writes the log messages to the console
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final httpOptions = HttpConnectionOptions(logger: transportProtLogger);


  // Creates the connection by using the HubConnectionBuilder.
  final hubConnection = HubConnectionBuilder()
    .withUrl(restoSignalRHub, options: httpOptions)
    .configureLogging(hubProtLogger)
    .build();

  hubConnection.on("ReceiveMessage", (arguments) async {
    if (arguments != null && arguments.isNotEmpty) {
      await showLocalNotification("Un message a été reçu", arguments.first.toString());
    }
  });
  // When the connection is closed, print out a message to the console.
  hubConnection.onclose(({Exception? error}) {
    print("Connection Closed");
  });

  await hubConnection.start();
  
  if (hubConnection.state != HubConnectionState.Connected)
  {
    print("SignalR init failed");
    print(hubConnection.state);
    return;
  }
  print("SignalR init successful");

}


