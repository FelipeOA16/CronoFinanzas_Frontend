import 'package:flutter/material.dart';

import '../brand/crono_brand_theme.dart';
import 'cf_button.dart';
import 'cf_card.dart';

class CFFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CFFormHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.brandTypography.headline),
        SizedBox(height: context.brandSpacing.space4),
        Text(
          subtitle,
          style: context.brandTypography.body.copyWith(
            color: context.brandColors.grisNeutro,
          ),
        ),
      ],
    );
  }
}

class CFFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const CFFormSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: context.brandTypography.title.copyWith(
            color: context.brandColors.azulAndino,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: context.brandSpacing.space4),
          Text(subtitle!, style: context.brandTypography.caption),
        ],
        SizedBox(height: context.brandSpacing.space12),
        child,
      ],
    );
  }
}

class CFFormSwitchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CFFormSwitchCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      color: context.brandColors.marfil,
      borderColor: context.brandColors.border,
      padding: EdgeInsets.symmetric(
        horizontal: context.brandSpacing.space16,
        vertical: context.brandSpacing.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.brandTypography.subtitle),
                SizedBox(height: context.brandSpacing.space4),
                Text(subtitle, style: context.brandTypography.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class CFFormActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool loading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const CFFormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.loading = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: CFButton(
            label: primaryLabel,
            onPressed: onPrimary,
            loading: loading,
          ),
        ),
        if (secondaryLabel != null) ...[
          SizedBox(height: context.brandSpacing.space8),
          SizedBox(
            height: 48,
            child: CFOutlinedButton(
              label: secondaryLabel!,
              onPressed: onSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class CFFormSurface extends StatelessWidget {
  final Widget child;

  const CFFormSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      elevated: true,
      color: context.brandColors.surface,
      borderColor: context.brandColors.border,
      padding: EdgeInsets.all(context.brandSpacing.space24),
      child: child,
    );
  }
}

class CFFormSegmented<T> extends StatelessWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  const CFFormSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      showSelectedIcon: false,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : context.brandColors.azulAndino,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? context.brandColors.verdeValle
              : context.brandColors.surface,
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: context.brandColors.border),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.brandRadius.radius12),
          ),
        ),
      ),
    );
  }
}
