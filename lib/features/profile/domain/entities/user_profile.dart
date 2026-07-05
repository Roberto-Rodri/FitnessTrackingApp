enum TrainingPhase {
  gaining,
  cutting,
  maintaining,
  none,
}

class UserProfile {
  final String? name;
  final TrainingPhase phase;
  final bool hasSeenWarmupHint;

  const UserProfile({
    this.name,
    this.phase = TrainingPhase.none,
    this.hasSeenWarmupHint = false,
  });

  UserProfile copyWith({
    String? name,
    TrainingPhase? phase,
    bool? hasSeenWarmupHint,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phase: phase ?? this.phase,
      hasSeenWarmupHint: hasSeenWarmupHint ?? this.hasSeenWarmupHint,
    );
  }
}
