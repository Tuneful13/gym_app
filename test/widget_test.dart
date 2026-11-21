import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/actualizador.dart';

Map<String, dynamic> release(String tag, {List<Map<String, dynamic>>? assets}) => {
      'tag_name': tag,
      'body': 'Cambios',
      'assets': assets ??
          [
            {
              'name': 'gym_app-$tag.apk',
              'browser_download_url': 'https://example.com/$tag.apk',
              'digest': 'sha256:abc123',
            }
          ],
    };

void main() {
  group('compararVersiones', () {
    test('ordena por mayor, menor y parche', () {
      expect(compararVersiones('1.0.2', '1.0.1'), greaterThan(0));
      expect(compararVersiones('1.1.0', '1.0.9'), greaterThan(0));
      expect(compararVersiones('2.0.0', '1.9.9'), greaterThan(0));
      expect(compararVersiones('1.0.1', '1.0.2'), lessThan(0));
      expect(compararVersiones('1.0.10', '1.0.9'), greaterThan(0));
    });

    test('ignora la v inicial y el número de build', () {
      expect(compararVersiones('v1.0.1', '1.0.1'), 0);
      expect(compararVersiones('1.0.1+5', '1.0.1'), 0);
      expect(compararVersiones('1.0', '1.0.0'), 0);
    });
  });

  group('releaseDesdeJson', () {
    test('devuelve la release si es más nueva y tiene APK', () {
      final r = releaseDesdeJson(release('v1.0.2'), '1.0.1');
      expect(r, isNotNull);
      expect(r!.version, '1.0.2');
      expect(r.urlApk, 'https://example.com/v1.0.2.apk');
      expect(r.sha256, 'abc123');
      expect(r.notas, 'Cambios');
    });

    test('nada si la versión es igual o más antigua', () {
      expect(releaseDesdeJson(release('v1.0.1'), '1.0.1'), isNull);
      expect(releaseDesdeJson(release('v1.0.0'), '1.0.1'), isNull);
    });

    test('nada si la release no trae APK', () {
      final json = release('v2.0.0', assets: [
        {'name': 'notas.txt', 'browser_download_url': 'https://example.com/notas.txt'}
      ]);
      expect(releaseDesdeJson(json, '1.0.1'), isNull);
    });
  });
}
