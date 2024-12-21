import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Для работы с Firestore
import 'package:flutter/material.dart';
import 'package:fitness/screens/account_screen.dart';
import 'package:fitness/screens/login_screen.dart';
import 'package:fitness/screens/edit_profile_screen.dart'; // Экран для редактирования данных пользователя

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text("Добро пожаловать, для использования дневника войдите в профиль!" ))
            : StreamBuilder<DocumentSnapshot>(
                stream: _getUserDataStream(user.uid), // Используем Stream для обновлений в реальном времени
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Ошибка загрузки данных"));
                  }

                  if (snapshot.hasData) {
                    final userData = snapshot.data?.data() as Map<String, dynamic>?;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(userData?['photoUrl'] ?? 'https://via.placeholder.com/150'),
                          ),
                          const SizedBox(height: 10),
                          Text('Имя: ${userData?['name'] ?? "Не указано"}'),
                          Text('Вес: ${userData?['weight'] ?? "Не указан"}'),
                          Text('Процент жира: ${userData?['fatPercentage'] ?? "Не указан"}'),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text("Пользователь не найден"));
                },
              ),
      ),
    );
  }

  // Функция для создания потока данных пользователя из Firestore
  Stream<DocumentSnapshot> _getUserDataStream(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }
}
