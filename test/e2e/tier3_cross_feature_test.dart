// Entrypoint running all 8 Tier 3 pairwise cross-feature E2E tests.
// Split across focused sub-modules to obey the <300-line file limit.
import 'tier3_cross_feature_test_imports.dart';

void main() {
  registerTier3Part1Tests();
  registerTier3Part2Tests();
}
