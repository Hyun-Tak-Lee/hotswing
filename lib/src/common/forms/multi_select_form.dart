import 'package:flutter/material.dart';

class MultiSelectForm extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<int> optionsId;
  final List<int> initialValue;
  final Function(List<int>) onSelectionChanged;

  const MultiSelectForm({
    Key? key,
    required this.title,
    required this.options,
    required this.optionsId,
    required this.initialValue,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _MultiSelectFormState createState() => _MultiSelectFormState();
}

class _MultiSelectFormState extends State<MultiSelectForm> {
  late List<int> _selectedOptions;
  final int _maxSelection = 3;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialValue);
  }

  void _onOptionChanged(int option, bool? isSelected) {
    if (isSelected == true) {
      setState(() {
        _selectedOptions.add(option);
      });
    } else {
      setState(() {
        _selectedOptions.remove(option);
      });
    }
    widget.onSelectionChanged(_selectedOptions);
  }

  Widget _buildSelectedOptionsTitle() {
    if (_selectedOptions.isEmpty) {
      return Text(
        widget.title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    List<Widget> selectedChips = [];
    for (int selectedId in _selectedOptions) {
      int index = widget.optionsId.indexOf(selectedId);
      if (index != -1) {
        selectedChips.add(
          Chip(
            label: Text(widget.options[index]),
            onDeleted: () {
              _onOptionChanged(selectedId, false);
            },
          ),
        );
      }
    }
    print(_selectedOptions);

    return Wrap(spacing: 6.0, runSpacing: 6.0, children: selectedChips);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.0,
      child: ExpansionTile(
        title: _buildSelectedOptionsTitle(),

        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 250,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = widget.options[index];
                final optionId = widget.optionsId[index];
                final isSelected = _selectedOptions.contains(optionId);
                final isMaxSelected = _selectedOptions.length >= _maxSelection;

                return CheckboxListTile(
                  title: Text(option),
                  value: isSelected,
                  onChanged: (bool? selected) {
                    _onOptionChanged(optionId, selected);
                  },
                  enabled: isSelected || !isMaxSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
