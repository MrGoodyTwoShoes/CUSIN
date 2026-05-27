import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_constants.dart';
import '../../widgets/common/cusin_button.dart';

/// Onboarding screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.security,
      title: 'Community Safety',
      description: 'Report incidents anonymously and help keep your community safe.',
    ),
    OnboardingPage(
      icon: Icons.map,
      title: 'Real-time Awareness',
      description: 'View safety heatmaps and get real-time updates about your area.',
    ),
    OnboardingPage(
      icon: Icons.groups,
      title: 'Stay Connected',
      description: 'Join safety circles and stay connected with trusted contacts.',
    ),
    OnboardingPage(
      icon: Icons.privacy_tip,
      title: 'Privacy First',
      description: 'Your location is fuzzed for privacy. No biometrics or tracking.',
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageConstants.onboardingCompleted, true);
    
    if (mounted) {
      context.go('/auth/phone');
    }
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageConstants.onboardingCompleted, true);
    
    if (mounted) {
      context.go('/auth/phone');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text('Skip'),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: CUSINButton(
                  text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                  onPressed: _nextPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  
  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  
  const OnboardingPageWidget({
    super.key,
    required this.page,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
