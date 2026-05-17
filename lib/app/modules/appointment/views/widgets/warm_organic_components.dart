import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/theme/warm_organic_blue_theme.dart';

// ═══════════════════════════════════════════════════════════════
// WARM ORGANIC BLUE — Reusable Styled Components
// Drop these into your project and use everywhere.
// ═══════════════════════════════════════════════════════════════

/// ─── Organic Card ──────────────────────────────────────────
class OrganicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final List<BoxShadow>? shadow;
  final double? radius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const OrganicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.shadow,
    this.radius,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: gradient != null ? null : (color ?? Colors.white),
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          radius ?? WarmOrganicBlueTheme.radiusLg,
        ),
        boxShadow: shadow ?? WarmOrganicBlueTheme.cardShadow,
      ),
      child: child,
    );
  }
}

/// ─── Gradient Header Card ──────────────────────────────────
class GradientHeaderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientHeaderCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: WarmOrganicBlueTheme.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(WarmOrganicBlueTheme.radiusXl),
          bottomRight: Radius.circular(WarmOrganicBlueTheme.radiusXl),
        ),
        boxShadow: WarmOrganicBlueTheme.elevatedShadow,
      ),
      child: child,
    );
  }
}

/// ─── Organic Status Badge ──────────────────────────────────
class OrganicStatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final double? fontSize;

  const OrganicStatusBadge({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// ─── Organic Info Row ──────────────────────────────────────
class OrganicInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const OrganicInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: (iconColor ?? WarmOrganicBlueTheme.primaryBlue)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  WarmOrganicBlueTheme.radiusSm,
                ),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: iconColor ?? WarmOrganicBlueTheme.primaryBlue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WarmOrganicBlueTheme.bodySmall.copyWith(
                      color: WarmOrganicBlueTheme.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Organic Detail Row (label : value horizontal) ────────
class OrganicDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const OrganicDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: WarmOrganicBlueTheme.darkSlate,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                color: valueColor ?? WarmOrganicBlueTheme.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Organic Button (Primary) ─────────────────────────────
class OrganicPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;

  const OrganicPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      decoration: BoxDecoration(
        gradient: WarmOrganicBlueTheme.primaryGradient,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
        boxShadow: WarmOrganicBlueTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                      ],
                      Text(text, style: WarmOrganicBlueTheme.buttonLabel),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// ─── Organic Button (Secondary / Outline) ─────────────────
class OrganicSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final IconData? icon;

  const OrganicSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
        border: Border.all(
          color: WarmOrganicBlueTheme.primaryBlue.withOpacity(0.3),
        ),
        boxShadow: WarmOrganicBlueTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: WarmOrganicBlueTheme.primaryBlue,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  text,
                  style: WarmOrganicBlueTheme.buttonLabel.copyWith(
                    color: WarmOrganicBlueTheme.primaryBlue,
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

/// ─── Organic Tab Bar ──────────────────────────────────────

class OrganicTabBar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;

  const OrganicTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  State<OrganicTabBar> createState() => _OrganicTabBarState();
}

class _OrganicTabBarState extends State<OrganicTabBar>
    with SingleTickerProviderStateMixin {
  bool _canScrollRight = true;
  bool _canScrollLeft = false;
  late AnimationController _nudgeController;

  @override
  void initState() {
    super.initState();
    _nudgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_canScrollRight && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _nudgeController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _nudgeController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollMetrics metrics) {
    final canRight = metrics.pixels < metrics.maxScrollExtent - 5;
    final canLeft = metrics.pixels > 5;
    if (canRight != _canScrollRight || canLeft != _canScrollLeft) {
      setState(() {
        _canScrollRight = canRight;
        _canScrollLeft = canLeft;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      height: 60.h,
      decoration: BoxDecoration(
        gradient: WarmOrganicBlueTheme.headerGradient,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusLg),
        boxShadow: WarmOrganicBlueTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusLg),
        child: Stack(
          children: [
            // ── Left fade + chevron ──────────────────────────
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 40.w,
              child: AnimatedSwitcher(
                key: Key('left'),
                duration: const Duration(milliseconds: 250),
                child: _canScrollLeft
                    ? Container(
                        key: const ValueKey('left'),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFF4878C8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white.withValues(alpha: 0.65),
                            size: 20.sp,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // ── Right fade + animated chevron ────────────────
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 52.w,
              child: AnimatedSwitcher(
                key: Key('right'),

                duration: const Duration(milliseconds: 250),
                child: _canScrollRight
                    ? Container(
                        key: const ValueKey('right'),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF2B5299),
                            ],
                          ),
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _nudgeController,
                            builder: (context, child) {
                              final dx =
                                  math.sin(_nudgeController.value * math.pi) *
                                  4.0;
                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: child,
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  3,
                                  (i) => Container(
                                    width: 3.w,
                                    height: 3.w,
                                    margin: EdgeInsets.only(right: 2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withValues(alpha: 0.65),
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // ── TabBar ───────────────────────────────────────
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onScroll(notification.metrics);
                  return false;
                },
                child: TabBar(
                controller: widget.controller,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(
                    WarmOrganicBlueTheme.radiusSm,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                indicatorPadding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 15.h,
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                labelStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                // Remove labelPadding — width is now controlled per tab
                labelPadding: EdgeInsets.zero,
                tabs: widget.tabs
                    .map(
                      (t) => Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 90.w, // ← fixed width for every tab
                        child: Tab(text: t),
                      ),
                    )
                    .toList(),
              ),
            ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ─── Organic Section Title ────────────────────────────────
class OrganicSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionText;

  const OrganicSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 16.h, 4.w, 8.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: WarmOrganicBlueTheme.headingSmall.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: WarmOrganicBlueTheme.bodySmall.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!,
                style: WarmOrganicBlueTheme.bodySmall.copyWith(
                  color: WarmOrganicBlueTheme.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ─── Organic Chip ─────────────────────────────────────────
class OrganicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;

  const OrganicChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? WarmOrganicBlueTheme.primaryBlue)
              : WarmOrganicBlueTheme.warmSilver,
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (selectedColor ?? WarmOrganicBlueTheme.primaryBlue)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : WarmOrganicBlueTheme.darkSlate,
          ),
        ),
      ),
    );
  }
}

/// ─── Organic Empty State ──────────────────────────────────
class OrganicEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const OrganicEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: WarmOrganicBlueTheme.primaryBlueSoft,
                borderRadius: BorderRadius.circular(
                  WarmOrganicBlueTheme.radiusXl,
                ),
              ),
              child: Icon(
                icon,
                size: 40.sp,
                color: WarmOrganicBlueTheme.primaryBlue.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 16.h),
            Text(title, style: WarmOrganicBlueTheme.headingSmall),
            if (subtitle != null) ...[
              SizedBox(height: 6.h),
              Text(
                subtitle!,
                style: WarmOrganicBlueTheme.bodySmall.copyWith(
                  color: WarmOrganicBlueTheme.darkSlate,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null) ...[
              SizedBox(height: 20.h),
              OrganicPrimaryButton(
                text: buttonText!,
                onPressed: onButtonTap,
                width: 160.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ─── Organic Avatar ───────────────────────────────────────
class OrganicAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double? size;
  final Color? bgColor;

  const OrganicAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 44.r;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        gradient: WarmOrganicBlueTheme.primaryGradient,
        borderRadius: BorderRadius.circular(s / 2),
        boxShadow: WarmOrganicBlueTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s / 2),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials ?? '?',
        style: TextStyle(
          fontSize: (size ?? 44.r) * 0.38,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// ─── Organic Bottom Sheet Wrapper ─────────────────────────
class OrganicBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const OrganicBottomSheet({super.key, this.title, required this.child});

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
        ),
      ),
      builder: (_) => OrganicBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: WarmOrganicBlueTheme.warmSilver,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          if (title != null) ...[
            SizedBox(height: 12.h),
            Text(title!, style: WarmOrganicBlueTheme.headingMedium),
          ],
          SizedBox(height: 8.h),
          Flexible(child: child),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

/// ─── Organic Text Field ───────────────────────────────────
class OrganicTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const OrganicTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WarmOrganicBlueTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: WarmOrganicBlueTheme.darkSlate,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: WarmOrganicBlueTheme.bodyMedium.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

/// ─── Organic Divider ──────────────────────────────────────
class OrganicDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double? thickness;

  const OrganicDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        indent: indent ?? 0,
        endIndent: endIndent ?? 0,
        thickness: thickness ?? 1,
        color: WarmOrganicBlueTheme.warmSilver,
      ),
    );
  }
}

/// ─── Organic Icon Action Button ───────────────────────────
class OrganicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double? size;

  const OrganicIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: (color ?? WarmOrganicBlueTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusSm),
        ),
        child: Icon(
          icon,
          size: size ?? 20.sp,
          color: color ?? WarmOrganicBlueTheme.primaryBlue,
        ),
      ),
    );
  }
}

/// ─── Organic Popup Menu Button ────────────────────────────
class OrganicPopupMenu<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> items;
  final Widget child;
  final Color? shadowColor;

  const OrganicPopupMenu({
    super.key,
    required this.items,
    required this.child,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      elevation: 8,
      shadowColor:
          shadowColor ?? WarmOrganicBlueTheme.primaryBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
      ),
      color: Colors.white,
      itemBuilder: (_) => items,
      child: child,
    );
  }
}

/// ─── Organic Media Grid Item ──────────────────────────────
class OrganicMediaGridItem extends StatelessWidget {
  final Widget imageWidget;
  final String? label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const OrganicMediaGridItem({
    super.key,
    required this.imageWidget,
    this.label,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
          boxShadow: WarmOrganicBlueTheme.subtleShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
          child: Stack(
            children: [
              imageWidget,
              if (trailing != null)
                Positioned(top: 6.h, right: 6.w, child: trailing!),
              if (label != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          WarmOrganicBlueTheme.radiusMd,
                        ),
                        bottomRight: Radius.circular(
                          WarmOrganicBlueTheme.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      label!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
