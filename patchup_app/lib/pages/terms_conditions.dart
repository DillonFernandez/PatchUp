//
// Terms and Conditions page for PatchUp app.
// Displays legal information, usage terms, and privacy details.
//

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

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
          appLoc.translate('Terms and Conditions Title'),
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
              // Hero section with icon and subtitle
              _buildHeroSection(context, appLoc),
              const SizedBox(height: 24),

              // Welcome section
              _buildWelcomeSection(context, appLoc),
              const SizedBox(height: 20),

              // Terms sections (numbered)
              _buildTermsSection(context, appLoc, 1, Icons.public_rounded),
              const SizedBox(height: 16),
              _buildTermsSection(
                context,
                appLoc,
                2,
                Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildTermsSection(
                context,
                appLoc,
                3,
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildTermsSection(context, appLoc, 4, Icons.camera_alt_outlined),
              const SizedBox(height: 16),
              _buildTermsSection(
                context,
                appLoc,
                5,
                Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildTermsSection(context, appLoc, 6, Icons.money_off_rounded),
              const SizedBox(height: 16),
              _buildTermsSection(context, appLoc, 7, Icons.map_outlined),
              const SizedBox(height: 16),
              _buildTermsSection(
                context,
                appLoc,
                8,
                Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 16),
              _buildTermsSection(context, appLoc, 9, Icons.update_rounded),
              const SizedBox(height: 20),

              // Footer section
              _buildFooter(context, appLoc),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the hero section with icon and subtitle
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
              child: Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appLoc.translate('Terms and Conditions Title'),
              style: TextStyle(
                fontSize: 22,
                color: primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appLoc.translate('Terms and Conditions Last Updated'),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
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

  /// Builds the welcome section card
  Widget _buildWelcomeSection(BuildContext context, AppLocalizations appLoc) {
    return _buildSectionCard(
      context,
      title: appLoc.translate('Terms and Conditions Welcome Title'),
      icon: Icons.info_outline_rounded,
      content: appLoc.translate('Terms and Conditions Welcome Description'),
      isWelcome: true,
    );
  }

  /// Builds individual terms section card
  Widget _buildTermsSection(
    BuildContext context,
    AppLocalizations appLoc,
    int sectionNumber,
    IconData icon,
  ) {
    return _buildSectionCard(
      context,
      title: appLoc.translate('Terms and Conditions $sectionNumber Title'),
      icon: icon,
      content: appLoc.translate(
        'Terms and Conditions $sectionNumber Description',
      ),
    );
  }

  /// Builds a section card for terms or welcome
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    bool isWelcome = false,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient:
                        isWelcome
                            ? LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.15),
                                accentColor.withOpacity(0.1),
                              ],
                            )
                            : LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.1),
                                primaryColor.withOpacity(0.05),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isWelcome ? primaryColor : accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isWelcome ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 0.1,
                    ),
                    softWrap: true,
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
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the footer section
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
