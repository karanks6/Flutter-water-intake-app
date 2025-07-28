import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../models/intake_entry.dart';


class LogEntryScreen extends StatefulWidget {
  final IntakeEntry? entry;
  const LogEntryScreen({super.key, this.entry});
  @override
  _LogEntryScreenState createState() => _LogEntryScreenState();
}


class _LogEntryScreenState extends State<LogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();


  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _amountController.text = widget.entry!.amount.toString();
      _noteController.text = widget.entry!.note;
      _selectedDate = widget.entry!.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(widget.entry!.timestamp);
    }
  }


  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Log Water Intake' : 'Edit Entry'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (ml)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Quick Amount Buttons
              Text(
                'Quick Amounts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickAmountChip(250),
                  _buildQuickAmountChip(500),
                  _buildQuickAmountChip(750),
                  _buildQuickAmountChip(1000),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Date Selection
              ListTile(
                title: Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                leading: Icon(Icons.calendar_today),
                onTap: _selectDate,
                contentPadding: EdgeInsets.zero,
              ),
              
              // Time Selection
              ListTile(
                title: Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                leading: Icon(Icons.access_time),
                onTap: _selectTime,
                contentPadding: EdgeInsets.zero,
              ),
              
              SizedBox(height: 16),
              
              // Note Input
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.entry == null ? 'Save Entry' : 'Update Entry',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(double amount) {
    return ActionChip(
      label: Text('${amount.toStringAsFixed(0)} ml'),
      onPressed: () {
        _amountController.text = amount.toString();
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
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
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.entry == null) {
        // Add new entry
        Provider.of<IntakeProvider>(context, listen: false)
            .addEntry(amount, note, timestamp);
      } else {
        // Update existing entry
        Provider.of<IntakeProvider>(context, listen: false)
            .updateEntry(widget.entry!.id, amount, note, timestamp);
      }

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.entry == null 
              ? 'Entry saved successfully' 
              : 'Entry updated successfully'),
        ),
      );
    }
  }
}