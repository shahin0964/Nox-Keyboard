import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../services/ime_platform_bridge.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> with WidgetsBindingObserver {
  final ImePlatformBridge _bridge = ImePlatformBridge();

  String _currentVersion = '...';
  bool _autoCheck = true;
  bool _hasInstallPerm = true;
  bool _hasNotifPerm = true;

  bool _isChecking = false;
  bool _isDownloading = false;
  int _downloadPercent = 0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;

  Map<String, dynamic>? _updateInfo;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bindCallbacks();
    _loadInitialState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.onOtaProgressCallback = null;
    _bridge.onOtaCompleteCallback = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionsAndVersion();
    }
  }

  void _bindCallbacks() {
    _bridge.onOtaProgressCallback = (percent, downloaded, total) {
      if (!mounted) return;
      setState(() {
        _isDownloading = true;
        _downloadPercent = percent.clamp(0, 100);
        _downloadedBytes = downloaded;
        _totalBytes = total;
        _isError = false;
      });
    };

    _bridge.onOtaCompleteCallback = (status, message) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _statusMessage = message;
        _isError = status == 'FAILED';
      });
      if (status == 'PERMISSION_REQUIRED') {
        _refreshPermissionsAndVersion();
      }
    };
  }

  Future<void> _loadInitialState() async {
    await _refreshPermissionsAndVersion();
    final auto = await _bridge.getAutoCheckUpdates();
    if (mounted) {
      setState(() => _autoCheck = auto);
    }
    await _checkForUpdates(silentIfFailed: false);
  }

  Future<void> _refreshPermissionsAndVersion() async {
    final version = await _bridge.getAppVersion();
    final canInstall = await _bridge.canRequestPackageInstalls();
    final hasNotif = await _bridge.hasNotificationPermission();
    if (!mounted) return;
    setState(() {
      _currentVersion = version;
      _hasInstallPerm = canInstall;
      _hasNotifPerm = hasNotif;
    });
  }

  Future<void> _checkForUpdates({bool silentIfFailed = false}) async {
    if (_isChecking || _isDownloading) return;
    setState(() {
      _isChecking = true;
      _statusMessage = null;
      _isError = false;
    });

    final result = await _bridge.checkForUpdate(notify: false);
    if (!mounted) return;

    final success = result['success'] == true;
    setState(() {
      _isChecking = false;
      if (success) {
        _updateInfo = result;
        final current = result['currentVersion']?.toString();
        if (current != null && current.isNotEmpty) {
          _currentVersion = current;
        }
      } else if (!silentIfFailed) {
        _isError = true;
        _statusMessage =
            result['error']?.toString() ?? 'Unable to check for updates.';
      }
    });
  }

  Future<void> _startDownloadAndInstall() async {
    final apkUrl = _updateInfo?['apkUrl']?.toString() ?? '';
    final tagName = _updateInfo?['tagName']?.toString() ?? 'latest';
    if (apkUrl.isEmpty) {
      setState(() {
        _isError = true;
        _statusMessage = 'No APK download link found in this release.';
      });
      return;
    }

    final canInstall = await _bridge.canRequestPackageInstalls();
    if (!mounted) return;
    setState(() => _hasInstallPerm = canInstall);

    if (!canInstall) {
      await _bridge.openInstallPermissionSettings();
      setState(() {
        _isError = false;
        _statusMessage =
            'Please allow "Install unknown apps" for Nox Keyboard, then tap Update again.';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadPercent = 0;
      _downloadedBytes = 0;
      _totalBytes = (_updateInfo?['apkSize'] as num?)?.toInt() ?? 0;
      _statusMessage = 'Downloading update package...';
      _isError = false;
    });

    await _bridge.downloadAndInstallUpdate(apkUrl, tagName);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    if (mb < 1) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final hasUpdate = _updateInfo?['hasUpdate'] == true;
    final latestVersion = _updateInfo?['latestVersion']?.toString() ?? '';
    final releaseName = _updateInfo?['releaseName']?.toString() ?? '';
    final releaseNotes = _updateInfo?['releaseNotes']?.toString() ?? '';
    final apkSize = (_updateInfo?['apkSize'] as num?)?.toInt() ?? 0;

    return ModernScaffold(
      title: 'App Updates (OTA)',
      actions: [
        IconButton(
          onPressed: _isChecking || _isDownloading
              ? null
              : () => _checkForUpdates(),
          icon: const Icon(CupertinoIcons.refresh, color: Colors.white),
          tooltip: 'Check now',
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: hasUpdate
                ? const Color(0xFF00E5FF).withValues(alpha: 0.45)
                : const Color(0xFF10B981).withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: hasUpdate
                              ? [
                                  const Color(0xFF00E5FF).withValues(alpha: 0.28),
                                  const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                ]
                              : [
                                  const Color(0xFF10B981).withValues(alpha: 0.28),
                                  const Color(0xFF059669).withValues(alpha: 0.16),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        hasUpdate
                            ? CupertinoIcons.arrow_down_circle_fill
                            : CupertinoIcons.checkmark_seal_fill,
                        color: hasUpdate
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF34D399),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isChecking
                                ? 'Checking GitHub Releases...'
                                : hasUpdate
                                    ? 'New Update Available!'
                                    : 'Nox Keyboard is Up to Date',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latestVersion.isNotEmpty
                                ? 'Installed: v$_currentVersion  •  Latest: v$latestVersion'
                                : 'Installed version: v$_currentVersion',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isChecking) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: Color(0x22FFFFFF),
                      valueColor: AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                    ),
                  ),
                ],
                if (_isDownloading) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Downloading APK... $_downloadPercent%',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _totalBytes > 0
                            ? '${_formatBytes(_downloadedBytes)} / ${_formatBytes(_totalBytes)}'
                            : _formatBytes(_downloadedBytes),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadPercent > 0 ? _downloadPercent / 100.0 : null,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                    ),
                  ),
                ],
                if (_statusMessage != null && _statusMessage!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: (_isError
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF00E5FF))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_isError
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF00E5FF))
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _isError
                            ? const Color(0xFFFCA5A5)
                            : Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: hasUpdate
                      ? FilledButton.icon(
                          onPressed:
                              _isDownloading ? null : _startDownloadAndInstall,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: const Color(0xFF06131F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.cloud_download_fill),
                          label: Text(
                            _isDownloading
                                ? 'Downloading $_downloadPercent%...'
                                : apkSize > 0
                                    ? 'Download & Install v$latestVersion (${_formatBytes(apkSize)})'
                                    : 'Download & Install v$latestVersion',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: _isChecking || _isDownloading
                              ? null
                              : () => _checkForUpdates(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E5FF),
                            side: BorderSide(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.refresh_thick),
                          label: const Text(
                            'Check for Updates',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),

          if (hasUpdate && (releaseName.isNotEmpty || releaseNotes.isNotEmpty)) ...[
            const SizedBox(height: 20),
            const ModernSectionHeader(
              title: 'WHAT\'S NEW',
              accentColor: Color(0xFF00E5FF),
            ),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (releaseName.isNotEmpty) ...[
                    Text(
                      releaseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    releaseNotes.isNotEmpty
                        ? releaseNotes
                        : 'Performance improvements, bug fixes, and keyboard refinements.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const ModernSectionHeader(
            title: 'OTA SETTINGS & PERMISSIONS',
            accentColor: Color(0xFF34D399),
          ),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                ModernSwitchTile(
                  icon: CupertinoIcons.bell_fill,
                  iconColor: const Color(0xFF00E5FF),
                  title: 'Auto-Check & Notify',
                  subtitle:
                      'Automatically check GitHub Releases & show a notification when a new update arrives',
                  value: _autoCheck,
                  onChanged: (val) async {
                    setState(() => _autoCheck = val);
                    await _bridge.setAutoCheckUpdates(val);
                    if (val && !_hasNotifPerm) {
                      await _bridge.requestNotificationPermission();
                      await _refreshPermissionsAndVersion();
                    }
                  },
                ),
                Divider(
                  color: Colors.white.withValues(alpha: 0.07),
                  height: 1,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: ModernIconBadge(
                    icon: _hasInstallPerm
                        ? CupertinoIcons.checkmark_shield_fill
                        : CupertinoIcons.exclamationmark_shield_fill,
                    color: _hasInstallPerm
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                  title: const Text(
                    'App Install Permission',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _hasInstallPerm
                        ? 'Allowed — updates can launch the installer directly'
                        : 'Tap to allow "Install unknown apps" for Nox Keyboard',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: _hasInstallPerm
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: Color(0xFF10B981),
                          size: 18,
                        )
                      : TextButton(
                          onPressed: () async {
                            await _bridge.openInstallPermissionSettings();
                          },
                          child: const Text('Allow'),
                        ),
                  onTap: _hasInstallPerm
                      ? null
                      : () async {
                          await _bridge.openInstallPermissionSettings();
                        },
                ),
                if (!_hasNotifPerm) ...[
                  Divider(
                    color: Colors.white.withValues(alpha: 0.07),
                    height: 1,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: const ModernIconBadge(
                      icon: CupertinoIcons.bell_slash_fill,
                      color: Color(0xFFF59E0B),
                    ),
                    title: const Text(
                      'Update Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Allow notifications to get alerted immediately when a new version is published',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        await _bridge.requestNotificationPermission();
                        await _refreshPermissionsAndVersion();
                      },
                      child: const Text('Allow'),
                    ),
                    onTap: () async {
                      await _bridge.requestNotificationPermission();
                      await _refreshPermissionsAndVersion();
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),
          GlassCard(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernIconBadge(
                  icon: CupertinoIcons.trash_fill,
                  color: Color(0xFFA78BFA),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Clean Storage Guarantee: Update APKs download into Nox Keyboard\'s private cache (never cluttering File Manager Downloads) and are automatically deleted right after installation completes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
