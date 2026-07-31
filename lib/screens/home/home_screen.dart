import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/widgets/animated_tab_bar.dart';
import 'package:mishra_milk_cash/core/widgets/particle_background.dart';
import 'package:mishra_milk_cash/core/widgets/premium_app_bar.dart';
import 'package:mishra_milk_cash/screens/counter/counter_screen.dart';
import 'package:mishra_milk_cash/screens/history/history_screen.dart';
import 'package:mishra_milk_cash/screens/baaki/baaki_screen.dart';
import 'package:mishra_milk_cash/screens/calculator/calculator_screen.dart';
import 'package:mishra_milk_cash/core/widgets/expandable_fab.dart';
import 'package:mishra_milk_cash/screens/admin/admin_screen.dart';
import 'package:mishra_milk_cash/providers/history_provider.dart';
import 'package:mishra_milk_cash/providers/counter_provider.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';
import 'package:mishra_milk_cash/update/providers/update_provider.dart';
import 'package:mishra_milk_cash/update/screens/update_dialog.dart';
import 'package:mishra_milk_cash/update/screens/maintenance_screen.dart';

/// Main home screen with app bar, tab navigation, and page views
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Set system UI overlay style for premium dark look
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdateProvider>().checkForUpdates().then((_) {
        _handleUpdateState(context);
      });
    });
  }

  void _handleUpdateState(BuildContext context) {
    final provider = context.read<UpdateProvider>();
    if (provider.state == UpdateState.maintenance) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
      );
    } else if (provider.state == UpdateState.available || provider.state == UpdateState.blocked) {
      showDialog(
        context: context,
        barrierDismissible: provider.updateInfo?.forceUpdate == false,
        builder: (_) => const UpdateDialog(),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _currentTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ParticleBackground(
            child: Column(
              children: [
                // ── Premium App Bar ──
                PremiumAppBar(
                  actions: _currentTab == 1 // Only on History tab
                      ? [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              context.read<HistoryProvider>().toggleShowFilters();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminScreen(),
                                ),
                              );
                            },
                          ),
                        ]
                      : null,
                ),

                // ── Tab Bar ──
                AnimatedTabBar(
                  currentIndex: _currentTab,
                  onTabChanged: _onTabChanged,
                ),

                const SizedBox(height: 4),

                // ── Page Content ──
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentTab = index);
                    },
                    children: const [
                      CounterScreen(),
                      HistoryScreen(),
                      BaakiScreen(),
                      CalculatorScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ExpandableFab(
            onQuickCalculator: () => _showCalculatorDialog(context),
            onScanQr: () => _showQrDialog(context),
            onTallyCash: () {
              context.read<CounterProvider>().toggleTallyPanel();
              if (_currentTab != 0) {
                _onTabChanged(0);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCalculatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: 320,
          height: 450,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  child: CalculatorScreen(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    final qrs = HiveService.getBankQrs();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bank QR Codes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (qrs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No QR codes found. Upload them in Admin Settings.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textMuted),
                  ),
                )
              else
                SizedBox(
                  height: 300,
                  width: 300,
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: qrs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(qrs[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
