import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/festive_background.dart';
import 'workout_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Dashboard(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050706),
      body: SafeArea(
        child: pages[tab],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B0F0B),
        indicatorColor: AppTheme.lime.withValues(alpha: 0.18),
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() {
            tab = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(
              Icons.grid_view_rounded,
              color: AppTheme.lime,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(
              Icons.history,
              color: AppTheme.lime,
            ),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: AppTheme.lime,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FestiveBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎄 PULSE FIT',
                      style: TextStyle(
                        color: AppTheme.lime,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Hoy es tu día.',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.surface,
                child: Icon(
                  Icons.bolt,
                  color: AppTheme.lime,
                  size: 27,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            '❄️  EDICIÓN NAVIDEÑA  ❄️',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF29351F),
                  Color(0xFF1B201B),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.lime.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lime.withValues(alpha: 0.08),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '🎅',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'LISTO PARA MOVERTE',
                      style: TextStyle(
                        color: AppTheme.lime,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Cada paso cuenta.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Activa tu sesión y mide tu rendimiento '
                      'con sensores reales.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.lime,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkoutScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    label: const Text(
                      'INICIAR ENTRENAMIENTO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Row(
            children: [
              Text(
                '🎁',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Text(
                'CENTRO DE CONTROL',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.directions_walk,
                  title: 'Podómetro',
                  value: 'En sesión',
                  note: 'STEP_COUNTER',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.my_location,
                  title: 'GPS',
                  value: 'En espera',
                  note: 'Ubicación',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.speed,
                  title: 'Acelerómetro',
                  value: 'X / Y / Z',
                  note: 'Movimiento',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.screen_rotation,
                  title: 'Giroscopio',
                  value: 'ω X / Y / Z',
                  note: 'Orientación',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  '❄️',
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tus métricas se activarán al iniciar '
                        'una sesión de entrenamiento.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              '🎄  ENTRENA · AVANZA · DISFRUTA  🎄',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String note;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.lime.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: AppTheme.lime,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              note,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}