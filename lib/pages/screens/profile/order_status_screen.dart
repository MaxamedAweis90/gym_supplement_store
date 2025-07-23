import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusScreen extends StatelessWidget {
  final QueryDocumentSnapshot order;
  const OrderStatusScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = order.data() as Map<String, dynamic>;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final onTheWayAt = (data['onTheWayAt'] as Timestamp?)?.toDate();
    final deliveredAt = (data['deliveredAt'] as Timestamp?)?.toDate();
    final status = (data['status'] ?? 'pending').toString().toLowerCase();
    // Determine current step
    int currentStep = 0;
    if (status == 'on the way' || status == 'shipped') currentStep = 1;
    if (status == 'delivered' ||
        status == 'arrived' ||
        status == 'complete' ||
        status == 'completed')
      currentStep = 2;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Order Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18, top: 8),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: theme.colorScheme.onBackground,
                    size: 28,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      // Top illustration (no background circle)
                      Center(
                        child: Image.asset(
                          'assets/images/order.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 18),
                      // Timeline
                      _OrderTimeline(
                        createdAt: createdAt,
                        onTheWayAt: onTheWayAt,
                        deliveredAt: deliveredAt,
                        theme: theme,
                        currentStep: currentStep,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    currentStep == 2
                        ? 'Order Delivered'
                        : 'The order is on the way',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? onTheWayAt;
  final DateTime? deliveredAt;
  final ThemeData theme;
  final int currentStep;
  const _OrderTimeline({
    required this.createdAt,
    required this.onTheWayAt,
    required this.deliveredAt,
    required this.theme,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _TimelineRow(
          icon: Icons.access_time_rounded,
          label: 'Order received',
          time: createdAt != null ? _formatTime(createdAt!) : '-',
          isActive: currentStep == 0,
          highlight: false,
          theme: theme,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Align the dashed divider with the icon
            Container(
              width: 40, // same as icon width
              alignment: Alignment.center,
              child: _DashedDivider(isActive: currentStep >= 1, theme: theme),
            ),
            SizedBox(width: 22),
            Expanded(child: SizedBox()),
          ],
        ),
        _TimelineRow(
          icon: Icons.location_on_rounded,
          label: 'On the way',
          time: onTheWayAt != null ? _formatTime(onTheWayAt!) : '-',
          isActive: currentStep == 1,
          highlight: false,
          theme: theme,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: _DashedDivider(isActive: currentStep == 2, theme: theme),
            ),
            SizedBox(width: 22),
            Expanded(child: SizedBox()),
          ],
        ),
        _TimelineRow(
          icon: Icons.local_shipping_rounded,
          label: 'Delivered',
          time: deliveredAt != null
              ? _formatTime(deliveredAt!)
              : 'Finish time in 45 min',
          isActive: currentStep == 2,
          highlight: currentStep == 2,
          theme: theme,
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}, ${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}

class _TimelineIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final ThemeData theme;
  const _TimelineIcon({
    required this.icon,
    required this.isActive,
    required this.theme,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.disabledColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool isActive;
  final bool highlight;
  final ThemeData theme;
  const _TimelineRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.isActive,
    required this.highlight,
    required this.theme,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TimelineIcon(
          icon: icon,
          isActive: isActive || highlight,
          theme: theme,
        ),
        SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: highlight
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    time,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: highlight
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onBackground,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final bool isActive;
  final ThemeData theme;
  const _DashedDivider({this.isActive = false, required this.theme});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      height: 38,
      width: 2,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: isActive
              ? theme.colorScheme.primary
              : theme.disabledColor.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 2.0;
    const dashSpace = 4.0;
    double startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
