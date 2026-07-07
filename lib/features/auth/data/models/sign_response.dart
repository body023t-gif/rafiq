class SignResponse {
  final String? id;
  final String? email;
  final String? fullName;
  final String? phone;
  final List<String>? roles;
  final String? profilePictureUrl;
  final String? token;
  final String? refreshToken;
  final String? tokenType;
  final dynamic expiresIn;

  SignResponse({
    this.id,
    this.email,
    this.fullName,
    this.phone,
    this.roles,
    this.profilePictureUrl,
    this.token,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (roles != null) 'roles': roles,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (tokenType != null) 'tokenType': tokenType,
      if (expiresIn != null) 'expiresIn': expiresIn,
    };
  }

  factory SignResponse.fromJson(Map<String, dynamic> json) {
    return SignResponse(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      phone: json['phone']?.toString(),
      roles: json['roles'] is List
          ? (json['roles'] as List).map((e) => e.toString()).toList()
          : null,
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      token: json['token']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      tokenType: json['tokenType']?.toString(),
      expiresIn: json['expiresIn'],
    );
  }
}
