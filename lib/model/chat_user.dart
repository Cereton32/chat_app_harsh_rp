class ChatUser {
  String? image;
  String? createdAt;
  String? name;
  String? about;
  String? lastActive;
  bool? isOnline;
  String? id;
  String? pushToken;
  String? email;

  ChatUser(
      { this.image,
        this.createdAt,
        this.name,
        this.about,
        this.lastActive,
        this.isOnline,
        this.id,
        this.pushToken,
        this.email});

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? " ";
    createdAt = json['created_at ']?? " ";
    name = json['name']?? " ";
    about = json['about']?? " ";
    lastActive = json['last_active']?? " ";
    isOnline = json['is_online']?? " ";
    id = json['id']?? " ";
    pushToken = json['push_token']?? " ";
    email = json['email']?? " ";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['created_at '] = this.createdAt;
    data['name'] = this.name;
    data['about'] = this.about;
    data['last_active'] = this.lastActive;
    data['is_online'] = this.isOnline;
    data['id'] = this.id;
    data['push_token'] = this.pushToken;
    data['email'] = this.email;
    return data;
  }
}
