import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ornaments.dart';

/// Первый запуск: знакомство. Регистрация не нужна — только имя для приветствия.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<GameProvider>().setName(name);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ContentWidth(
            maxWidth: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 110)),
                const SizedBox(height: 22),
                Text('Православный путь',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(context, size: 30)),
                const SizedBox(height: 8),
                Text('Познавай веру. Изучай Священное Писание.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(200))),
                const SizedBox(height: 22),
                const OrnamentDivider(),
                const SizedBox(height: 26),
                Text('Как вас зовут?',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(context, size: 20)),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  maxLength: 24,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Ваше имя',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _submit, child: const Text('Продолжить')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
