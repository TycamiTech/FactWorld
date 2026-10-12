import 'package:flutter/material.dart';

class CompactKeyValueRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final double keyWidth;
  final VoidCallback? onTapValue;

  const CompactKeyValueRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.keyWidth = 110.0,
    this.onTapValue,
  }) : assert(
          value != null || valueWidget != null,
          'Harus menyertakan value teks atau valueWidget',
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Kiri: Label/Key tetap selebar 110dp (11.5sp, #6B7280)
          SizedBox(
            width: keyWidth,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
          ),

          // Pemisah " : "
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Kolom Kanan: Value teks (12.5sp, #111827) atau Widget kustom
          Expanded(
            child: valueWidget ??
                GestureDetector(
                  onTap: onTapValue,
                  child: Text(
                    value ?? '-',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: onTapValue != null
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF111827),
                      height: 1.35,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
