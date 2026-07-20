import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (_user == null && args is UserModel) {
      _user = args;
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _apiService.getUserProfile();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar', style: AppTextStyles.h2),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;
  
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text('Profil', style: AppTextStyles.h1),
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.navyText,
                elevation: 0,
                centerTitle: false,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_errorMessage != null && user == null)
                      _buildErrorState()
                    else if (user != null) ...[
                      _buildProfileHeader(user),
                      SizedBox(height: AppConstants.spacing24),
                      _buildInfoCard(user),
                      SizedBox(height: AppConstants.spacing24),
                      _buildMenuSection(),
                      SizedBox(height: AppConstants.spacing24),
                      _buildLogoutButton(),
                      SizedBox(height: AppConstants.spacing32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final roleLabel = user.role.isEmpty ? 'User' : user.role;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing24,
        AppConstants.spacing32,
        AppConstants.spacing24,
        40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.skyBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.pureWhite,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacing16),
          Text(
            user.name,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.pureWhite,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),  
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleLabel,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserModel user) {
    final infoItems = [
      _InfoRow(icon: Icons.person_outline_rounded, label: 'Nama', value: user.name),
      _InfoRow(icon: Icons.alternate_email_rounded, label: 'Username', value: user.username),
      _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
      _InfoRow(icon: Icons.badge_outlined, label: 'Role', value: user.role),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Akun', style: AppTextStyles.h2),
          SizedBox(height: AppConstants.spacing16),
          ...infoItems.map((item) {
            final index = infoItems.indexOf(item);
            final isLast = index == infoItems.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppConstants.spacing16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      _MenuTile(
        icon: Icons.settings_outlined,
        label: 'Pengaturan Akun',
        onTap: () {},
      ),  
      _MenuTile(
        icon: Icons.help_outline_rounded,
        label: 'Bantuan & Dukungan',
        onTap: () {},
      ),
      _MenuTile(
        icon: Icons.info_outline_rounded,
        label: 'Tentang Aplikasi',
        onTap: () {},
      ),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: EdgeInsets.all(AppConstants.spacing8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          final index = menuItems.indexOf(item);
          final isLast = index == menuItems.length - 1;
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
                vertical: AppConstants.spacing14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacing16),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.slateText.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(top: AppConstants.spacing14),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.lightBlueBg,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      child: OutlinedButton(
        onPressed: _confirmLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dangerRed,
          side: const BorderSide(color: AppColors.dangerRed, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: AppColors.dangerRed),
            SizedBox(width: AppConstants.spacing8),
            Text(
              'Keluar',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.dangerRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: EdgeInsets.all(AppConstants.spacing32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          SizedBox(height: AppConstants.spacing20),
          Container(
            width: 160,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: AppColors.dangerRed.withValues(alpha: 0.6),
          ),
          SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Gagal memuat data profil',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _MenuTile {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
