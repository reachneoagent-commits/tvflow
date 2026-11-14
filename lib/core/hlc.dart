/// Hybrid Logical Clock.
///
/// A stamp is `<millis:15 digits>-<counter:5 digits>-<deviceId>` so plain
/// string comparison orders stamps by time, then counter, then device id.
/// That gives a total order across devices even when wall clocks drift.
class Hlc {
  Hlc(this.deviceId, {int Function()? now})
      : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final String deviceId;
  final int Function() _now;
  int _millis = 0;
  int _counter = 0;

  /// Next stamp for a local change.
  String tick() {
    final wall = _now();
    if (wall > _millis) {
      _millis = wall;
      _counter = 0;
    } else {
      _counter++;
    }
    return format(_millis, _counter, deviceId);
  }

  /// Advance past a stamp seen from another device.
  void observe(String remote) {
    final p = parse(remote);
    if (p == null) return;
    final wall = _now();
    final maxMillis = [wall, _millis, p.millis].reduce((a, b) => a > b ? a : b);
    if (maxMillis == _millis && maxMillis == p.millis) {
      _counter = (_counter > p.counter ? _counter : p.counter) + 1;
    } else if (maxMillis == _millis) {
      _counter++;
    } else if (maxMillis == p.millis) {
      _counter = p.counter + 1;
    } else {
      _counter = 0;
    }
    _millis = maxMillis;
  }

  static String format(int millis, int counter, String device) =>
      '${millis.toString().padLeft(15, '0')}-'
      '${counter.toString().padLeft(5, '0')}-$device';

  static ({int millis, int counter, String device})? parse(String s) {
    final parts = s.split('-');
    if (parts.length < 3) return null;
    final m = int.tryParse(parts[0]);
    final c = int.tryParse(parts[1]);
    if (m == null || c == null) return null;
    return (millis: m, counter: c, device: parts.sublist(2).join('-'));
  }

  /// Wall-clock millis encoded in a stamp (0 if malformed).
  static int millisOf(String s) => parse(s)?.millis ?? 0;
}
