import 'package:logging/logging.dart';

void initializeLogger([worker = "MAIN"]) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    String color = "";
    const String reset = "\x1B[0m";
    const String workerColor = "\x1B[1;95m";
    const String nameColor = "\x1B[1;92m";
    
    switch (record.level) {
      case Level.FINEST:
        color = "\x1B[37m";
        break;

      case Level.FINER:
        color = "\x1B[36m";
        break;
      
      case Level.FINE:
        color = "\x1B[32m";
        break;
      
      case Level.SEVERE:
        color = "\x1B[31m";
        break;

      case Level.WARNING:
        color = "\x1B[33m";
        break;

      case Level.INFO:
        color = ansiColor(50, 50, 250);
        break;
      
      case Level.CONFIG:
        color = ansiColor(141, 97, 250);
        break;
      default:
        color = "";
    }

    //ignore: avoid_print
    print('$workerColor[WORKER/$worker]$nameColor[${record.loggerName}] $color${record.level.name}: ${record.time}: ${record.message}$reset');
  });
}

String ansiColor(int r, int g, int b) {
  return "\x1B[38;2;$r;$g;${b}m";
}