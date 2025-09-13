//
// AboutContactUsPage: Displays app info, team, vision, contact details, and footer.
//

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AboutContactUsPage extends StatelessWidget {
  const AboutContactUsPage({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF04274B);
  static const Color accentColor = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          appLoc.translate('About & Contact Us'),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Hero section
              _buildHeroSection(context, appLoc),
              const SizedBox(height: 24),

              // About section
              _buildAboutSection(context, appLoc),
              const SizedBox(height: 20),

              // Vision & Mission section
              _buildVisionMissionSection(context, appLoc),
              const SizedBox(height: 20),

              // Why PatchUp section
              _buildWhyPatchUpSection(context, appLoc),
              const SizedBox(height: 20),

              // Team section
              _buildTeamSection(context, appLoc),
              const SizedBox(height: 20),

              // Contact section
              _buildContactSection(context, appLoc),
              const SizedBox(height: 20),

              // Footer
              _buildFooter(context, appLoc),
            ],
          ),
        ),
      ),
    );
  }

  // Builds hero section with logo and subtitle
  Widget _buildHeroSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryColor, accentColor]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 48,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo/Logo 1.webp',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appLoc.translate('Smart Pothole Reporting & Management'),
              style: TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appLoc.translate('Connecting communities for safer roads'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds about section card
  Widget _buildAboutSection(BuildContext context, AppLocalizations appLoc) {
    return _buildSectionCard(
      context,
      title: appLoc.translate('Who We Are'),
      icon: Icons.info_outline_rounded,
      content: appLoc.translate('Who We Are Description'),
    );
  }

  // Builds vision and mission section
  Widget _buildVisionMissionSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vision
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.visibility_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('Our Vision'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appLoc.translate('Our Vision Description'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Mission
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.1),
                        primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.flag_rounded, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('Our Mission'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appLoc.translate('Our Mission Description'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds "Why PatchUp" section card
  Widget _buildWhyPatchUpSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return _buildSectionCard(
      context,
      title: appLoc.translate('Why PatchUp?'),
      icon: Icons.lightbulb_outline_rounded,
      content: appLoc.translate('Why PatchUp Description'),
      gradient: [
        Colors.orange.withOpacity(0.1),
        Colors.orange.withOpacity(0.05),
      ],
      iconColor: Colors.orange[700]!,
    );
  }

  // Builds team section card
  Widget _buildTeamSection(BuildContext context, AppLocalizations appLoc) {
    return _buildSectionCard(
      context,
      title: appLoc.translate('Our Team'),
      icon: Icons.group_rounded,
      content: appLoc.translate('Our Team Description'),
      gradient: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
      iconColor: Colors.green[700]!,
    );
  }

  // Builds contact section with contact items
  Widget _buildContactSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('Contact Us'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appLoc.translate('Contact Us Description'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Contact Items
            _buildContactItem(
              icon: Icons.email_rounded,
              text: appLoc.translate('Email'),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              icon: Icons.phone_rounded,
              text: appLoc.translate('Phone'),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Builds individual contact item
  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                fontSize: 15,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a generic section card
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    List<Color>? gradient,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient:
                        gradient != null
                            ? LinearGradient(colors: gradient)
                            : LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.1),
                                accentColor.withOpacity(0.05),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor ?? primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds footer section
  Widget _buildFooter(BuildContext context, AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appLoc.translate('Copyright'),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
