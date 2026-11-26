// Entrypoint running all 35 Tier 1 happy-path E2E tests across AC-1..AC-7.
// Split across focused sub-modules to obey the <300-line file limit.
import 'tier1_feature_coverage_test_imports.dart';

void main() {
  registerTier1Ac1ToAc2Tests();
  registerTier1Ac3Tests();
  registerTier1Ac4Tests();
  registerTier1Ac5Tests();
  registerTier1Ac6Tests();
  registerTier1Ac7Tests();
}
