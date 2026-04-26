import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/membership_loyalty_widgets/add_membership_dialog.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/widgets/membership_loyalty_widgets/create_promo_dialog.dart';
import 'package:aims/widgets/membership_loyalty_widgets/delete_membership_dialog.dart';
import 'package:aims/widgets/membership_loyalty_widgets/edit_hourly_pricing_dialog.dart';
import 'package:aims/widgets/membership_loyalty_widgets/edit_membership_dialog.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_action_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_section.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_table.dart';
import 'package:aims/widgets/utils/space_pricing.dart';
import 'package:flutter/material.dart';

class MembershipLoyaltyProgramScreen extends StatefulWidget {
  const MembershipLoyaltyProgramScreen({
    super.key,
    this.role = UserRole.staff,
  });

  final UserRole role;

  @override
  State<MembershipLoyaltyProgramScreen> createState() =>
      _MembershipLoyaltyProgramScreenState();
}

class _MembershipType {
  const _MembershipType({
    required this.type,
    required this.duration,
    required this.price,
    required this.benefits,
  });

  final String type;
  final String duration;
  final String price;
  final String benefits;
}

class _LoyaltyReward {
  const _LoyaltyReward({
    required this.memberName,
    required this.entries,
    required this.freeHours,
  });

  final String memberName;
  final String entries;
  final String freeHours;
}

class _Promotion {
  const _Promotion({
    required this.name,
    required this.type,
    required this.discount,
    required this.expiry,
  });

  final String name;
  final String type;
  final String discount;
  final String expiry;
}

