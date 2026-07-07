sealed class ReminderState {
  const ReminderState();
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

class ReminderLoaded extends ReminderState {
  final List<Map<String, dynamic>> reminders;

  const ReminderLoaded(this.reminders);
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);
}

class ReminderActionSuccess extends ReminderState {
  final String message;

  const ReminderActionSuccess(this.message);
}
