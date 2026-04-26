import '../../domain/entities/stop.dart';

class StopModel extends Stop {
  StopModel({
    required super.name,
    required super.address,
    required super.image,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      name: json['name'],
      address: json['address'],
      image: json['image']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'image' : image,
    };
  }
}