class _MembershipLoyaltyProgramScreenState
    extends State<MembershipLoyaltyProgramScreen> {
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tan = Color(0xFFD7B59E);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _cardWhite = Color(0xF7FFFFFF);

  static const List<_LoyaltyReward> _rewards = [
    _LoyaltyReward(
      memberName: 'Mika Santos',
      entries: '8 visits',
      freeHours: '2 hours',
    ),
    _LoyaltyReward(
      memberName: 'Paolo Reyes',
      entries: '12 visits',
      freeHours: '4 hours',
    ),
    _LoyaltyReward(
      memberName: 'Andrea Lim',
      entries: '5 visits',
      freeHours: '1 hour',
    ),
  ];

  bool isSidebarOpen = true;
  String selectedMenu = 'Membership and Loyalty Program';
  late final List<_MembershipType> _memberships;
  late final List<_Promotion> _promotions;

  @override
  void initState() {
    super.initState();
    _memberships = [
      const _MembershipType(
        type: 'Monthly Membership',
        duration: '30 days',
        price: 'PHP 2,499',
        benefits: 'Flexible coworking access',
      ),
      const _MembershipType(
        type: 'Annual Membership',
        duration: '12 months',
        price: 'PHP 24,999',
        benefits: 'Priority booking and discounts',
      ),
      const _MembershipType(
        type: 'Student Pass',
        duration: '15 days',
        price: 'PHP 1,199',
        benefits: 'Discounted day access',
      ),
    ];
    _promotions = [
      const _Promotion(
        name: 'Summer Study Boost',
        type: 'Student Promo',
        discount: '15% off',
        expiry: 'May 30, 2026',
      ),
      const _Promotion(
        name: 'Team Workspace Bundle',
        type: 'Corporate Promo',
        discount: '20% off',
        expiry: 'June 15, 2026',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Header(
              role: widget.role,
              onMenuTap: () {
                setState(() {
                  isSidebarOpen = !isSidebarOpen;
                });
              },
              maxWidth: _desktopFrameWidth,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _desktopFrameWidth),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isSidebarOpen)
                        Sidebar(
                          role: widget.role,
                          selectedTitle: selectedMenu,
                          onItemSelected: _handleSidebarTap,
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final stackedButtons = constraints.maxWidth < 900;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  _buildPageHero(),
                                  const SizedBox(height: 18),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _buildInfoChip(
                                        label: 'Membership Types',
                                        value: '${_memberships.length}',
                                      ),
                                      _buildInfoChip(
                                        label: 'Reward Members',
                                        value: '${_rewards.length}',
                                      ),
                                      _buildInfoChip(
                                        label: 'Active Promos',
                                        value: '${_promotions.length}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  if (stackedButtons)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        MembershipProgramActionButton(
                                          label: 'Add Membership Type',
                                          backgroundColor: _tanSoft,
                                          textColor: _textPrimary,
                                          icon: Icons.add_card_rounded,
                                          onPressed: _openAddMembershipDialog,
                                        ),
                                        const SizedBox(height: 12),
                                        MembershipProgramActionButton(
                                          label: 'Create Promo',
                                          backgroundColor: _tanSoft,
                                          textColor: _textPrimary,
                                          icon: Icons.local_offer_outlined,
                                          onPressed: _openCreatePromoDialog,
                                        ),
                                        if (widget.role == UserRole.manager) ...[
                                          const SizedBox(height: 12),
                                          MembershipProgramActionButton(
                                            label: 'Update Hourly Rates',
                                            backgroundColor: Colors.white,
                                            textColor: _textPrimary,
                                            icon: Icons.payments_outlined,
                                            onPressed:
                                                _openEditHourlyPricingDialog,
                                          ),
                                        ],
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        MembershipProgramActionButton(
                                          label: 'Add Membership Type',
                                          backgroundColor: _tanSoft,
                                          textColor: _textPrimary,
                                          icon: Icons.add_card_rounded,
                                          onPressed: _openAddMembershipDialog,
                                        ),
                                        const SizedBox(width: 16),
                                        MembershipProgramActionButton(
                                          label: 'Create Promo',
                                          backgroundColor: _tanSoft,
                                          textColor: _textPrimary,
                                          icon: Icons.local_offer_outlined,
                                          onPressed: _openCreatePromoDialog,
                                        ),
                                        if (widget.role == UserRole.manager) ...[
                                          const SizedBox(width: 16),
                                          MembershipProgramActionButton(
                                            label: 'Update Hourly Rates',
                                            backgroundColor: Colors.white,
                                            textColor: _textPrimary,
                                            icon: Icons.payments_outlined,
                                            onPressed:
                                                _openEditHourlyPricingDialog,
                                          ),
                                        ],
                                      ],
                                    ),
                                  const SizedBox(height: 24),
                                  _buildHourlyPricingSection(),
                                  const SizedBox(height: 18),
                                  MembershipProgramSection(
                                    title: 'Membership Types',
                                    subtitle: 'Review available plans and their inclusions.',
                                    backgroundColor: _panelBlue,
                                    textColor: _textPrimary,
                                    child: MembershipProgramTable(
                                      headers: const [
                                        'Type',
                                        'Duration',
                                        'Price',
                                        'Benefits',
                                        '',
                                      ],
                                      flexes: const [3, 2, 2, 3, 2],
                                      rows: _memberships
                                          .map(
                                            (membership) => [
                                              membership.type,
                                              membership.duration,
                                              membership.price,
                                              membership.benefits,
                                              'Edit    Delete',
                                            ],
                                          )
                                          .toList(),
                                      headerColor: _tan,
                                      primaryTextColor: _textPrimary,
                                      actionTextColor: _headerBlue,
                                      actionColumnIndex: 4,
                                      actionBuilder: _buildMembershipActions,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  MembershipProgramSection(
                                    title: 'Loyalty Rewards Tracking',
                                    subtitle: 'Monitor visits and complimentary hours.',
                                    backgroundColor: _panelBlue,
                                    textColor: _textPrimary,
                                    child: MembershipProgramTable(
                                      headers: const [
                                        'Members Name',
                                        'Entries',
                                        'Free Hours',
                                      ],
                                      flexes: const [4, 3, 2],
                                      rows: _rewards
                                          .map(
                                            (reward) => [
                                              reward.memberName,
                                              reward.entries,
                                              reward.freeHours,
                                            ],
                                          )
                                          .toList(),
                                      headerColor: _tan,
                                      primaryTextColor: _textPrimary,
                                      actionTextColor: _headerBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  MembershipProgramSection(
                                    title: 'Active Promotions',
                                    subtitle: 'Current promo campaigns available to members.',
                                    backgroundColor: _panelBlue,
                                    textColor: _textPrimary,
                                    child: MembershipProgramTable(
                                      headers: const [
                                        'Promo',
                                        'Type',
                                        'Discount',
                                        'Expiry',
                                      ],
                                      flexes: const [4, 3, 2, 2],
                                      rows: _promotions
                                          .map(
                                            (promotion) => [
                                              promotion.name,
                                              promotion.type,
                                              promotion.discount,
                                              promotion.expiry,
                                            ],
                                          )
                                          .toList(),
                                      headerColor: _tan,
                                      primaryTextColor: _textPrimary,
                                      actionTextColor: _headerBlue,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSidebarTap(String title) {
    if (title == selectedMenu) {
      return;
    }

    if (title == 'Dashboard') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager
            ? '/manager-dashboard'
            : '/staff-dashboard',
      );
      return;
    }

    if (title == 'Calendar') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager ? '/manager-calendar' : '/calendar',
      );
      return;
    }

    if (title == 'List of Users') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager ? '/manager-users' : '/staff-users',
      );
      return;
    }
  }

  Future<void> _openCreatePromoDialog() async {
    final result = await showDialog<PromoDialogResult>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (_) => const CreatePromoDialog(),
    );

    if (result == null || result.name.isEmpty) {
      return;
    }

    setState(() {
      _promotions.insert(
        0,
        _Promotion(
          name: result.name,
          type: result.type,
          discount: result.discount,
          expiry: result.expiry,
        ),
      );
    });
  }

  Future<void> _openAddMembershipDialog() async {
    final result = await showDialog<AddMembershipDialogResult>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (_) => const AddMembershipDialog(),
    );

    if (result == null || result.type.isEmpty) {
      return;
    }

    setState(() {
      _memberships.insert(
        0,
        _MembershipType(
          type: result.type,
          duration: result.duration,
          price: result.price,
          benefits: result.benefits,
        ),
      );
    });
  }

  Future<void> _openEditHourlyPricingDialog() async {
    if (widget.role != UserRole.manager) {
      return;
    }

    final pricing = SpacePricingStore.current;
    final result = await showDialog<HourlyPricingDialogResult>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (_) => EditHourlyPricingDialog(
        initialBoardRoomRate: pricing.boardRoomHourlyRate,
        initialOrdinarySpaceRate: pricing.ordinarySpaceHourlyRate,
      ),
    );

    if (result == null) {
      return;
    }

    SpacePricingStore.update(
      boardRoomHourlyRate: result.boardRoomHourlyRate,
      ordinarySpaceHourlyRate: result.ordinarySpaceHourlyRate,
    );
  }

  Future<void> _editMembership(int index) async {
    final membership = _memberships[index];
    final result = await showDialog<MembershipDialogResult>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (_) => EditMembershipDialog(
        initialType: membership.type,
        initialDuration: membership.duration,
        initialPrice: membership.price,
        initialBenefits: membership.benefits,
      ),
    );

    if (result == null || result.type.isEmpty) {
      return;
    }

    setState(() {
      _memberships[index] = _MembershipType(
        type: result.type,
        duration: result.duration,
        price: result.price,
        benefits: result.benefits,
      );
    });
  }

  Future<void> _deleteMembership(int index) async {
    final membership = _memberships[index];
    final shouldDelete = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.18),
          builder: (_) => DeleteMembershipDialog(
            membershipType: membership.type,
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    setState(() {
      _memberships.removeAt(index);
    });
  }

  Widget _buildPageHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _panelBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.card_membership_rounded,
              color: _headerBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership and Loyalty Program',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track membership plans, loyalty rewards, and active promos for staff operations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _headerBlue,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyPricingSection() {
    return MembershipProgramSection(
      title: 'Hourly Space Charges',
      subtitle: widget.role == UserRole.manager
          ? 'Manager-controlled hourly pricing for checkout transactions.'
          : 'Current hourly pricing applied during checkout transactions.',
      backgroundColor: _panelBlue,
      textColor: _textPrimary,
      child: ValueListenableBuilder<SpacePricing>(
        valueListenable: SpacePricingStore.pricingNotifier,
        builder: (context, pricing, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _buildRateCard(
                    title: 'Board Room',
                    value: SpacePricingStore.formatCurrency(
                      pricing.boardRoomHourlyRate,
                    ),
                    description: 'Hourly charge for boardroom bookings.',
                    icon: Icons.meeting_room_outlined,
                  ),
                  _buildRateCard(
                    title: 'Ordinary Space',
                    value: SpacePricingStore.formatCurrency(
                      pricing.ordinarySpaceHourlyRate,
                    ),
                    description: 'Hourly charge for regular seats and open spaces.',
                    icon: Icons.event_seat_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.role == UserRole.manager
                    ? 'These values can be updated by the manager using the button above.'
                    : 'Only the manager can update these hourly charges.',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRateCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _tanSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _headerBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _headerBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipActions(int rowIndex) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 6,
      children: [
        InkWell(
          onTap: () => _editMembership(rowIndex),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.95)),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _headerBlue,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () => _deleteMembership(rowIndex),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAEA),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF3C7C7)),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC95656),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
