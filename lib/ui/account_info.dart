import 'dart:convert';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "28 Oct 2026"
String fmtDay(DateTime t) => '${t.day} ${_months[t.month - 1]} ${t.year}';

/// "28 Oct, 4:12 PM" (the year is added for other years)
String fmtStamp(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final day = t.year == DateTime.now().year ? '${t.day} ${_months[t.month - 1]}' : fmtDay(t);
  return '$day, $h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
}

/// What an Xtream Codes server says about the subscription (`user_info`),
/// saved the last time the playlist was refreshed. Plain M3U links carry none of it.
class AccountInfo {
  AccountInfo._({this.status, this.expires, this.unlimited = false, this.created, this.active, this.max, this.trial = false});

  final String? status;

  /// Expiry date, or null when the server gave none.
  final DateTime? expires;

  /// The server reported no expiry at all (lifetime or unlimited account).
  final bool unlimited;
  final DateTime? created;
  final int? active, max;
  final bool trial;

  static DateTime? _date(Object? v) {
    final n = int.tryParse(v?.toString() ?? '');
    if (n == null || n <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(n * 1000);
  }

  static AccountInfo? parse(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final d = jsonDecode(json);
      if (d is! Map) return null;
      final u = d['user_info'] is Map ? d['user_info'] as Map : d;
      if (!u.containsKey('exp_date') && !u.containsKey('status') && !u.containsKey('max_connections')) return null;
      final exp = _date(u['exp_date']);
      return AccountInfo._(
        status: u['status']?.toString(),
        expires: exp,
        unlimited: exp == null && u.containsKey('exp_date'),
        created: _date(u['created_at']),
        active: int.tryParse(u['active_cons']?.toString() ?? ''),
        max: int.tryParse(u['max_connections']?.toString() ?? ''),
        trial: u['is_trial']?.toString() == '1',
      );
    } catch (_) {
      return null;
    }
  }

  /// "in 23 days", "tomorrow", "today", "expired 4 days ago".
  String? get countdown {
    final e = expires;
    if (e == null) return null;
    final days = DateTime(e.year, e.month, e.day).difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
    if (days < 0) return 'expired ${-days} day${days == -1 ? '' : 's'} ago';
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days < 60) return 'in $days days';
    return 'in ${(days / 30).round()} months';
  }

  bool get expired => expires != null && expires!.isBefore(DateTime.now());

  /// Within two weeks of running out.
  bool get soon => expires != null && !expired && expires!.difference(DateTime.now()).inDays <= 14;
}
