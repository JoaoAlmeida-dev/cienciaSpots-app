class FeedbackFormResult {
  FeedbackFormResult({
    required this.email,
    required this.name,
    required this.description,
  });

  final String email;
  final String name;
  final String description;

  @override
  String toString() {
    return 'FeedbackFormResult{email: $email, name: $name, description: $description}';
  }

  factory FeedbackFormResult.fromJson(Map<String, dynamic> json) =>
      FeedbackFormResult(
        email: json["email"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "description": description,
    };
  }
}
