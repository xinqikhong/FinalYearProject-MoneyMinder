class User {
  String? id;
  String? name;
  String? email;
  String? regdate;
  String? otp;
  String? phone;
  String? address;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.regdate,
      required this.otp,
      required this.phone,
      required this.address,
      });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    regdate = json['regdate'];
    otp = json['otp'];
    phone = json['phone'];
    address = json['address'];
  }
}