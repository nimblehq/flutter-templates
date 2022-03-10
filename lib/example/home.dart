import 'package:flutter/material.dart';
import 'package:flutter_templates/example/model/ui/user_ui_model.dart';
import 'package:flutter_templates/gen/assets.gen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Home extends StatelessWidget {
  final String initialRoute;

  Home({this.initialRoute = '/home'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data?.appName ?? "")
                  : SizedBox.shrink();
            }),
      ),
      body: Column(
        children: [
          SizedBox(height: 24),
          FractionallySizedBox(
            widthFactor: 0.5,
            child: Image.asset(
              Assets.images.nimbleLogo.path,
              fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(height: 24),
          Expanded(child: _buildUsers())
        ],
      ),
    );
  }

  Widget _buildUsers() {
    final list = UserUiModel.fakeUsers();
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          leading: Image.network(
            item.avatarUrl,
            width: 52,
            height: 52,
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            item.description,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => Divider(),
      itemCount: list.length,
      padding: EdgeInsets.all(16),
    );
  }
}
