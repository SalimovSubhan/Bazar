import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/toast.dart';
import '../../../domain/entities/product.dart';
import '../../../injection_container.dart';
import '../../../domain/usecases/search_products_usecase.dart';
import '../../widgets/app_empty_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = Debouncer();
  final _searchUseCase = sl<SearchProductsUseCase>();

  String _query = '';
  bool _isLoading = false;
  List<Product> _results = [];
  final List<String> _recents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() => _query = q);
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debouncer(() => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    try {
      final results = await _searchUseCase(q);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        Toast.show(
          LocaleKeys.noInternet.tr(),
          type: ToastType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _onSubmit(String q) {
    final term = q.trim();
    if (term.isEmpty) return;
    setState(() {
      _recents.remove(term);
      _recents.insert(0, term);
    });
  }

  void _applyRecent(String term) {
    _controller.text = term;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: term.length));
    _onChanged(term);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          _SearchHeader(
            controller: _controller,
            focusNode: _focusNode,
            query: _query,
            onChanged: _onChanged,
            onSubmitted: _onSubmit,
            onClear: () {
              _controller.clear();
              setState(() {
                _query = '';
                _results = [];
                _isLoading = false;
              });
            },
            onCancel: () => context.pop(),
          ),
          Expanded(
            child: _query.isEmpty
                ? _buildRecents(isDark)
                : _buildResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRecents(bool isDark) {
    if (_recents.isEmpty) return const SizedBox.shrink();
    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.recentSearches.tr(),
              style: context.textTheme.titleSmall?.copyWith(color: textColor),
            ),
            GestureDetector(
              onTap: () => setState(() => _recents.clear()),
              child: Text(
                LocaleKeys.clearAll.tr(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recents
              .map((r) => GestureDetector(
                    onTap: () => _applyRecent(r),
                    child: Chip(
                      label: Text(r,
                          style: TextStyle(fontSize: 13, color: textColor)),
                      deleteIcon: Icon(Icons.close_rounded,
                          size: 14, color: subtitleColor),
                      onDeleted: () => setState(() => _recents.remove(r)),
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return AppEmptyWidget(
        icon: Icons.search_off_rounded,
        title: LocaleKeys.noResults.tr(),
        subtitle: LocaleKeys.noResultsDescription.tr(),
      );
    }

    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark2 : AppColors.backgroundLight;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(color: borderColor, height: 1, indent: 76),
      itemBuilder: (context, index) {
        final p = _results[index];
        return InkWell(
          onTap: () {
            _onSubmit(_query);
            context.push(AppRoutes.productDetailPath(p.id));
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: p.thumbnail,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: surfaceColor),
                    errorWidget: (_, __, ___) => Container(
                      color: surfaceColor,
                      child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.brand,
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  p.finalPrice.priceFormatted,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onCancel;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 8,
          4,
          12,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: LocaleKeys.searchHint.tr(),
                  hintStyle: TextStyle(
                      color: Colors.white.withAlpha(160), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withAlpha(200), size: 20),
                  filled: true,
                  fillColor: Colors.white.withAlpha(35),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.white.withAlpha(70)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.white.withAlpha(70)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: Colors.white.withAlpha(200), size: 18),
                          onPressed: onClear,
                        )
                      : null,
                ),
              ),
            ),
            TextButton(
              onPressed: onCancel,
              child: Text(
                LocaleKeys.cancel.tr(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
