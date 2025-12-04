import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:posix/posix.dart';

void main(List<String> arguments) async {
  if (geteuid() != 1000) {
    print("program should run as a user ... you are ${geteuid()}");
    exit(1);
  }

  if (arguments.isEmpty) {
    print("program needs args");
    exit(1);
  }

  final summary = arguments[0];
  final body = arguments[1];
  final timeout = int.parse(arguments[2]);

  final client = NotificationsClient();
  await client.notify(
    summary,
    appName: "PlutoOS",
    appIcon: "file:///usr/share/pixmaps/pluto-logo.png",
    expireTimeoutMs: timeout,
    body: body,
    replacesId: 45944595,
    hints: [
      NotificationHint.urgency(NotificationUrgency.critical),
    ]
  );
  await client.close();
}
