import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/theme.dart';

/// Edit Profile Screen
/// Allows users to update their profile information (name, email, and profile picture)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _hasChanges = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Add listeners to detect changes
    _fullNameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _fullNameController.text = user.userMetadata?['full_name'] ?? '';
      _emailController.text = user.email ?? '';
      _currentAvatarUrl = user.userMetadata?['avatar_url'];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          if (!kIsWeb) {
            _selectedImage = File(pickedFile.path);
          }
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: ChainlyTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: ChainlyTheme.primaryColor),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: ChainlyTheme.primaryColor),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImageBytes != null || _currentAvatarUrl != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ChainlyTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: ChainlyTheme.errorColor),
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                      _currentAvatarUrl = null;
                      _hasChanges = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkForChanges() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final hasNameChanged = _fullNameController.text != (user.userMetadata?['full_name'] ?? '');
      final hasEmailChanged = _emailController.text != (user.email ?? '');
      
      setState(() {
        _hasChanges = hasNameChanged || hasEmailChanged;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final currentEmail = user.email ?? '';
      final newEmail = _emailController.text.trim();
      final newFullName = _fullNameController.text.trim();
      String? avatarUrl = _currentAvatarUrl;

      // Upload profile picture if a new image was selected
      if (_selectedImageBytes != null) {
        try {
          // Upload to 'private' folder to match the bucket policy
          final fileName = 'private/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          // Upload to Supabase Storage
          await Supabase.instance.client.storage
              .from('avatars')
              .uploadBinary(
                fileName,
                _selectedImageBytes!,
                fileOptions: const FileOptions(
                  upsert: true,
                  contentType: 'image/jpeg',
                ),
              );
          
          // Get public URL
          avatarUrl = Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(fileName);
        } catch (storageError) {
          // If storage upload fails, continue without avatar update
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile picture upload failed: ${storageError.toString()}\n'
                  'Please create an "avatars" bucket in Supabase Storage (Settings > Storage > New Bucket).\n'
                  'Your name and email will still be updated.',
                ),
                backgroundColor: ChainlyTheme.warningColor,
                duration: const Duration(seconds: 6),
              ),
            );
          }
          // Keep existing avatar URL if upload fails
          avatarUrl = _currentAvatarUrl;
        }
      } else if (_selectedImageBytes == null && _currentAvatarUrl != null) {
        // User removed the avatar
        avatarUrl = null;
      }

      // Always update user metadata with name and avatar
      final Map<String, dynamic> metadata = {
        'full_name': newFullName,
        'avatar_url': avatarUrl,
      };

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: metadata),
      );

      // Update email if changed
      if (newEmail != currentEmail) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: newEmail),
        );
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Email Verification Required'),
              content: const Text(
                'A verification email has been sent to your new email address. '
                'Please verify your new email to complete the change.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to profile
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: ChainlyTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: ChainlyTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ChainlyTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: ChainlyTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: ChainlyTheme.buttonShadow,
                            ),
                            child: ClipOval(
                              child: _selectedImageBytes != null
                                  ? Image.memory(
                                      _selectedImageBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : _currentAvatarUrl != null
                                      ? Image.network(
                                          _currentAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildInitialsAvatar();
                                          },
                                        )
                                      : _buildInitialsAvatar(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ChainlyTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Profile Picture',
                        style: TextStyle(
                          fontSize: 14,
                          color: ChainlyTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Full Name Field
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline, color: ChainlyTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: ChainlyTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: ChainlyTheme.surfaceColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Email Field
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined, color: ChainlyTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      borderSide: BorderSide(color: ChainlyTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: ChainlyTheme.surfaceColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                        size: 16, 
                        color: ChainlyTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Changing your email will require verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: ChainlyTheme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChainlyTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ChainlyTheme.textPrimary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: ChainlyTheme.primaryGradient,
      ),
      child: Center(
        child: Text(
          _getInitials(_fullNameController.text),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
