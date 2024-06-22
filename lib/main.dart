import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio_connectivity_app/interceptor/dio_connectivity_request_retrier.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'interceptor/retry_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  bool _isLoading = false;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    // пакет для добавления интерспектора для повторной отправки запроса при отсуствии интернет соединения ->
    // _dio.interceptors.add(RetryInterceptor(dio: _dio, logPrint: log));
    // в реальной работе будет реализовано в get_it классе ->
    _dio.interceptors.add(RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
            connectivity: Connectivity(), dio: Dio())));
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response =
          await _dio.get('https://jsonplaceholder.typicode.com/users');
      setState(() {
        _users = response.data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _fetchUsers,
            child: const Text('Load Users'),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      var user = _users[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailScreen(user: user),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  final dynamic user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user['username']}'),
            Text('Email: ${user['email']}'),
            Text('Phone: ${user['phone']}'),
            Text('Website: ${user['website']}'),
            const SizedBox(height: 20),
            const Text('Address:'),
            Text('Street: ${user['address']['street']}'),
            Text('Suite: ${user['address']['suite']}'),
            Text('City: ${user['address']['city']}'),
            Text('Zipcode: ${user['address']['zipcode']}'),
            const SizedBox(height: 20),
            const Text('Company:'),
            Text('Name: ${user['company']['name']}'),
            Text('CatchPhrase: ${user['company']['catchPhrase']}'),
            Text('BS: ${user['company']['bs']}'),
          ],
        ),
      ),
    );
  }
}
