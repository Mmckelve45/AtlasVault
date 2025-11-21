import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:atlasvault/models/asset.dart';
import 'package:atlasvault/widgets/custom_card.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    Color getStatusColor() {
      switch (asset.status) {
        case AssetStatus.active:
          return const Color(0xFF10B981);
        case AssetStatus.inactive:
          return const Color(0xFF6B7280);
        case AssetStatus.maintenance:
          return const Color(0xFFF59E0B);
        case AssetStatus.disposed:
          return const Color(0xFFEF4444);
      }
    }

    return CustomCard(
      onTap: onTap,
      // Green variant with a vibrant emerald glow
      backgroundColor: const Color(0xFF10B981),
      shadowColor: const Color(0xFF34D399),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  asset.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Use a subtle translucent white chip for contrast on green
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asset.statusDisplayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            asset.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: Colors.white,
              ),
              Text(
                currencyFormatter.format(asset.value),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (asset.location != null) ...[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    asset.location!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}