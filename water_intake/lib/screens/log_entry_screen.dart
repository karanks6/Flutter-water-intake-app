import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../models/intake_entry.dart';
import '../theme/app_text_styles.dart';
import '../widgets/theme_toggle_button.dart';

class LogEntryScreen extends StatefulWidget {
  final IntakeEntry? entry;
  const LogEntryScreen({super.key, this.entry});

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  
  double _amount = 250.0; // Default logging volume
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.entry != null) {
      _amount = widget.entry!.amount;
      _noteController.text = widget.entry!.note;
      _selectedDate = widget.entry!.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(widget.entry!.timestamp);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showCustomAmountDialog() {
    final textController = TextEditingController(text: _amount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Enter Custom Amount', style: AppTextStyles.tileTitle),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Volume (ml)',
              labelStyle: AppTextStyles.inputLabel,
              suffixText: 'ml',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.tileTitle),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(textController.text);
                if (val != null && val > 0) {
                  setState(() {
                    _amount = val.clamp(50.0, 3000.0);
                  });
                }
                Navigator.pop(context);
              },
              child: Text('OK', style: AppTextStyles.tileTitle),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Progress calculation for cup fill (slider goes up to 1500ml by default, support up to 3000ml)
    final fillProgress = (_amount / 1500.0).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outlineVariant;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'LOG WATER' : 'EDIT ENTRY',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Dynamic Interactive Cup Visualization
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Container(
                    height: 200,
                    width: 150,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomPaint(
                      painter: _CupPainter(
                        fillProgress: fillProgress,
                        waveAnimationValue: _waveController.value,
                        waterColor: const Color(0xFF039BE5),
                      ),
                    ),
                  );
                },
              ),

              // Large Numeric Amount Indicator with Edit Key
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_amount.toStringAsFixed(0)} ml',
                    style: AppTextStyles.heroValue,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.edit_note, color: Colors.blue[600], size: 28),
                    onPressed: _showCustomAmountDialog,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Custom Liquid Slide Selector
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue[400],
                  inactiveTrackColor: Colors.blue[50],
                  trackHeight: 6.0,
                  thumbColor: Colors.blue[600],
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayColor: Colors.blue[200]!.withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                ),
                child: Slider(
                  value: _amount.clamp(50.0, 1500.0),
                  min: 50.0,
                  max: 1500.0,
                  divisions: 29, // 50ml steps
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _amount = value;
                    });
                  },
                ),
              ),

              // Slider indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('50 ml', style: AppTextStyles.sliderBound),
                    Text('1500 ml', style: AppTextStyles.sliderBound),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Settings Cards for Date, Time and Notes
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: borderColor, width: 1.5),
                ),
                color: surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: [
                      // Date Selector Row
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.calendar_today_rounded, color: Colors.blue[400], size: 20),
                        ),
                        title: Text('Date', style: AppTextStyles.tileTitle),
                        subtitle: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.blueGrey[300],
                        ),
                        onTap: _selectDate,
                      ),
                      Divider(height: 1, color: borderColor),
                      // Time Selector Row
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.access_time_rounded, color: Colors.blue[400], size: 20),
                        ),
                        title: Text('Time', style: AppTextStyles.tileTitle),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: AppTextStyles.caption,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.blueGrey[300],
                        ),
                        onTap: _selectTime,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Notes input field
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: AppTextStyles.inputValue,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: AppTextStyles.inputLabel,
                  prefixIcon: Icon(
                    Icons.note_alt_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey[300]
                        : Colors.blueGrey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E2A3E)
                          : Colors.blue[50]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E2A3E)
                          : Colors.blue[50]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
              ),

              const SizedBox(height: 32),

              // 5. Submit Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.cyan[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[400]!.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.entry == null ? 'Log Drink' : 'Update Entry',
                    style: AppTextStyles.buttonLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF64B5F6),
                    onPrimary: Colors.black,
                    surface: Color(0xFF1A2336),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Colors.blue[600]!,
                    onPrimary: Colors.white,
                    onSurface: Colors.blue[900]!,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final note = _noteController.text;
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.entry == null) {
        Provider.of<IntakeProvider>(context, listen: false)
            .addEntry(_amount, note, timestamp);
      } else {
        Provider.of<IntakeProvider>(context, listen: false)
            .updateEntry(widget.entry!.id, _amount, note, timestamp);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.entry == null
              ? 'Logged successfully!'
              : 'Updated successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green[600],
        ),
      );
    }
  }
}

class _CupPainter extends CustomPainter {
  final double fillProgress;
  final double waveAnimationValue;
  final Color waterColor;

  _CupPainter({
    required this.fillProgress,
    required this.waveAnimationValue,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cup path: tapered beaker/glass shape
    final cupPath = Path();
    cupPath.moveTo(w * 0.15, h * 0.15); // Top left
    cupPath.lineTo(w * 0.23, h * 0.85); // Bottom left
    cupPath.lineTo(w * 0.77, h * 0.85); // Bottom right
    cupPath.lineTo(w * 0.85, h * 0.15); // Top right
    cupPath.close();

    // 1. Draw light glass backing
    final bgPaint = Paint()..color = Colors.blue[50]!.withOpacity(0.35);
    canvas.drawPath(cupPath, bgPaint);

    // 2. Draw animated liquid level (clipped to cup outline)
    if (fillProgress > 0.0) {
      canvas.save();
      canvas.clipPath(cupPath);

      // Max fill is 70% of total height to leave room at the rim
      final double liquidHeight = (h * 0.65) * fillProgress;
      final double baseHeight = h * 0.85 - liquidHeight;

      final wavePaint = Paint()
        ..color = waterColor
        ..style = PaintingStyle.fill;

      final wavePath = Path();
      wavePath.moveTo(w * 0.05, baseHeight);

      // Draw mathematical sine wave
      for (double x = 0; x <= w; x++) {
        final double waveY = 4 * sin((x / w * 2.2 * pi) + (waveAnimationValue * 2 * pi));
        wavePath.lineTo(x, baseHeight + waveY);
      }
      wavePath.lineTo(w * 1.1, h * 1.1);
      wavePath.lineTo(-w * 0.1, h * 1.1);
      wavePath.close();

      canvas.drawPath(wavePath, wavePaint);
      canvas.restore();
    }

    // 3. Draw glass container outlines
    final outlinePaint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final outlinePath = Path();
    outlinePath.moveTo(w * 0.15, h * 0.15);
    outlinePath.lineTo(w * 0.23, h * 0.85);
    outlinePath.lineTo(w * 0.77, h * 0.85);
    outlinePath.lineTo(w * 0.85, h * 0.15);
    canvas.drawPath(outlinePath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
        oldDelegate.waveAnimationValue != waveAnimationValue ||
        oldDelegate.waterColor != waterColor;
  }
}