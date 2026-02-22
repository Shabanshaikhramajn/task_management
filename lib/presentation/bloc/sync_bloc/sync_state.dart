abstract class SyncState {}


class SyncIdle extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  final String message;
  SyncFailure(this.message);
}