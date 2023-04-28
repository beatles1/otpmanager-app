import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../main.dart' show DarkThemeProvider, objectBox;
import '../models/user.dart';
import "../routing/constants.dart";
import '../utils/toast.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.updateHome}) : super(key: key);

  final Function updateHome;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _userBox = objectBox.store.box<User>();
  late User _user;
  PackageInfo _packageInfo = PackageInfo(
    appName: "Unknown",
    packageName: "Unknown",
    version: "Unknown",
    buildNumber: "Unknown",
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    _user = _userBox.getAll()[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: const Text("Nextcloud server"),
                trailing: Text(
                  _user.url,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _user.url));
                  showToast("URL copied");
                },
              ),
              ListTile(
                title: const Text("Copy code with tap"),
                trailing: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: _user.copyWithTap,
                  onChanged: (value) => setState(() {
                    _user.copyWithTap = value!;
                    _userBox.put(_user);
                    widget.updateHome();
                  }),
                ),
                onTap: () => setState(() {
                  _user.copyWithTap = !_user.copyWithTap;
                  _userBox.put(_user);
                  widget.updateHome();
                }),
              ),
              ListTile(
                  title: const Text("Dark theme"),
                  trailing: Checkbox(
                    activeColor: Theme.of(context).primaryColor,
                    value: themeChange.darkTheme,
                    onChanged: (value) => themeChange.darkTheme = value!,
                  ),
                  onTap: () => themeChange.darkTheme = !themeChange.darkTheme),
              ListTile(
                title: _user.pin != null && _user.pin != ""
                    ? const Text("Change pin")
                    : const Text("Set pin"),
                trailing: const Text(
                  "⬤⬤⬤⬤⬤⬤",
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  NavigationService().navigateTo(pinRoute, arguments: {
                    "toEdit": _user.pin != null && _user.pin != "",
                  });
                },
              ),
              ListTile(
                title: const Text("Version number"),
                trailing: Text(
                  "${_packageInfo.version}.${_packageInfo.buildNumber}",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
