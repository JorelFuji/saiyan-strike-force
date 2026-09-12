// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState()';
}


}

/// @nodoc
class $SettingsStateCopyWith<$Res>  {
$SettingsStateCopyWith(SettingsState _, $Res Function(SettingsState) __);
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsInitial value)?  initial,TResult Function( SettingsLoading value)?  loading,TResult Function( SettingsLoaded value)?  loaded,TResult Function( SettingsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial(_that);case SettingsLoading() when loading != null:
return loading(_that);case SettingsLoaded() when loaded != null:
return loaded(_that);case SettingsError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsInitial value)  initial,required TResult Function( SettingsLoading value)  loading,required TResult Function( SettingsLoaded value)  loaded,required TResult Function( SettingsError value)  error,}){
final _that = this;
switch (_that) {
case SettingsInitial():
return initial(_that);case SettingsLoading():
return loading(_that);case SettingsLoaded():
return loaded(_that);case SettingsError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsInitial value)?  initial,TResult? Function( SettingsLoading value)?  loading,TResult? Function( SettingsLoaded value)?  loaded,TResult? Function( SettingsError value)?  error,}){
final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial(_that);case SettingsLoading() when loading != null:
return loading(_that);case SettingsLoaded() when loaded != null:
return loaded(_that);case SettingsError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( bool isDarkMode)?  loaded,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial();case SettingsLoading() when loading != null:
return loading();case SettingsLoaded() when loaded != null:
return loaded(_that.isDarkMode);case SettingsError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( bool isDarkMode)  loaded,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case SettingsInitial():
return initial();case SettingsLoading():
return loading();case SettingsLoaded():
return loaded(_that.isDarkMode);case SettingsError():
return error(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( bool isDarkMode)?  loaded,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial();case SettingsLoading() when loading != null:
return loading();case SettingsLoaded() when loaded != null:
return loaded(_that.isDarkMode);case SettingsError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SettingsInitial implements SettingsState {
  const SettingsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState.initial()';
}


}




/// @nodoc


class SettingsLoading implements SettingsState {
  const SettingsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState.loading()';
}


}




/// @nodoc


class SettingsLoaded implements SettingsState {
  const SettingsLoaded({required this.isDarkMode});
  

 final  bool isDarkMode;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsLoadedCopyWith<SettingsLoaded> get copyWith => _$SettingsLoadedCopyWithImpl<SettingsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsLoaded&&(identical(other.isDarkMode, isDarkMode) || other.isDarkMode == isDarkMode));
}


@override
int get hashCode => Object.hash(runtimeType,isDarkMode);

@override
String toString() {
  return 'SettingsState.loaded(isDarkMode: $isDarkMode)';
}


}

/// @nodoc
abstract mixin class $SettingsLoadedCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $SettingsLoadedCopyWith(SettingsLoaded value, $Res Function(SettingsLoaded) _then) = _$SettingsLoadedCopyWithImpl;
@useResult
$Res call({
 bool isDarkMode
});




}
/// @nodoc
class _$SettingsLoadedCopyWithImpl<$Res>
    implements $SettingsLoadedCopyWith<$Res> {
  _$SettingsLoadedCopyWithImpl(this._self, this._then);

  final SettingsLoaded _self;
  final $Res Function(SettingsLoaded) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isDarkMode = null,}) {
  return _then(SettingsLoaded(
isDarkMode: null == isDarkMode ? _self.isDarkMode : isDarkMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SettingsError implements SettingsState {
  const SettingsError({required this.failure});
  

 final  Failure failure;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsErrorCopyWith<SettingsError> get copyWith => _$SettingsErrorCopyWithImpl<SettingsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SettingsState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SettingsErrorCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $SettingsErrorCopyWith(SettingsError value, $Res Function(SettingsError) _then) = _$SettingsErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$SettingsErrorCopyWithImpl<$Res>
    implements $SettingsErrorCopyWith<$Res> {
  _$SettingsErrorCopyWithImpl(this._self, this._then);

  final SettingsError _self;
  final $Res Function(SettingsError) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SettingsError(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res> get failure {
  
  return $FailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
