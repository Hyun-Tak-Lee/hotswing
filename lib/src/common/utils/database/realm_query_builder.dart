/// Realm DB의 쿼리 구문과 인자를 안전하게 생성하고 조합하기 위한 유틸리티 빌더 클래스입니다.
class RealmQueryBuilder {
  final List<String> _conditions = [];
  final List<Object> _args = [];
  int _argIndex = 0;

  /// 문자열 시작 일치 검색 조건 추가 (대소문자 무시)
  /// 예: [field] BEGINSWITH[c] [value]
  RealmQueryBuilder addStartsWithCondition(String field, String? value) {
    if (value != null && value.isNotEmpty) {
      _conditions.add('($field BEGINSWITH[c] \$${_argIndex++})');
      _args.add(value);
    }
    return this;
  }

  /// IN 조건 (또는 다중 OR 조건) 추가
  /// 예: ([field] == val1 OR [field] == val2 ...)
  RealmQueryBuilder addInCondition(String field, Iterable<dynamic> values) {
    if (values.isNotEmpty) {
      String condition = values
          .map((_) => '$field == \$${_argIndex++}')
          .join(' OR ');
      _conditions.add('($condition)');
      _args.addAll(values.cast<Object>());
    }
    return this;
  }

  /// 단일 범위 조건 추가
  /// 예: ([field] >= [min] AND [field] <= [max])
  RealmQueryBuilder addRangeCondition(
    String field,
    num min,
    num max, {
    bool includeMax = true,
  }) {
    String maxOperator = includeMax ? '<=' : '<';
    _conditions.add(
      '($field >= \$${_argIndex++} AND $field $maxOperator \$${_argIndex++})',
    );
    _args.addAll([min, max].cast<Object>());
    return this;
  }

  /// 다중 범위 식들을 OR 로 묶는 조건 추가
  /// 예: ( (rate >= 0 AND rate < 500) OR (rate >= 1000 AND rate < 1500) )
  RealmQueryBuilder addMultiRangeOrCondition(
    String field,
    List<List<num>> ranges, {
    bool includeMax = false,
  }) {
    if (ranges.isNotEmpty) {
      List<String> rangeConditions = [];
      String maxOperator = includeMax ? '<=' : '<';

      for (var range in ranges) {
        if (range.length >= 2) {
          rangeConditions.add(
            '($field >= \$${_argIndex++} AND $field $maxOperator \$${_argIndex++})',
          );
          _args.addAll([range[0], range[1]].cast<Object>());
        }
      }

      if (rangeConditions.isNotEmpty) {
        _conditions.add('(${rangeConditions.join(' OR ')})');
      }
    }
    return this;
  }

  /// 완성된 쿼리 문자열 반환
  String build() {
    return _conditions.isEmpty ? 'TRUEPREDICATE' : _conditions.join(' AND ');
  }

  /// 완성된 쿼리 문자열과 매핑된 인자 리스트 반환
  List<Object> get args => _args;
}
