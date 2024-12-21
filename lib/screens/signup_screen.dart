import 'dart:io'; // Для работы с файлами
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/services/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Импортируем image_picker
import 'package:firebase_storage/firebase_storage.dart'; // Для работы с Firebase Storage

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  bool isHiddenPassword = true;
  bool isFirstStep = true; // Track whether we're in the first or second step of registration
  bool isPhotoStep = false; // Track whether we're in the photo upload step
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController = TextEditingController();
  TextEditingController nameTextInputController = TextEditingController();
  TextEditingController weightTextInputController = TextEditingController();
  TextEditingController fatPercentageTextInputController = TextEditingController();

  String gender = 'male'; // Default gender
  XFile? pickedFile; // Объявляем переменную для выбранного изображения

  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Создаем экземпляр ImagePicker

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();
    nameTextInputController.dispose();
    weightTextInputController.dispose();
    fatPercentageTextInputController.dispose();
    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> pickImage() async {
    try {
      final XFile? selectedFile = await _picker.pickImage(source: ImageSource.gallery); // Открытие галереи
      if (selectedFile != null) {
        setState(() {
          pickedFile = selectedFile; // Сохраняем выбранный файл
        });
      }
    } catch (e) {
      print('Ошибка при выборе изображения: $e');
    }
  }

  Future<void> signUp() async {
    final navigator = Navigator.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (isFirstStep) {
      // Step 1: Collect user data (name, gender, weight, fat percentage)
      setState(() {
        isFirstStep = false;
        isPhotoStep = true; // Переходим на шаг добавления фото
      });
      return;
    }

    if (isPhotoStep) {
      // Step 2: If photo step, save photo and go to email/password step
      setState(() {
        isPhotoStep = false; // Переходим к шагу ввода почты и пароля
      });
      return;
    }

    // Step 3: Sign up the user with email and password
    if (passwordTextInputController.text != passwordTextRepeatInputController.text) {
      SnackBarService.showSnackBar(
        context,
        'Пароли должны совпадать',
        true,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );

      String? imageUrl;

      // Если фото выбрано, загружаем его в Firebase Storage
      if (pickedFile != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('user_images/${userCredential.user!.uid}.jpg');
        await imageRef.putFile(File(pickedFile!.path)); // Загружаем файл
        imageUrl = await imageRef.getDownloadURL(); // Получаем ссылку на загруженное изображение
      }

      // Сохраняем данные пользователя в Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': nameTextInputController.text.trim(),
        'gender': gender,
        'weight': double.tryParse(weightTextInputController.text.trim()) ?? 0.0,
        'fatPercentage': double.tryParse(fatPercentageTextInputController.text.trim()) ?? 0.0,
        'email': userCredential.user!.email,
        'photoUrl': imageUrl ?? '', // Сохраняем URL изображения или пустую строку
        'createdAt': FieldValue.serverTimestamp(),
      });

      navigator.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'email-already-in-use') {
        SnackBarService.showSnackBar(
          context,
          'Такой Email уже используется, повторите попытку с использованием другого Email',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Зарегистрироваться'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Step 1: Input fields for name, gender, weight, and fat percentage
              if (isFirstStep) ...[
                TextFormField(
                  controller: nameTextInputController,
                  validator: (value) => value != null && value.isEmpty ? 'Введите имя' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите имя',
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => gender = 'male'),
                      child: Icon(
                        Icons.male,
                        color: gender == 'male' ? Colors.blue : Colors.grey,
                        size: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => gender = 'female'),
                      child: Icon(
                        Icons.female,
                        color: gender == 'female' ? Colors.pink : Colors.grey,
                        size: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: weightTextInputController,
                  keyboardType: TextInputType.number,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Введите ваш вес'
                      : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите ваш вес',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: fatPercentageTextInputController,
                  keyboardType: TextInputType.number,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Введите процент жира'
                      : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите процент жира',
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: signUp,
                  child: const Center(child: Text('Далее')),
                ),
              ] else if (isPhotoStep) ...[
                // Step 2: Upload photo if not selected
                if (pickedFile == null) ...[
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                if (pickedFile != null) ...[
                  Image.file(
                    File(pickedFile!.path),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 30),
                ],
                ElevatedButton(
                  onPressed: signUp,
                  child: const Center(child: Text('Далее')),
                ),
              ] else ...[
                // Step 3: Input email and password
                TextFormField(
                  controller: emailTextInputController,
                  validator: (value) => !EmailValidator.validate(value ?? '') ? 'Введите корректный email' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите Email',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordTextInputController,
                  obscureText: isHiddenPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Введите пароль',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHiddenPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: togglePasswordView,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordTextRepeatInputController,
                  obscureText: isHiddenPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Повторите пароль',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHiddenPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: togglePasswordView,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: signUp,
                  child: const Center(child: Text('Завершить регистрацию')),
                ),
              ],
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Войти',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
