// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsModelAdapter extends TypeAdapter<UserSettingsModel> {
  @override
  final int typeId = 2;

  @override
  UserSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsModel(
      themeMode: fields[0] as String,
      notificationsEnabled: fields[1] as bool,
      notificationTime: fields[2] as String,
      skipWeekends: fields[3] as bool,
      isPremium: fields[4] as bool,
      premiumPurchasedAt: fields[5] as DateTime?,
      language: fields[6] as String,
      isFirstLaunch: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.notificationTime)
      ..writeByte(3)
      ..write(obj.skipWeekends)
      ..writeByte(4)
      ..write(obj.isPremium)
      ..writeByte(5)
      ..write(obj.premiumPurchasedAt)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.isFirstLaunch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
