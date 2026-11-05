import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ornaments.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text(
            'Будут удалены очки, пройденные уровни, достижения и история вопросов дня. Имя игрока сохранится. Это действие нельзя отменить.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<GameProvider>().resetProgress();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Прогресс сброшен')));
    }
  }

  Future<void> _rename(BuildContext context) async {
    final game = context.read<GameProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: game.playerName),
    );
    if (name != null && name.trim().isNotEmpty) {
      await game.setName(name);
    }
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Православный путь',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Познавай веру. Изучай Священное Писание.',
      children: const [
        SizedBox(height: 14),
        Text(
          'Образовательная викторина об основах православной веры, Священном Писании, святых, церковной жизни и праздниках.\n\n'
          'Приложение работает без интернета, без рекламы и без регистрации. Вопросы составлены на основе Священного Писания и церковного предания. '
          'Даты праздников указаны по гражданскому календарю.',
          style: TextStyle(height: 1.4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final game = context.watch<GameProvider>();
    final gold = AppColors.goldFor(context);

    Widget tile(Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoldCard(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: child),
        );

    return AppScaffold(
      title: 'Настройки',
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            tile(SwitchListTile(
              secondary: Icon(Icons.volume_up_outlined, color: gold),
              title: const Text('Звуки'),
              subtitle: const Text('Сигналы при ответах'),
              value: s.sound,
              onChanged: s.setSound,
            )),
            tile(SwitchListTile(
              secondary: Icon(Icons.music_note_outlined, color: gold),
              title: const Text('Музыка'),
              subtitle: const Text('Тихий фоновый звук'),
              value: s.music,
              onChanged: s.setMusic,
            )),
            tile(SwitchListTile(
              secondary: Icon(Icons.dark_mode_outlined, color: gold),
              title: const Text('Тёмная тема'),
              subtitle: Text(s.darkTheme ? 'Включена' : 'Светлая тема'),
              value: s.darkTheme,
              onChanged: s.setDarkTheme,
            )),
            const SizedBox(height: 4),
            const OrnamentDivider(),
            const SizedBox(height: 16),
            tile(ListTile(
              leading: Icon(Icons.person_outline, color: gold),
              title: const Text('Имя игрока'),
              subtitle: Text(game.playerName),
              trailing: Icon(Icons.edit_outlined, color: gold),
              onTap: () => _rename(context),
            )),
            tile(ListTile(
              leading: Icon(Icons.info_outline, color: gold),
              title: const Text('О приложении'),
              onTap: () => _about(context),
            )),
            tile(ListTile(
              leading: const Icon(Icons.restart_alt, color: AppColors.error),
              title: const Text('Сбросить прогресс',
                  style: TextStyle(color: AppColors.error)),
              subtitle: const Text('Потребуется подтверждение'),
              onTap: () => _reset(context),
            )),
          ],
        ),
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Имя игрока'),
      content: TextField(
        controller: _c,
        autofocus: true,
        maxLength: 24,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(
            onPressed: () => Navigator.pop(context, _c.text),
            child: const Text('Сохранить')),
      ],
    );
  }
}
