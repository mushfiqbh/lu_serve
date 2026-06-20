class BusSchedule {
  final String id;
  final String busNumber;
  final String route;
  final String departureTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusSchedule({
    required this.id,
    required this.busNumber,
    required this.route,
    required this.departureTime,
    this.createdAt,
    this.updatedAt,
  });

  factory BusSchedule.fromMap(Map<String, dynamic> map) {
    return BusSchedule(
      id: map['id'] as String,
      busNumber: map['bus_number'] as String,
      route: map['route'] as String,
      departureTime: map['departure_time'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bus_number': busNumber,
      'route': route,
      'departure_time': departureTime,
    };
  }
}
