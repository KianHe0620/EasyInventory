import 'package:flutter/material.dart';

class QuantityBox extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const QuantityBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<QuantityBox> createState() => _QuantityBoxState();
}

class _QuantityBoxState extends State<QuantityBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant QuantityBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(35),
        child: SizedBox(
          width: 35,
          height: 35,
          child: Center(
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double boxHeight = 40;

    final quantityControls = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildActionButton(Icons.remove, () {
          final newValue = (widget.value > 0) ? widget.value - 1 : 0;
          widget.onChanged(newValue);
        }),
        SizedBox(
          width: 50,
          height: boxHeight,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.black45),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.black45),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.black87, width: 1.5),
              ),
            ),
            onChanged: (val) {
              final number = int.tryParse(val);
              if (number != null) {
                widget.onChanged(number);
              }
            },
          ),
        ),
        _buildActionButton(Icons.add, () {
          final newValue = widget.value + 1;
          widget.onChanged(newValue);
        }),
      ],
    );

    if (widget.label.isEmpty) return quantityControls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        quantityControls,
      ],
    );
  }
}
