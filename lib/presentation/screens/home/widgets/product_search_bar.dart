import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/utils/app_extensions.dart';

class ProductSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const ProductSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: context.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: LocaleKeys.searchHint.tr(),
          prefixIcon: Icon(Icons.search_rounded, color: subtitleColor, size: 20),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clear,
                  child: Icon(Icons.close_rounded,
                      color: subtitleColor, size: 18),
                )
              : null,
        ),
      ),
    );
  }
}
