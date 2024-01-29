////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {

  Size screenSize = const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    bool enableDarkTheme = ref.read(settingProvider).enableDarkTheme;
    bool defaultShiftView = ref.read(settingProvider).defaultShiftView;

    return 
    Scaffold(
      body: SafeArea(
        child: SettingsList(
          lightTheme: const SettingsThemeData(
            settingsListBackground: Color(0xFFF2F2F7),
            settingsSectionBackground: Colors.white,
          ),
          sections: [
            SettingsSection(
              title: Text('基本設定', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.color_lens_rounded),
                  title: Text('カラーテーマ', style: Styles.defaultStyle13),
                  value: Text((enableDarkTheme) ? "ダークテーマ" : "ライトテーマ", style: Styles.defaultStyle13),
                  onPressed: (value){
                    setState(() {
                      // ref.read(settingProvider).enableDarkTheme = value;
                      // ref.read(settingProvider).storePreferences();
                    });
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text('デフォルトの画面', style: Styles.defaultStyle13),
                  value: Text((defaultShiftView) ? "管理中のシフト表" : "フォロー中のシフト表", style: Styles.defaultStyle13),
                  onPressed: (value) {
                    setState(() {
                      // ref.read(settingProvider).defaultShiftView = value;
                      // ref.read(settingProvider).storePreferences();
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text('アカウント', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.person_rounded),
                  title: Text('ユーザ情報', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.logout_rounded),
                  title: Text('ログアウト', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.delete_rounded),
                  title: Text('退会する', style: Styles.defaultStyle13),
                ),
              ],
            ),
            SettingsSection(
              title: Text('その他', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.help_rounded),
                  title: Text('ヘルプ', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.email_rounded),
                  title: Text('お問い合わせ', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.share_rounded),
                  title: Text('友達に教える', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.star_rounded),
                  title: Text('レビューを書く', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.document_scanner_rounded),
                  title: const Text('利用規約'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: const Text('プライバシーポリシー'),
                ),
                SettingsTile.navigation(
                  title: const Text('バージョン情報'),
                ),
              ],
            ),
          ],
        ),
      ),
      // SafeArea(
    //     child: SingleChildScrollView(
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text("カラーテーマの設定", style: Styles.defaultStyle15),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(vertical:  10),
    //               child: Row(
    //                 children: [
    //                   CupertinoSwitch(
    //                     thumbColor: Styles.primaryColor,
    //                     activeColor : Styles.primaryColor.withAlpha(100),
    //                     value: enableDarkTheme,
    //                     onChanged: (result){

    //                     },
    //                   ),
    //                   const SizedBox(width: 20),
    //                   
    //                 ],
    //               ),
    //             ),
    //             Text(, style: Styles.defaultStyleGrey13),
                
    //             SizedBox(height: screenSize.height * 0.05),
            
    //             Text("デフォルトで表示するシフト表", style: Styles.defaultStyle15),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(vertical:  10),
    //               child: Row(
    //                 children: [
    //                   CupertinoSwitch(
    //                     thumbColor: Styles.primaryColor,
    //                     activeColor : Styles.primaryColor.withAlpha(100),
    //                     value: defaultShiftView,
    //                     onChanged: (result){
    //                       setState(() {
    //                         ref.read(settingProvider).defaultShiftView = result;
    //                         ref.read(settingProvider).storePreferences();
    //                       });
    //                     },
    //                   ),
    //                   const SizedBox(width: 20),
    //                   Text((defaultShiftView) ? "管理中のシフト表" : "フォロー中のシフト表", style: Styles.defaultStyle13),
    //                 ],
    //               ),
    //             ),
    //             Text("「ホーム画面」で「管理中のシフト表」/「フォロー中のシフト表」どちらをデフォルト表示にするか設定します。", style: Styles.defaultStyleGrey13),
    //             Text("シフト表管理者は「管理中のシフト表」を設定することをお勧めします。", style: Styles.defaultStyleGrey13)
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    );
  }
}
