import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../managers/profile_manager.dart';
import '../managers/image_manager.dart';
import '../widgets/add_profile_widget.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String title;

  const ProfileScreen({super.key, this.title = "Whos watching today?"});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileManager _profileManager = ProfileManager();
  List<Profile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final list = await _profileManager.getProfiles();
    setState(() {
      _profiles = list;
      _isLoading = false;
    });
  }

  void _onAddProfile() async {
    showDialog(
      context: context,
      builder: (ctx) => AddProfileWidget(
        onSave: (name, url, imagePath) async {
          String? storedPath = "";
          if (imagePath != null && imagePath.isNotEmpty) {
            storedPath = await ImageManager.saveImage(imagePath);
          }
          final newProfile = Profile(name: name, url: url, imgPath: storedPath);
          await _profileManager.addProfile(newProfile);
          _loadProfiles();
        },
      ),
    );
  }

  void _onManageProfiles() {
    _deleteAllProfilesAndImages();
  }

  Future<void> _deleteAllProfilesAndImages() async {
    for (final profile in _profiles) {
      if (profile.imgPath.isNotEmpty) {
        await ImageManager.deleteImage(profile.imgPath);
      }
    }
    await _profileManager.saveProfiles([]);
    _loadProfiles();
  }

  _onProfileTap(Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(m3uUrl: profile.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.black, Colors.red]
                : [Colors.white, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 36),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 28,
                      crossAxisSpacing: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      childAspectRatio: 0.9,
                      children: [
                        ..._profiles.map((p) => _ProfileTile(
                          profile: p,
                          onTap: () => _onProfileTap(p),
                        )),
                        _AddProfileTile(onTap: _onAddProfile),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _onManageProfiles,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'MANAGE PROFILES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const _ProfileTile({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: SizedBox(
                width: 104,
                height: 104,
                child: ImageManager.getImage(
                  profile.imgPath,
                  size: 104,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.24),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add Profile',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}