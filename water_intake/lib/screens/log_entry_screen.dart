import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../models/intake_entry.dart';

class LogEntryScreen extends StatefulWidget {
  final IntakeEntry? entry;

  LogEntryScreen({this.entry});

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
      _noteController.text = widget.entry!.note ?? '';
      _selectedDate = widget.entry!.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(widget.entry!.timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'Log Water Intake'),
        actions: isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteEntry,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (ml)',
                  border: OutlineInputBorder(),
                  suffixText: 'ml',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Quick Add',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickAddChip(250, 'Glass'),
                  _buildQuickAddChip(500, 'Bottle'),
                  _buildQuickAddChip(1000, 'Large Bottle'),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(isEditing ? 'Update Entry' : 'Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddChip(double amount, String label) {
    return ActionChip(
      label: Text('$label (${amount.toInt()}ml)'),
      onPressed: () {
        _amountController.text = amount.toString();
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<IntakeProvider>(context, listen: false);
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final entry = IntakeEntry(
        id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: timestamp,
        amount: double.parse(_amountController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (widget.entry != null) {
        provider.updateEntry(entry);
      } else {
        provider.addEntry(entry);
      }

      Navigator.pop(context);
    }
  }

  void _deleteEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<IntakeProvider>(context, listen: false);
              provider.deleteEntry(widget.entry!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}