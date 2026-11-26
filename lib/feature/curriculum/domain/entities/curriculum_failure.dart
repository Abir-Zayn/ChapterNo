// Enumerates curriculum catalogue failure modes independent of any backend.
// Presentation and callers map these values to recoverable UI feedback.

enum CurriculumFailure {
  offline,
  notFound,
  unauthorized,
  serverError,
  cacheCorrupt,
  unknown,
}
