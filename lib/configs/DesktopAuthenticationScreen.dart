import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

const _key = "desktopAuthPassword";

Future<bool> needDesktopAuthentication() async {
  return await methods.loadProperty(_key) != "";
}

class VerifyPassword extends StatefulWidget {
  const VerifyPassword({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(child: Container()),
              TextField(
                decoration: const InputDecoration(labelText: "当前密码"),
                onChanged: (value) {
                  _password = value;
                },
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String savedPassword = await methods.loadProperty(_key);
                  if (_password == savedPassword) {
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("密码错误")));
                  }
                },
                child: const Text("确定"),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class SetPassword extends StatefulWidget {
  const SetPassword({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  String _password = "";
  String _password2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text(
                "密码初始化",
                style: TextStyle(
                  height: 18,
                ),
              ),
              Container(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "密码"),
                onChanged: (value) {
                  _password = value;
                },
              ),
              Container(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "再次输入密码"),
                onChanged: (value) {
                  _password2 = value;
                },
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("取消"),
                  ),
                  Container(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_password != _password2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("两次输入的密码不一致")));
                          return;
                        }
                        await methods.saveProperty(_key, _password);
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("设置密码"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
