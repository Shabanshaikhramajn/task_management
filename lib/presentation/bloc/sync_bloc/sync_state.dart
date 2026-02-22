abstract class SyncState {}

class SyncIdle extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncCompleted extends SyncState {}

class SyncFailed extends SyncState {
  final String reason;
  SyncFailed(this.reason);
}