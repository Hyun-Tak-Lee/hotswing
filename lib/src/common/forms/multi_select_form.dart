import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class MultiSelectForm extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<ObjectId> optionsId;
  final List<ObjectId> groupsOptionId;
  final List<ObjectId> initialValue;
  final Function(List<ObjectId>) onSelectionChanged;
  final ObjectId? currentId;

  const MultiSelectForm({
    super.key,
    required this.title,
    required this.options,
    required this.optionsId,
    required this.groupsOptionId,
    required this.initialValue,
    required this.onSelectionChanged,
    this.currentId,
  });

  @override
  State<MultiSelectForm> createState() => _MultiSelectFormState();
}

class _MultiSelectFormState extends State<MultiSelectForm> {
  late List<ObjectId> _selectedOptions;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  double get _labelFontSize {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    return isMobileSize ? 20 : 32;
  }

  double get _chipFontSize {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    return isMobileSize ? 8 : 16;
  }

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialValue);
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _onOptionChanged(ObjectId option, bool? isSelected) {
    if (isSelected == true) {
      setState(() {
        _selectedOptions.add(option);
      });
    } else {
      setState(() {
        _selectedOptions.remove(option);
      });
    }
    _overlayEntry?.markNeedsBuild();
    widget.onSelectionChanged(_selectedOptions);
  }

  void _toggleMenu(BaseColors baseColors) {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu(baseColors);
    }
  }

  void _openMenu(BaseColors baseColors) {
    _overlayEntry = _createOverlayEntry(baseColors);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry(BaseColors baseColors) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4.0,
              color: baseColors.cardBg,
              child: SizedBox(
                width: size.width,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = widget.options[index];
                      final optionId = widget.optionsId[index];
                      final isCurrentPlayer = optionId == widget.currentId;
                      final isSelected = _selectedOptions.contains(optionId);
                      final isGrouped = widget.groupsOptionId.contains(
                        optionId,
                      );
                      final isEnabled =
                          isSelected || !(isGrouped || isCurrentPlayer);

                      return CheckboxListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: _labelFontSize,
                            color: isEnabled
                                ? baseColors.textPrimary
                                : baseColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                        value: isSelected,
                        activeColor: baseColors.primaryAccent,
                        checkColor: baseColors.sliderIndicatorText,
                        onChanged: (bool? selected) {
                          _onOptionChanged(optionId, selected);
                        },
                        enabled: isEnabled,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.0,
      color: baseColors.cardBg,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: ListTile(
          onTap: () => _toggleMenu(baseColors),
          title: _SelectedOptionsTitle(
            title: widget.title,
            selectedOptions: _selectedOptions,
            options: widget.options,
            optionsId: widget.optionsId,
            labelFontSize: _labelFontSize,
            chipFontSize: _chipFontSize,
            onDeleted: (selectedId) => _onOptionChanged(selectedId, false),
          ),
          trailing: Icon(
            _isMenuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: baseColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SelectedOptionsTitle extends StatelessWidget {
  const _SelectedOptionsTitle({
    required this.title,
    required this.selectedOptions,
    required this.options,
    required this.optionsId,
    required this.labelFontSize,
    required this.chipFontSize,
    required this.onDeleted,
  });

  final String title;
  final List<ObjectId> selectedOptions;
  final List<String> options;
  final List<ObjectId> optionsId;
  final double labelFontSize;
  final double chipFontSize;
  final ValueChanged<ObjectId> onDeleted;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    if (selectedOptions.isEmpty) {
      return Text(
        title,
        style: TextStyle(
          color: baseColors.textSecondary,
          fontWeight: FontWeight.normal,
          fontSize: labelFontSize,
        ),
      );
    }

    final sortedSelected = List<ObjectId>.from(selectedOptions)
      ..sort((a, b) {
        final indexA = optionsId.indexOf(a);
        final indexB = optionsId.indexOf(b);
        return indexA.compareTo(indexB);
      });

    final List<Widget> selectedChips = [];
    for (final ObjectId selectedId in sortedSelected) {
      final int index = optionsId.indexOf(selectedId);
      if (index != -1) {
        selectedChips.add(
          Chip(
            label: Text(options[index], style: TextStyle(fontSize: chipFontSize)),
            onDeleted: () => onDeleted(selectedId),
          ),
        );
      }
    }

    return Wrap(spacing: 6.0, runSpacing: 6.0, children: selectedChips);
  }
}
