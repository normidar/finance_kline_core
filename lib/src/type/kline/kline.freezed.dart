// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Kline {

 Decimal get open; Decimal get high; Decimal get low; Decimal get close;
/// Create a copy of Kline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlineCopyWith<Kline> get copyWith => _$KlineCopyWithImpl<Kline>(this as Kline, _$identity);

  /// Serializes this Kline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Kline&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,high,low,close);

@override
String toString() {
  return 'Kline(open: $open, high: $high, low: $low, close: $close)';
}


}

/// @nodoc
abstract mixin class $KlineCopyWith<$Res>  {
  factory $KlineCopyWith(Kline value, $Res Function(Kline) _then) = _$KlineCopyWithImpl;
@useResult
$Res call({
 Decimal open, Decimal high, Decimal low, Decimal close
});




}
/// @nodoc
class _$KlineCopyWithImpl<$Res>
    implements $KlineCopyWith<$Res> {
  _$KlineCopyWithImpl(this._self, this._then);

  final Kline _self;
  final $Res Function(Kline) _then;

/// Create a copy of Kline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? high = null,Object? low = null,Object? close = null,}) {
  return _then(_self.copyWith(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Decimal,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as Decimal,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [Kline].
extension KlinePatterns on Kline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Kline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Kline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Kline value)  $default,){
final _that = this;
switch (_that) {
case _Kline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Kline value)?  $default,){
final _that = this;
switch (_that) {
case _Kline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Decimal open,  Decimal high,  Decimal low,  Decimal close)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Kline() when $default != null:
return $default(_that.open,_that.high,_that.low,_that.close);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Decimal open,  Decimal high,  Decimal low,  Decimal close)  $default,) {final _that = this;
switch (_that) {
case _Kline():
return $default(_that.open,_that.high,_that.low,_that.close);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Decimal open,  Decimal high,  Decimal low,  Decimal close)?  $default,) {final _that = this;
switch (_that) {
case _Kline() when $default != null:
return $default(_that.open,_that.high,_that.low,_that.close);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Kline extends Kline {
   _Kline({required this.open, required this.high, required this.low, required this.close}): super._();
  factory _Kline.fromJson(Map<String, dynamic> json) => _$KlineFromJson(json);

@override final  Decimal open;
@override final  Decimal high;
@override final  Decimal low;
@override final  Decimal close;

/// Create a copy of Kline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlineCopyWith<_Kline> get copyWith => __$KlineCopyWithImpl<_Kline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Kline&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,high,low,close);

@override
String toString() {
  return 'Kline(open: $open, high: $high, low: $low, close: $close)';
}


}

/// @nodoc
abstract mixin class _$KlineCopyWith<$Res> implements $KlineCopyWith<$Res> {
  factory _$KlineCopyWith(_Kline value, $Res Function(_Kline) _then) = __$KlineCopyWithImpl;
@override @useResult
$Res call({
 Decimal open, Decimal high, Decimal low, Decimal close
});




}
/// @nodoc
class __$KlineCopyWithImpl<$Res>
    implements _$KlineCopyWith<$Res> {
  __$KlineCopyWithImpl(this._self, this._then);

  final _Kline _self;
  final $Res Function(_Kline) _then;

/// Create a copy of Kline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? high = null,Object? low = null,Object? close = null,}) {
  return _then(_Kline(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Decimal,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as Decimal,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
