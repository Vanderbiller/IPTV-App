import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileManager {
  static const String profilesKey = 'profiles';

  Future<List<Profile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(profilesKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((item) => Profile.fromMap(item)).toList();
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profiles.map((p) => p.toMap()).toList());
    await prefs.setString(profilesKey, encoded);
  }

  Future<void> addProfile(Profile profile) async {
    final profiles = await getProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
  }

  Future<void> deleteProfile(int index) async {
    final profiles = await getProfiles();
    if (index >= 0 && index < profiles.length) {
      profiles.removeAt(index);
      await saveProfiles(profiles);
    }
  }
}