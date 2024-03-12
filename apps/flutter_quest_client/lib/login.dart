// FlutterQuest
// A simple chatroom with certain game elements.
// Copyright (C) 2024 aspdotnut
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '/dio/account_dio.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {

      final String username = _usernameController.text;
      final String password = _passwordController.text;

      await logIn(username, password);
  }

  Future<void> _register() async {

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    await register(username, password);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: const Text('Login Page'),
      ),
      body: Center(

        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 600),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              Text(
                'Welcome to Flutter Quest!',
                style: Theme.of(context).textTheme.headline4,
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your username',
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your password',
                ),
              ),

              const SizedBox(height: 20),

              Row(

                children: [

                  ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login')),
                  const SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
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
