class UserUiModel {
  final String avatarUrl;
  final String name;
  final String description;

  UserUiModel({
    required this.avatarUrl,
    required this.name,
    required this.description,
  });

  static List<UserUiModel> fakeUsers() => List.generate(
      3,
      (index) => UserUiModel(
            avatarUrl:
                'https://upload.wikimedia.org/wikipedia/commons/e/ee/Sample_abc.jpg',
            name: 'Repo Test $index',
            description: 'This is Test Repo $index',
          )).toList();
}
