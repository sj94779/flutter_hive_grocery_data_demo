import 'package:hive/hive.dart';

part 'data_model.g.dart';
// to store custom objects in hive box , we need to register adapter
// flutter packages pub run build_runner build

@HiveType(typeId: 0)
class DataModel extends HiveObject{
  @HiveField(0)
  final String? item;
  @HiveField(1)
  final int? quantity;
  @HiveField(2)
  final String? metrics;

  DataModel({this.item, this.quantity,this.metrics});
}