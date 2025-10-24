class UserModel {
  String? id;
  String? email;
  String? role;
  String? firstName;
  String? lastName;
  String? fullName;
  DateTime? lastLogin;

  UserModel({
     this.id,
     this.email,
     this.role,
     this.firstName,
     this.lastName,
     this.fullName,
     this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print(json["id"]);
    return UserModel(
      id: json["id"],
      email: json["email"],
      role: json["role"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      fullName: json["fullName"],
      lastLogin: DateTime.parse(json["lastLogin"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "lastLogin": lastLogin!.toIso8601String(),
  };
}
