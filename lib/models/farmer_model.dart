class Farmer {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final FarmLocation location;
  final List<Farm> farms;
  final DateTime registrationDate;
  final String? profileImagePath;

  Farmer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.location,
    required this.farms,
    required this.registrationDate,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'location': location.toJson(),
      'farms': farms.map((farm) => farm.toJson()).toList(),
      'registrationDate': registrationDate.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      location: FarmLocation.fromJson(json['location']),
      farms:
          (json['farms'] as List).map((farm) => Farm.fromJson(farm)).toList(),
      registrationDate: DateTime.parse(json['registrationDate']),
      profileImagePath: json['profileImagePath'],
    );
  }
}

class FarmLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String country;

  FarmLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  factory FarmLocation.fromJson(Map<String, dynamic> json) {
    return FarmLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
    );
  }
}

class Farm {
  final String id;
  final String name;
  final double area; // in acres
  final String soilType;
  final List<Crop> crops;
  final List<Livestock> livestock;
  final FarmLocation location;
  final List<FarmBoundary> boundaries;

  Farm({
    required this.id,
    required this.name,
    required this.area,
    required this.soilType,
    required this.crops,
    required this.livestock,
    required this.location,
    required this.boundaries,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'soilType': soilType,
      'crops': crops.map((crop) => crop.toJson()).toList(),
      'livestock': livestock.map((animal) => animal.toJson()).toList(),
      'location': location.toJson(),
      'boundaries': boundaries.map((boundary) => boundary.toJson()).toList(),
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
      area: json['area'],
      soilType: json['soilType'],
      crops:
          (json['crops'] as List).map((crop) => Crop.fromJson(crop)).toList(),
      livestock: (json['livestock'] as List)
          .map((animal) => Livestock.fromJson(animal))
          .toList(),
      location: FarmLocation.fromJson(json['location']),
      boundaries: (json['boundaries'] as List)
          .map((boundary) => FarmBoundary.fromJson(boundary))
          .toList(),
    );
  }
}

class FarmBoundary {
  final double latitude;
  final double longitude;

  FarmBoundary({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory FarmBoundary.fromJson(Map<String, dynamic> json) {
    return FarmBoundary(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class Crop {
  final String id;
  final String name;
  final String variety;
  final DateTime plantingDate;
  final DateTime? harvestDate;
  final double area; // in acres
  final String status; // planted, growing, harvested
  final int? expectedYield;

  Crop({
    required this.id,
    required this.name,
    required this.variety,
    required this.plantingDate,
    this.harvestDate,
    required this.area,
    required this.status,
    this.expectedYield,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'plantingDate': plantingDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'area': area,
      'status': status,
      'expectedYield': expectedYield,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      variety: json['variety'],
      plantingDate: DateTime.parse(json['plantingDate']),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'])
          : null,
      area: json['area'],
      status: json['status'],
      expectedYield: json['expectedYield'],
    );
  }
}

class Livestock {
  final String id;
  final String type; // cow, buffalo, goat, chicken, etc.
  final String breed;
  final int count;
  final String healthStatus;
  final DateTime lastVaccination;
  final String? notes;

  Livestock({
    required this.id,
    required this.type,
    required this.breed,
    required this.count,
    required this.healthStatus,
    required this.lastVaccination,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'breed': breed,
      'count': count,
      'healthStatus': healthStatus,
      'lastVaccination': lastVaccination.toIso8601String(),
      'notes': notes,
    };
  }

  factory Livestock.fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'],
      type: json['type'],
      breed: json['breed'],
      count: json['count'],
      healthStatus: json['healthStatus'],
      lastVaccination: DateTime.parse(json['lastVaccination']),
      notes: json['notes'],
    );
  }
}
