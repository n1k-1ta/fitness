import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Для работы с Firestore
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController fatPercentageController = TextEditingController();

  // Функция для обновления профиля пользователя
  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Обновление имени пользователя
        await user?.updateDisplayName(nameController.text);
        // Обновление данных в Firestore
        await FirebaseFirestore.instance
            .collection('users') // Коллекция пользователей
            .doc(user?.uid) // Используем UID пользователя для обновления документа
            .update({
          'name': nameController.text,
          'weight': weightController.text,
          'fatPercentage': fatPercentageController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные успешно обновлены!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка обновления данных')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Поле для имени
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите ваше имя';
                  }
                  return null;
                },
              ),
              // Поле для веса
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Вес'),
                keyboardType: TextInputType.number, // Устанавливаем тип клавиатуры как число
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите ваш вес';
                  }
                  return null;
                },
              ),
              // Поле для процента жира
              TextFormField(
                controller: fatPercentageController,
                decoration: const InputDecoration(labelText: 'Процент жира'),
                keyboardType: TextInputType.number, // Устанавливаем тип клавиатуры как число
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите процент жира';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Кнопка для сохранения изменений
              ElevatedButton(
                onPressed: updateProfile,
                child: const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
