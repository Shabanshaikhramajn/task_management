abstract class SyncEvent {}

/// Triggered by timer every 10 seconds
class StartSync extends SyncEvent {}

/// Manual retry (optional)
class RetrySync extends SyncEvent {}