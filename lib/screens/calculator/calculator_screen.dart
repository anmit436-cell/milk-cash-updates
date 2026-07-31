import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';

/// Premium glass calculator with large display and animated buttons
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _result = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;

  final List<String> _history = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth - AppConstants.paddingOuter * 2 - 36) / 4;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingOuter,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Display ──
                Expanded(
                  flex: 2,
                  child: _buildDisplay(),
                ),

                const SizedBox(height: 16),

                // ── Button Grid ──
                Expanded(
                  flex: 5,
                  child: _buildButtonGrid(buttonSize),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression
              if (_expression.isNotEmpty)
                Text(
                  _expression,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // Main display
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid(double buttonSize) {
    final buttons = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['00', '0', '.', '='],
    ];

    return Column(
      children: buttons.map((row) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: row.asMap().entries.map((entry) {
                final idx = entry.key;
                final btn = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: idx < 3 ? 10 : 0),
                    child: _buildButton(btn),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String label) {
    final isOperator = ['÷', '×', '-', '+', '='].contains(label);
    final isSpecial = ['C', '⌫', '%'].contains(label);
    final isEquals = label == '=';

    Color bgColor;
    Color textColor;
    Gradient? gradient;

    if (isEquals) {
      gradient = AppColors.grandTotalGradient;
      textColor = Colors.white;
      bgColor = Colors.transparent;
    } else if (isOperator) {
      bgColor = AppColors.primaryPurple.withValues(alpha: 0.2);
      textColor = AppColors.primaryPurple;
    } else if (isSpecial) {
      bgColor = AppColors.surface;
      textColor = label == 'C'
          ? AppColors.error
          : AppColors.textSecondary;
    } else {
      bgColor = AppColors.backgroundCard;
      textColor = AppColors.textPrimary;
    }

    return _CalcButton(
      label: label,
      backgroundColor: bgColor,
      textColor: textColor,
      gradient: gradient,
      onTap: () => _onButtonPressed(label),
    );
  }

  void _onButtonPressed(String btn) {
    HapticFeedback.lightImpact();

    setState(() {
      switch (btn) {
        case 'C':
          _display = '0';
          _expression = '';
          _result = 0;
          _operator = '';
          _shouldResetDisplay = false;
          break;

        case '⌫':
          if (_display.length > 1) {
            _display = _display.substring(0, _display.length - 1);
          } else {
            _display = '0';
          }
          break;

        case '%':
          final current = double.tryParse(_display) ?? 0;
          _display = _formatResult(current / 100);
          break;

        case '÷':
        case '×':
        case '-':
        case '+':
          _result = double.tryParse(_display) ?? 0;
          _operator = btn;
          _expression = '$_display $btn';
          _shouldResetDisplay = true;
          break;

        case '=':
          final current = double.tryParse(_display) ?? 0;
          double res = 0;
          switch (_operator) {
            case '+':
              res = _result + current;
              break;
            case '-':
              res = _result - current;
              break;
            case '×':
              res = _result * current;
              break;
            case '÷':
              res = current != 0 ? _result / current : 0;
              break;
            default:
              res = current;
          }
          _expression = '$_expression $_display =';
          _display = _formatResult(res);
          _history.insert(0, '$_expression $_display');
          _operator = '';
          _shouldResetDisplay = true;
          break;

        case '.':
          if (!_display.contains('.')) {
            _display += '.';
          }
          break;

        default: // Numbers
          if (_shouldResetDisplay) {
            _display = btn;
            _shouldResetDisplay = false;
          } else {
            if (_display == '0' && btn != '00') {
              _display = btn;
            } else {
              _display += btn;
            }
          }
          break;
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

/// Individual calculator button with press animation
class _CalcButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _CalcButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.gradient,
    required this.onTap,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.gradient == null ? widget.backgroundColor : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Center(
            child: widget.label == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    color: widget.textColor,
                    size: 22,
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: widget.label == '=' ? 28 : 22,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
