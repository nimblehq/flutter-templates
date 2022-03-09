class UserUiModel {
  final String avatarUrl;
  final String name;
  final String description;

  UserUiModel({
    required this.avatarUrl,
    required this.name,
    required this.description,
  });

  static List<UserUiModel> fakeData() {
    return [
      UserUiModel(
        avatarUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/ee/Sample_abc.jpg',
        name: 'Repo Test 1',
        description: 'This is Test Repo 1',
      ),
      UserUiModel(
        avatarUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/ee/Sample_abc.jpg',
        name: 'Repo Test 2',
        description: 'This is Test Repo 2',
      ),
      UserUiModel(
        avatarUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/ee/Sample_abc.jpg',
        name: 'Repo Test 3',
        description: 'This is Test Repo 3',
      ),
    ];
  }
}
