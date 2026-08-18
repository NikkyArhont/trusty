import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/backend/app_update/app_update_service.dart';

void main() {
  test('builds below minimum require an update', () {
    expect(
      resolveAppUpdateRequirement(
        currentBuild: 18,
        latestBuild: 19,
        minimumBuild: 19,
      ),
      AppUpdateRequirement.required,
    );
  });

  test('supported old builds receive an optional update', () {
    expect(
      resolveAppUpdateRequirement(
        currentBuild: 18,
        latestBuild: 19,
        minimumBuild: 18,
      ),
      AppUpdateRequirement.optional,
    );
  });

  test('the latest build does not receive an update dialog', () {
    expect(
      resolveAppUpdateRequirement(
        currentBuild: 19,
        latestBuild: 19,
        minimumBuild: 19,
      ),
      AppUpdateRequirement.none,
    );
  });
}
