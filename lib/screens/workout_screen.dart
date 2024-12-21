import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchWorkouts() async {
    final snapshot = await FirebaseFirestore.instance.collection('workouts').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список тренировок'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет доступных тренировок.'));
          }
          final workouts = snapshot.data!;
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout['name']),
                subtitle: Text(workout['description']),
              );
            },
          );
        },
      ),
    );
  }
}
