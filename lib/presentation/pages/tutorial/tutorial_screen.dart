import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/onboarding_service.dart';
import '../../../injection.dart';

/// Carrossel de boas-vindas com mini-demonstrações animadas dos principais
/// recursos do app. Aparece automaticamente na primeira execução e também pode
/// ser reaberto em Configurações ("Ver tutorial").
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, this.fromSettings = false});

  /// Quando aberto a partir de Configurações, ao concluir volta (`pop`) em vez
  /// de navegar para a home.
  final bool fromSettings;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _anim;
  int _page = 0;

  late final List<_SlideData> _slides = [
    _SlideData(
      title: AppStrings.tutorialWelcomeTitle,
      description: AppStrings.tutorialWelcomeDesc,
      demoBuilder: (a) => _WelcomeDemo(animation: a),
    ),
    _SlideData(
      title: AppStrings.tutorialAddTitle,
      description: AppStrings.tutorialAddDesc,
      demoBuilder: (a) => _AddBookDemo(animation: a),
    ),
    _SlideData(
      title: AppStrings.tutorialReorderTitle,
      description: AppStrings.tutorialReorderDesc,
      demoBuilder: (a) => _ReorderDemo(animation: a),
    ),
    _SlideData(
      title: AppStrings.tutorialNotesTitle,
      description: AppStrings.tutorialNotesDesc,
      demoBuilder: (a) => _NotesDemo(animation: a),
    ),
    _SlideData(
      title: AppStrings.tutorialProgressTitle,
      description: AppStrings.tutorialProgressDesc,
      demoBuilder: (a) => _ProgressDemo(animation: a),
    ),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await getIt<OnboardingService>().markSeen();
    if (!mounted) return;
    if (widget.fromSettings) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(AppStrings.tutorialSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 220,
                          child: Center(child: slide.demoBuilder(_anim)),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  _Dots(count: _slides.length, active: _page),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_isLast
                        ? AppStrings.tutorialStart
                        : AppStrings.tutorialNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.description,
    required this.demoBuilder,
  });

  final String title;
  final String description;
  final Widget Function(Animation<double> animation) demoBuilder;
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini-demos animadas
// ---------------------------------------------------------------------------

/// Slide 1 — ícone do app pulsando suavemente.
class _WelcomeDemo extends StatelessWidget {
  const _WelcomeDemo({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final pulse = 1 + 0.06 * math.sin(animation.value * 2 * math.pi);
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded,
                size: 64, color: AppColors.primary),
          ),
        );
      },
    );
  }
}

/// Slide 2 — botão "Novo Livro" e um card com capa surgindo (busca).
class _AddBookDemo extends StatelessWidget {
  const _AddBookDemo({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Capa surge entre 0.25 e 0.6 do ciclo.
        final appear =
            Curves.easeOut.transform(((t - 0.25) / 0.35).clamp(0.0, 1.0));
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: appear,
              child: Transform.scale(
                scale: 0.8 + 0.2 * appear,
                child: const _MockCover(width: 70, height: 96, label: 'A'),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text('Novo Livro',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Slide 3 — três cards onde o de baixo sobe para o topo (drag-and-drop).
class _ReorderDemo extends StatelessWidget {
  const _ReorderDemo({required this.animation});
  final Animation<double> animation;

  static const _slotHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // O card "C" (índice 2) sobe para o slot 0 entre 0.2 e 0.55, segura, e
        // os outros descem. Reinicia ao fim do ciclo.
        final raise =
            Curves.easeInOut.transform(((t - 0.2) / 0.35).clamp(0.0, 1.0));
        final settle = ((t - 0.7) / 0.2).clamp(0.0, 1.0);
        final lift = raise * (1 - settle);

        // Posições verticais (top) de cada card.
        final cTop = (2 - 2 * raise) * _slotHeight;
        final aTop = (0 + raise) * _slotHeight;
        final bTop = (1 + 0 * raise) * _slotHeight;

        return SizedBox(
          width: 200,
          height: 3 * _slotHeight,
          child: Stack(
            children: [
              _reorderCard('A', aTop, AppColors.primary, false, 0),
              _reorderCard('B', bTop, AppColors.secondary, false, 0),
              _reorderCard('C', cTop, AppColors.success, true, lift),
            ],
          ),
        );
      },
    );
  }

  Widget _reorderCard(
      String label, double top, Color color, bool dragging, double lift) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 0),
      top: top,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: dragging ? (0.7 + 0.3 * (1 - lift)) : 1,
        child: Transform.scale(
          scale: 1 + 0.05 * lift,
          child: Container(
            height: _slotHeight - 10,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dragging && lift > 0.1
                    ? color
                    : color.withValues(alpha: 0.3),
                width: dragging && lift > 0.1 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _MockCover(width: 26, height: 36, label: label, color: color),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Icon(Icons.drag_handle,
                    color: color.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slide 4 — bolha de anotação com texto sendo "digitado", página e OCR.
class _NotesDemo extends StatelessWidget {
  const _NotesDemo({required this.animation});
  final Animation<double> animation;

  static const _fullText =
      'Trecho marcante deste capítulo que quero lembrar depois...';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final typed = (t * 1.5).clamp(0.0, 1.0);
        final chars = (typed * _fullText.length).round();
        final text = _fullText.substring(0, chars);
        return Container(
          width: 240,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('pág. 42',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  const Icon(Icons.photo_camera_outlined,
                      size: 18, color: AppColors.secondary),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: text),
                      if (chars < _fullText.length)
                        const TextSpan(
                            text: '|',
                            style: TextStyle(color: AppColors.secondary)),
                    ]),
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Slide 5 — barra de progresso enchendo, estrelas acendendo e mini gráfico.
class _ProgressDemo extends StatelessWidget {
  const _ProgressDemo({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final progress = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Barra de progresso
            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${(progress * 100).round()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Estrelas acendendo em sequência
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final lit = progress >= (i + 1) / 6;
                return Icon(
                  lit ? Icons.star : Icons.star_border,
                  color: lit ? Colors.amber : AppColors.textSecondary,
                  size: 28,
                );
              }),
            ),
            const SizedBox(height: 20),
            // Mini gráfico de barras (estatísticas)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                final heights = [0.4, 0.7, 0.5, 0.9, 0.6];
                final h = 40 * heights[i] * progress;
                return Container(
                  width: 12,
                  height: h + 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// Capa de livro simulada (sem asset).
class _MockCover extends StatelessWidget {
  const _MockCover({
    required this.width,
    required this.height,
    required this.label,
    this.color = AppColors.primary,
  });

  final double width;
  final double height;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.4,
        ),
      ),
    );
  }
}
