// Entrypoint running all 39 Tier 2 boundary & negative E2E tests (AC-1..AC-7).
// Split across focused sub-modules to obey the <300-line file limit.
import 'tier2_boundary_cases_test_imports.dart';

void main() {
  registerTier2Ac1ToAc2Tests();
  registerTier2Ac3Tests();
  registerTier2Ac4Tests();
  registerTier2Ac5Tests();
  registerTier2Ac6Tests();
  registerTier2Ac7Tests();
}
