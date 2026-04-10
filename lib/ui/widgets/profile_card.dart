import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/student_provider.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback? onLogoutRequested;

  const ProfileCard({Key? key, this.onLogoutRequested}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.student;

    if (student == null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3EC9C0),
            Color(0xFF1F8A82),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey[300],
            backgroundImage: student.avatarUrl != null
                ? NetworkImage(student.avatarUrl!)
                : null,
            child: student.avatarUrl == null
                ? Icon(
              Icons.person,
              size: 36,
              color: Colors.grey[600],
            )
                : null,
          ),
          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${student.group} | ${student.faculty}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Курс ${student.course}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {
                  if (onLogoutRequested != null) {
                    onLogoutRequested!();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh_outlined, color: Colors.white),
                onPressed: () {
                  studentProvider.loadStudentData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}