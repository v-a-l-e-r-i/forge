import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  final _pageController = PageController();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sloganController = TextEditingController();
  final _primarySkillController = TextEditingController();

  File? _profileImage;

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _sloganController.dispose();
    _primarySkillController.dispose();
    super.dispose();
  }

  // Метод для вибору фотографії з галереї
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Обмежуємо розмір для економії пам'яті
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  bool _isCurrentStepValid() {
    if (_currentPage == 0) return _step1Key.currentState?.validate() ?? false;
    if (_currentPage == 1) return _step2Key.currentState?.validate() ?? false;
    if (_currentPage == 2) return _step3Key.currentState?.validate() ?? false;
    if (_currentPage == 3) {
      final isFormValid = _step4Key.currentState?.validate() ?? false;

      // Перевіряємо, чи користувач додав фото
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Будь ласка, завантажте фото персонажу!'),
            backgroundColor: Color(0xffD32F2F),
          ),
        );
        return false;
      }
      return isFormValid;
    }
    return false;
  }

  void _nextPage() {
    if (_isCurrentStepValid()) {
      if (_currentPage < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<String> _parseSkills(String raw) {
    return raw
        .split(RegExp(r'[,;]'))
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  Future<void> _submitRegistration() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().register(
        nickname: _nicknameController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        uploadedImageUrl: _profileImage!.path.trim(),
        slogan: _sloganController.text.trim(),
        abilitiesText: _parseSkills(_primarySkillController.text),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      // 1. Обов'язкова перевірка перед використанням context після await
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка реєстрації: $e'),
          backgroundColor: const Color(0xffD32F2F),
        ),
      );

      // 2. Викликаємо метод очищення
      _resetForm();

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Новий метод для скидання стану форми
  void _resetForm() {
    // Очищаємо всі контролери
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _nicknameController.clear();
    _passwordController.clear();
    _sloganController.clear();
    _primarySkillController.clear();

    setState(() {
      _profileImage = null; // Видаляємо вибране фото
      _currentPage = 0;     // Повертаємо лічильник на перший крок
    });

    // Миттєво перекидаємо PageView на першу сторінку без анімації
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    InputDecoration buildAdaptiveInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.onSurface,
                  size: 20,
                ),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          'Step ${_currentPage + 1} of 4',
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: colors.surface,
                    color: colors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildStep1Meet(colors, buildAdaptiveInputDecoration),
                      _buildStep2Nickname(colors, buildAdaptiveInputDecoration),
                      _buildStep3Password(colors, buildAdaptiveInputDecoration),
                      _buildStep4UploadPhoto(
                        colors,
                        buildAdaptiveInputDecoration,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 3 ? 'SUMMON CHARACTER ⚡' : 'CONTINUE ➔',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStep1Meet(
    ColorScheme colors,
    InputDecoration Function(String) decorationBuilder,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your real identity fields to connect with your team.',
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _lastNameController,
              style: TextStyle(color: colors.onSurface),
              maxLength: 50,
              decoration: decorationBuilder('Last Name (Прізвище)'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐ'\s-]"),
                ),
              ],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your last name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              style: TextStyle(color: colors.onSurface),
              maxLength: 50,
              decoration: decorationBuilder('First Name (Ім\'я)'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐ'\s-]"),
                ),
              ],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your first name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _middleNameController,
              style: TextStyle(color: colors.onSurface),
              maxLength: 50,
              decoration: decorationBuilder('Middle Name (По батькові)'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐ'\s-]"),
                ),
              ],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your middle name' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Nickname(
      ColorScheme colors,
      InputDecoration Function(String) decorationBuilder,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Identity',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your unique nickname and role will define your character.',
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nicknameController,
              style: TextStyle(color: colors.onSurface),
              decoration: decorationBuilder('Nickname (@username)'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nickname is required';
                if (v.trim().length < 3) return 'Too short (min 3 characters)';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // НОВЕ ПОЛЕ: Навичка / Клас / Професія
            TextFormField(
              controller: _primarySkillController,
              style: TextStyle(color: colors.onSurface),
              decoration: decorationBuilder('Primary Skill / Class (e.g. Developer, Designer)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your primary skill';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Password(
    ColorScheme colors,
    InputDecoration Function(String) decorationBuilder,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a secure password to protect your characters.',
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: colors.onSurface),
              decoration: decorationBuilder('Password'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required field';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4UploadPhoto(
      ColorScheme colors,
      InputDecoration Function(String) decorationBuilder,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step4Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a profile picture so your team can recognize you.',
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),

            // Віджет вибору фотографії
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _profileImage != null ? colors.primary : colors.surface,
                      width: 3,
                    ),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 48,
                        color: colors.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add',
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
            Text(
              'Your Battle Slogan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _sloganController,
              style: TextStyle(color: colors.onSurface),
              maxLength: 150,
              decoration: decorationBuilder(
                'Enter your personal motto / slogan',
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty
                  ? 'Write a short slogan for your profile'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
