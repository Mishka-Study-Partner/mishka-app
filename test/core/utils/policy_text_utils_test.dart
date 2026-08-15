import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/core/utils/policy_text_utils.dart';

void main() {
  test('preparePolicyTextForDisplay structures numbered sections', () {
    const raw = '''
Welcome to Mishka.

⸻

1. About Mishka

Mishka is an educational application.

⸻

2. Information We Collect

Account Information

When you create an account, we may collect:

* Name or username
* Email address
''';

    final formatted = preparePolicyTextForDisplay(raw);

    expect(formatted, contains('## 1. About Mishka'));
    expect(formatted, contains('## 2. Information We Collect'));
    expect(formatted, contains('### Account Information'));
    expect(formatted, contains('\n---\n'));
    expect(formatted, contains('* Name or username'));
  });
}
