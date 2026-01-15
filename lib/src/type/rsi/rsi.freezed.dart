// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rsi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Rsi {

/// RSI値（0〜100の範囲）
 double get value;
/// Create a copy of Rsi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsiCopyWith<Rsi> get copyWith => _$RsiCopyWithImpl<Rsi>(this as Rsi, _$identity);

  /// Serializes this Rsi to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rsi&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'Rsi(value: $value)';
}


}

/// @nodoc
abstract mixin class $RsiCopyWith<$Res>  {
  factory $RsiCopyWith(Rsi value, $Res Function(Rsi) _then) = _$RsiCopyWithImpl;
@useResult
$Res call({
 double value
});




}
/// @nodoc
class _$RsiCopyWithImpl<$Res>
    implements $RsiCopyWith<$Res> {
  _$RsiCopyWithImpl(this._self, this._then);

  final Rsi _self;
  final $Res Function(Rsi) _then;

/// Create a copy of Rsi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Rsi].
extension RsiPatterns on Rsi {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rsi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rsi() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rsi value)  $default,){
final _that = this;
switch (_that) {
case _Rsi():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rsi value)?  $default,){
final _that = this;
switch (_that) {
case _Rsi() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rsi() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double value)  $default,) {final _that = this;
switch (_that) {
case _Rsi():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double value)?  $default,) {final _that = this;
switch (_that) {
case _Rsi() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rsi extends Rsi {
   _Rsi({required this.value}): super._();
  factory _Rsi.fromJson(Map<String, dynamic> json) => _$RsiFromJson(json);

/// RSI値（0〜100の範囲）
@override final  double value;

/// Create a copy of Rsi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RsiCopyWith<_Rsi> get copyWith => __$RsiCopyWithImpl<_Rsi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RsiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rsi&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'Rsi(value: $value)';
}


}

/// @nodoc
abstract mixin class _$RsiCopyWith<$Res> implements $RsiCopyWith<$Res> {
  factory _$RsiCopyWith(_Rsi value, $Res Function(_Rsi) _then) = __$RsiCopyWithImpl;
@override @useResult
$Res call({
 double value
});




}
/// @nodoc
class __$RsiCopyWithImpl<$Res>
    implements _$RsiCopyWith<$Res> {
  __$RsiCopyWithImpl(this._self, this._then);

  final _Rsi _self;
  final $Res Function(_Rsi) _then;

/// Create a copy of Rsi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_Rsi(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
