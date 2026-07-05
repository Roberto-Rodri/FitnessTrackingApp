enum TrainingPhase {
  gaining,
  cutting,
  maintaining,
  none,
}

class UserProfile {
  final String? name;
  final TrainingPhase phase;

  const UserProfile({
    this.name,
    this.phase = TrainingPhase.none,
  });

  UserProfile copyWith({
    String? name,
    TrainingPhase? phase,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phase: phase ?? this.phase,
    );
  }
}
