import 'package:flutter/material.dart';

import 'src/full_name_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/full_name_page': (context) => const FullNamePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Full Name Page'),
            onTap: () {
              Navigator.pushNamed(context, '/full_name_page');
            },
          ),
          // ListTile(
          //   title: const Text('Page 2'),
          //   onTap: () {
          //     Navigator.pushNamed(context, '/page2');
          //   },
          // ),
          // ListTile(
          //   title: const Text('Page 3'),
          //   onTap: () {
          //     Navigator.pushNamed(context, '/page3');
          //   },
          // ),
        ],
      ),
    );
  }
}
