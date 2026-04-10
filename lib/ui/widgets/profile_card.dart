import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers/student_provider.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onRefreshPressed;

  const ProfileCard({
    super.key,
    this.onSettingsPressed,
    this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.student;

    if (student == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.surfaceMuted,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppConstants.terracotta),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.blockBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppConstants.blockBlackElevated,
            backgroundImage:
                student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
            child: student.avatarUrl == null
                ? Icon(PhosphorIconsRegular.user, size: 32, color: AppConstants.onBlockSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    color: AppConstants.onBlock,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.group} · ${student.faculty}',
                  style: const TextStyle(
                    color: AppConstants.onBlockSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Курс ${student.course}',
                  style: const TextStyle(
                    color: AppConstants.onBlockSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onSettingsPressed != null)
                IconButton(
                  icon: Icon(PhosphorIconsRegular.gear, color: AppConstants.onBlock),
                  onPressed: onSettingsPressed,
                ),
              IconButton(
                icon: Icon(PhosphorIconsRegular.arrowsClockwise, color: AppConstants.onBlock),
                onPressed: onRefreshPressed ?? () => studentProvider.loadStudentData(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
