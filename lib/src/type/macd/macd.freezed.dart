// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macd.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Macd {

/// MACD Line: 短期EMA - 長期EMA
 double get macdLine;/// Signal Line: MACDラインのEMA
 double get signalLine;/// MACD Histogram: MACDライン - シグナルライン
 double get histogram;
/// Create a copy of Macd
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MacdCopyWith<Macd> get copyWith => _$MacdCopyWithImpl<Macd>(this as Macd, _$identity);

  /// Serializes this Macd to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Macd&&(identical(other.macdLine, macdLine) || other.macdLine == macdLine)&&(identical(other.signalLine, signalLine) || other.signalLine == signalLine)&&(identical(other.histogram, histogram) || other.histogram == histogram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,macdLine,signalLine,histogram);

@override
String toString() {
  return 'Macd(macdLine: $macdLine, signalLine: $signalLine, histogram: $histogram)';
}


}

/// @nodoc
abstract mixin class $MacdCopyWith<$Res>  {
  factory $MacdCopyWith(Macd value, $Res Function(Macd) _then) = _$MacdCopyWithImpl;
@useResult
$Res call({
 double macdLine, double signalLine, double histogram
});




}
/// @nodoc
class _$MacdCopyWithImpl<$Res>
    implements $MacdCopyWith<$Res> {
  _$MacdCopyWithImpl(this._self, this._then);

  final Macd _self;
  final $Res Function(Macd) _then;

/// Create a copy of Macd
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? macdLine = null,Object? signalLine = null,Object? histogram = null,}) {
  return _then(_self.copyWith(
macdLine: null == macdLine ? _self.macdLine : macdLine // ignore: cast_nullable_to_non_nullable
as double,signalLine: null == signalLine ? _self.signalLine : signalLine // ignore: cast_nullable_to_non_nullable
as double,histogram: null == histogram ? _self.histogram : histogram // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Macd].
extension MacdPatterns on Macd {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Macd value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Macd() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Macd value)  $default,){
final _that = this;
switch (_that) {
case _Macd():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Macd value)?  $default,){
final _that = this;
switch (_that) {
case _Macd() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double macdLine,  double signalLine,  double histogram)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Macd() when $default != null:
return $default(_that.macdLine,_that.signalLine,_that.histogram);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double macdLine,  double signalLine,  double histogram)  $default,) {final _that = this;
switch (_that) {
case _Macd():
return $default(_that.macdLine,_that.signalLine,_that.histogram);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double macdLine,  double signalLine,  double histogram)?  $default,) {final _that = this;
switch (_that) {
case _Macd() when $default != null:
return $default(_that.macdLine,_that.signalLine,_that.histogram);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Macd extends Macd {
   _Macd({required this.macdLine, required this.signalLine, required this.histogram}): super._();
  factory _Macd.fromJson(Map<String, dynamic> json) => _$MacdFromJson(json);

/// MACD Line: 短期EMA - 長期EMA
@override final  double macdLine;
/// Signal Line: MACDラインのEMA
@override final  double signalLine;
/// MACD Histogram: MACDライン - シグナルライン
@override final  double histogram;

/// Create a copy of Macd
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MacdCopyWith<_Macd> get copyWith => __$MacdCopyWithImpl<_Macd>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MacdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Macd&&(identical(other.macdLine, macdLine) || other.macdLine == macdLine)&&(identical(other.signalLine, signalLine) || other.signalLine == signalLine)&&(identical(other.histogram, histogram) || other.histogram == histogram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,macdLine,signalLine,histogram);

@override
String toString() {
  return 'Macd(macdLine: $macdLine, signalLine: $signalLine, histogram: $histogram)';
}


}

/// @nodoc
abstract mixin class _$MacdCopyWith<$Res> implements $MacdCopyWith<$Res> {
  factory _$MacdCopyWith(_Macd value, $Res Function(_Macd) _then) = __$MacdCopyWithImpl;
@override @useResult
$Res call({
 double macdLine, double signalLine, double histogram
});




}
/// @nodoc
class __$MacdCopyWithImpl<$Res>
    implements _$MacdCopyWith<$Res> {
  __$MacdCopyWithImpl(this._self, this._then);

  final _Macd _self;
  final $Res Function(_Macd) _then;

/// Create a copy of Macd
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? macdLine = null,Object? signalLine = null,Object? histogram = null,}) {
  return _then(_Macd(
macdLine: null == macdLine ? _self.macdLine : macdLine // ignore: cast_nullable_to_non_nullable
as double,signalLine: null == signalLine ? _self.signalLine : signalLine // ignore: cast_nullable_to_non_nullable
as double,histogram: null == histogram ? _self.histogram : histogram // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
