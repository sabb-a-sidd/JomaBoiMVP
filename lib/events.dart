import 'package:events_emitter/emitters/event_emitter.dart';

enum GlobalEventTypes {
  paymentUpdate,
  categoryUpdate,
  accountUpdate,
  groupUpdate
}

final globalEvent = EventEmitter();
