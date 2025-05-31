import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

/// Skills section of the portfolio website with elegant, modular, and accessible design.
class SkillsSection extends StatefulWidget {
  final ScrollController? scrollController;
  const SkillsSection({super.key, this.scrollController});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _allSkills = [];
  List<Map<String, dynamic>> _filteredSkills = [];
  final Map<String, bool> _expandedCategories = {};

  Future<List<Map<String, dynamic>>> _loadSkills() async {
    final String jsonString = await rootBundle.loadString('assets/data/skills.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    final skills = await _loadSkills();
    setState(() {
      _allSkills = skills;
      _filteredSkills = skills;
      for (var cat in skills) {
        _expandedCategories[cat['category']] = false;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredSkills = _allSkills;
      } else {
        _filteredSkills = _allSkills
            .map((cat) => {
                  'category': cat['category'],
                  'skills': (cat['skills'] as List)
                      .where((s) => (s as String).toLowerCase().contains(_searchQuery))
                      .toList(),
                })
            .where((cat) => (cat['skills'] as List).isNotEmpty)
            .toList();
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      _expandedCategories[category] = !(_expandedCategories[category] ?? true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.1 && _opacity == 0.0) {
      setState(() {
        _opacity = 1.0;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final double headingSize = isMobile ? 22 : 36;
    final EdgeInsets sectionPadding = MediaQuery.of(context).size.width < 800
        ? const EdgeInsets.symmetric(vertical: 32, horizontal: 10)
        : const EdgeInsets.symmetric(vertical: 80, horizontal: 40);
    final bool useScroll = _filteredSkills.length > 3;
    final ScrollController scrollController = ScrollController();

    return VisibilityDetector(
      key: const Key('skills-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 900),
        opacity: _opacity,
        curve: Curves.easeOut,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            padding: sectionPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedScale(
                    scale: _isHovered && !isMobile ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: theme.textTheme.displayMedium!.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                        fontSize: headingSize,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : (_isHovered && !isMobile
                                ? theme.colorScheme.secondary
                                : theme.textTheme.displayMedium!.color),
                      ),
                      child: const Text('Skills'),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Search/filter bar
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search skills...',
                    filled: true,
                    fillColor: theme.colorScheme.surface.withAlpha(30),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isMobile ? 8 : 14,
                      horizontal: isMobile ? 10 : 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: isMobile ? 13 : 17),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                if (_filteredSkills.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No skills found.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                if (useScroll)
                  SizedBox(
                    height: isMobile ? 420 : 340,
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      radius: const Radius.circular(12),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: _filteredSkills.map((category) {
                          return _SkillCategory(
                            category: category['category'] as String,
                            skills: List<String>.from(category['skills'] as List),
                            isMobile: isMobile,
                            expanded: _expandedCategories[category['category']] ?? false,
                            onToggle: () => _toggleCategory(category['category'] as String),
                            searchQuery: _searchQuery,
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _filteredSkills.map((category) {
                        return _SkillCategory(
                          category: category['category'] as String,
                          skills: List<String>.from(category['skills'] as List),
                          isMobile: isMobile,
                          expanded: _expandedCategories[category['category']] ?? false,
                          onToggle: () => _toggleCategory(category['category'] as String),
                          searchQuery: _searchQuery,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget to display a skill category and its skills as elegant chips with entrance animations, focus/hover, and search highlighting.
class _SkillCategory extends StatelessWidget {
  final String category;
  final List<String> skills;
  final bool isMobile;
  final bool expanded;
  final VoidCallback onToggle;
  final String searchQuery;
  const _SkillCategory({
    required this.category,
    required this.skills,
    required this.isMobile,
    required this.expanded,
    required this.onToggle,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool useListView = skills.length > 15;
    return Semantics(
      container: true,
      label: '$category skills category',
      hint: expanded
          ? 'Expanded. Tap to collapse and hide skills.'
          : 'Collapsed. Tap to expand and show skills.',
      toggled: expanded,
      button: true,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.only(bottom: isMobile ? 24 : 16),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        category,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 18 : 20,
                          color: theme.colorScheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: useListView
                    ? SizedBox(
                        height: isMobile ? 120 : 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: skills.length,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _AnimatedAccessibleChip(
                              label: skills[i],
                              isMobile: isMobile,
                              searchQuery: searchQuery,
                              animationDelay: i * 60,
                            ),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (int i = 0; i < skills.length; i++)
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth * 0.45,
                                    ),
                                    child: _AnimatedAccessibleChip(
                                      label: skills[i],
                                      isMobile: isMobile,
                                      searchQuery: searchQuery,
                                      animationDelay: i * 60,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A chip with entrance animation, keyboard focus, hover, search term highlighting, and ripple effect.
class _AnimatedAccessibleChip extends StatefulWidget {
  final String label;
  final bool isMobile;
  final String searchQuery;
  final int animationDelay;
  const _AnimatedAccessibleChip({
    required this.label,
    required this.isMobile,
    required this.searchQuery,
    required this.animationDelay,
  });

  @override
  State<_AnimatedAccessibleChip> createState() => _AnimatedAccessibleChipState();
}

class _AnimatedAccessibleChipState extends State<_AnimatedAccessibleChip> {
  // Built-in Tooltip is used; no custom AnimationController is created here.
  bool _isHovered = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final highlight = widget.searchQuery.isNotEmpty
        ? _highlightText(widget.label, widget.searchQuery, theme)
        : TextSpan(text: widget.label, style: _chipTextStyle(theme, isDarkMode));
    return Tooltip(
      message: widget.label,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        onShowFocusHighlight: (v) => setState(() => _isFocused = v),
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              Theme.of(context).extension<AppThemeExtension>()?.cardBorderRadius ?? 8,
            ),
            splashColor: theme.colorScheme.secondary.withAlpha(60),
            highlightColor: theme.colorScheme.secondary.withAlpha(40),
            onTap: () {}, // For ripple effect only
            child: Chip(
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * (widget.isMobile ? 0.4 : 0.25), // Limit text width
                ),
                child: RichText(
                  text: highlight,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              backgroundColor: _isFocused
                  ? theme.colorScheme.secondary.withAlpha(isDarkMode ? 100 : 80)
                  : _isHovered
                      ? theme.colorScheme.secondary.withAlpha(isDarkMode ? 70 : 50)
                      : theme.colorScheme.secondary.withAlpha(isDarkMode ? 50 : 30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Add this to reduce chip size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Theme.of(context).extension<AppThemeExtension>()?.cardBorderRadius ?? 8,
                ),
                side: BorderSide(
                  color: isDarkMode ? Colors.white.withAlpha((0.25 * 255).round()) : theme.colorScheme.secondary.withAlpha((0.22 * 255).round()),
                  width: 1.3,
                ),
              ),
              labelStyle: _chipTextStyle(theme, isDarkMode),
            ).animate()
              .fadeIn(duration: (Theme.of(context).extension<AppThemeExtension>()?.animationDuration ?? 400.ms), delay: widget.animationDelay.ms)
              .slideY(begin: 0.2, duration: (Theme.of(context).extension<AppThemeExtension>()?.animationDuration ?? 400.ms), delay: widget.animationDelay.ms, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
  }

  /// Highlights the search term in the skill label.
  TextSpan _highlightText(String text, String query, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final lower = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    if (!lower.contains(lowerQuery) || query.isEmpty) {
      return TextSpan(text: text, style: _chipTextStyle(theme, isDarkMode));
    }
    final spans = <TextSpan>[];
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(lowerQuery, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: _chipTextStyle(theme, isDarkMode)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: _chipTextStyle(theme, isDarkMode).copyWith(
          backgroundColor: theme.colorScheme.secondary.withAlpha(isDarkMode ? 120 : 100),
          color: isDarkMode ? Colors.white : theme.colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: _chipTextStyle(theme, isDarkMode)));
    }
    return TextSpan(children: spans);
  }

  TextStyle _chipTextStyle(ThemeData theme, bool isDarkMode) => theme.textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSecondary,
        fontSize: widget.isMobile ? 13 : 15,
      );
} 