// Reasons a community operation can fail, independent of any backend.
// Presentation maps each value to learner-facing copy.

enum CommunityFailure {
  network,

  /// The operation is not supported by the current backend wiring.
  unavailable,
  unknown,
}
