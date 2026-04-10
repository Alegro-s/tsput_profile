import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/student_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.student;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Профиль')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showSettingsMenu(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка профиля
            ProfileCard(
              onLogoutRequested: () {
                _showLogoutConfirmation(context);
              },
            ),

            SizedBox(height: 20),

            // Основная информация
            Text(
              'Основная информация',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 16),

            _buildInfoCard(
              title: 'Специальность',
              value: student.specialty,
              icon: Icons.school_outlined,
            ),

            _buildInfoCard(
              title: 'Дата поступления',
              value: _formatDate(student.admissionDate),
              icon: Icons.date_range_outlined,
            ),

            _buildInfoCard(
              title: 'Дата выпуска',
              value: _formatDate(student.graduationDate),
              icon: Icons.school,
            ),

            SizedBox(height: 20),

            // Контактная информация
            Text(
              'Контактная информация',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 16),

            _buildInfoCard(
              title: 'Email',
              value: student.email,
              icon: Icons.email_outlined,
            ),

            _buildInfoCard(
              title: 'Телефон',
              value: student.phone,
              icon: Icons.phone_outlined,
            ),

            _buildInfoCard(
              title: 'Адрес',
              value: student.address,
              icon: Icons.location_on_outlined,
            ),
            if (student.additionalInfo['city'] != null)
              _buildInfoCard(
                title: 'Город',
                value: student.additionalInfo['city'].toString(),
                icon: Icons.location_city_outlined,
              ),
            if (student.additionalInfo['timezone'] != null)
              _buildInfoCard(
                title: 'Часовой пояс',
                value: student.additionalInfo['timezone'].toString(),
                icon: Icons.schedule,
              ),

            SizedBox(height: 20),

            // Дополнительная информация
            Text(
              'Дополнительная информация',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 16),

            if (student.additionalInfo['birthDate'] != null)
              _buildInfoCard(
                title: 'Дата рождения',
                value: student.additionalInfo['birthDate'].toString(),
                icon: Icons.cake_outlined,
              ),
            if (student.additionalInfo['studentStatus'] != null)
              _buildInfoCard(
                title: 'Статус обучающегося',
                value: student.additionalInfo['studentStatus'].toString(),
                icon: Icons.verified_user_outlined,
              ),
            if (student.additionalInfo['trainingLevel'] != null)
              _buildInfoCard(
                title: 'Уровень подготовки',
                value: student.additionalInfo['trainingLevel'].toString(),
                icon: Icons.workspace_premium_outlined,
              ),
            if (student.additionalInfo['profile'] != null)
              _buildInfoCard(
                title: 'Профиль',
                value: student.additionalInfo['profile'].toString(),
                icon: Icons.account_tree_outlined,
              ),
            if (student.additionalInfo['recordBook'] != null)
              _buildInfoCard(
                title: 'Номер зачетной книжки',
                value: student.additionalInfo['recordBook'].toString(),
                icon: Icons.badge_outlined,
              ),

            Row(
              children: [
                Expanded(
                  child: _buildAdditionalCard(
                    title: 'Стипендия',
                    value: '${student.additionalInfo['scholarship'] ?? 0} ₽',
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAdditionalCard(
                    title: 'Общежитие',
                    value: student.additionalInfo['dormitory'] ?? '-',
                    icon: Icons.home_outlined,
                  ),
                ),
              ],
            ),

            // Средний балл и экзамены
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAdditionalCard(
                    title: 'Средний балл',
                    value: student.additionalInfo['averageGrade']?.toString() ?? '0.0',
                    icon: Icons.bar_chart,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAdditionalCard(
                    title: 'Экзаменов',
                    value: student.additionalInfo['examsCount']?.toString() ?? '0',
                    icon: Icons.assignment,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Выйти',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context); // Закрыть меню
                  _showLogoutConfirmation(context);
                },
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтверждение выхода'),
          content: Text('Вы уверены, что хотите выйти из системы?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => _logout(context),
              child: Text('Выйти', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Закрываем диалог
    Navigator.of(context).pop();

    // Вызываем logout из AuthProvider
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    // Очищаем данные студента
    final studentProvider = context.read<StudentProvider>();
    studentProvider.clearStudentData();

    // Переходим на экран логина, очищая историю навигации
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black87, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}