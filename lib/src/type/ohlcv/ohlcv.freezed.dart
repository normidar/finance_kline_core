// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ohlcv.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ohlcv {

 Decimal get open; Decimal get high; Decimal get low; Decimal get close; Decimal get volume;
/// Create a copy of Ohlcv
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OhlcvCopyWith<Ohlcv> get copyWith => _$OhlcvCopyWithImpl<Ohlcv>(this as Ohlcv, _$identity);

  /// Serializes this Ohlcv to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ohlcv&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,high,low,close,volume);

@override
String toString() {
  return 'Ohlcv(open: $open, high: $high, low: $low, close: $close, volume: $volume)';
}


}

/// @nodoc
abstract mixin class $OhlcvCopyWith<$Res>  {
  factory $OhlcvCopyWith(Ohlcv value, $Res Function(Ohlcv) _then) = _$OhlcvCopyWithImpl;
@useResult
$Res call({
 Decimal open, Decimal high, Decimal low, Decimal close, Decimal volume
});




}
/// @nodoc
class _$OhlcvCopyWithImpl<$Res>
    implements $OhlcvCopyWith<$Res> {
  _$OhlcvCopyWithImpl(this._self, this._then);

  final Ohlcv _self;
  final $Res Function(Ohlcv) _then;

/// Create a copy of Ohlcv
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? high = null,Object? low = null,Object? close = null,Object? volume = null,}) {
  return _then(_self.copyWith(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Decimal,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as Decimal,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Decimal,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [Ohlcv].
extension OhlcvPatterns on Ohlcv {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ohlcv value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ohlcv() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ohlcv value)  $default,){
final _that = this;
switch (_that) {
case _Ohlcv():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ohlcv value)?  $default,){
final _that = this;
switch (_that) {
case _Ohlcv() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Decimal open,  Decimal high,  Decimal low,  Decimal close,  Decimal volume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ohlcv() when $default != null:
return $default(_that.open,_that.high,_that.low,_that.close,_that.volume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Decimal open,  Decimal high,  Decimal low,  Decimal close,  Decimal volume)  $default,) {final _that = this;
switch (_that) {
case _Ohlcv():
return $default(_that.open,_that.high,_that.low,_that.close,_that.volume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Decimal open,  Decimal high,  Decimal low,  Decimal close,  Decimal volume)?  $default,) {final _that = this;
switch (_that) {
case _Ohlcv() when $default != null:
return $default(_that.open,_that.high,_that.low,_that.close,_that.volume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ohlcv extends Ohlcv {
   _Ohlcv({required this.open, required this.high, required this.low, required this.close, required this.volume}): super._();
  factory _Ohlcv.fromJson(Map<String, dynamic> json) => _$OhlcvFromJson(json);

@override final  Decimal open;
@override final  Decimal high;
@override final  Decimal low;
@override final  Decimal close;
@override final  Decimal volume;

/// Create a copy of Ohlcv
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OhlcvCopyWith<_Ohlcv> get copyWith => __$OhlcvCopyWithImpl<_Ohlcv>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OhlcvToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ohlcv&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,high,low,close,volume);

@override
String toString() {
  return 'Ohlcv(open: $open, high: $high, low: $low, close: $close, volume: $volume)';
}


}

/// @nodoc
abstract mixin class _$OhlcvCopyWith<$Res> implements $OhlcvCopyWith<$Res> {
  factory _$OhlcvCopyWith(_Ohlcv value, $Res Function(_Ohlcv) _then) = __$OhlcvCopyWithImpl;
@override @useResult
$Res call({
 Decimal open, Decimal high, Decimal low, Decimal close, Decimal volume
});




}
/// @nodoc
class __$OhlcvCopyWithImpl<$Res>
    implements _$OhlcvCopyWith<$Res> {
  __$OhlcvCopyWithImpl(this._self, this._then);

  final _Ohlcv _self;
  final $Res Function(_Ohlcv) _then;

/// Create a copy of Ohlcv
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? high = null,Object? low = null,Object? close = null,Object? volume = null,}) {
  return _then(_Ohlcv(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Decimal,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as Decimal,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Decimal,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
