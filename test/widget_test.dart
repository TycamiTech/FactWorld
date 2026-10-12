import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:factworld/main.dart';
import 'package:factworld/presentation/providers/country_provider.dart';
import 'package:factworld/domain/repositories/country_repository.dart';
import 'package:factworld/data/models/country_model.dart';

class FakeCountryRepository implements CountryRepository {
  @override
  Future<List<CountryModel>> getCountries() async => [];
}

void main() {
  testWidgets('FactWorldApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countryRepositoryProvider.overrideWithValue(FakeCountryRepository()),
        ],
        child: const FactWorldApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FactWorldApp), findsOneWidget);
  });
}
