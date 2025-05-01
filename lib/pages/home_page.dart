import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rmutlproj/auth.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:rmutlproj/pages/qr_scanner_page.dart';
import 'package:rmutlproj/pages/profile_page.dart';

import 'package:rmutlproj/firebase_seed.dart';
import 'package:rmutlproj/pages/attendeance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  late final WebViewController webViewController;
  int _selectedIndex = 0;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  void initState() {
    super.initState();

    // สร้าง WebViewController สำหรับแสดงเว็บไซต์
    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params =
          WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
          );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params =
          AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
          );
    }

    webViewController = WebViewController.fromPlatformCreationParams(params);
    webViewController.loadRequest(Uri.parse('https://www.rmutl.ac.th/'));
  }

  // ส่วนหัว: แสดงชื่อและปุ่มออกจากระบบ
  Widget _userInfoBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(user?.email ?? 'User Email'),
        ElevatedButton(onPressed: signOut, child: Text('Sign Out')),
      ],
    );
  }

  // สลับเนื้อหาแต่ละ tab (ตอนนี้แสดง WebView ทุก tab)
  Widget _getBody() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: _userInfoBar()),
        Expanded(child: WebViewWidget(controller: webViewController)),
      ],
    );
  }

  Widget _drawermenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'เมนู',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.check_box),
            title: const Text('ระบบเช็คชื่อ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendancePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('ดูข้อมูลนักเรียน'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.pushNamed(context, '/profile'); // ไปยังหน้าโปรไฟล์
            },
          ),
          ListTile(
            leading: const Icon(Icons.car_crash),
            title: const Text('ติดตามสถานะรถโรงเรียน'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.pushNamed(context, '/profile'); // ไปยังหน้าโปรไฟล์
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_rounded),
            title: const Text('ระบบส่งการบ้านและสั่งงานนักเรียน'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.pushNamed(context, '/profile'); // ไปยังหน้าโปรไฟล์
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('ตั้งค่า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ออกจากระบบ'),
            onTap: () async {
              await Auth().signOut(); // logout
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RMUTL WebView'),
        leading: Builder(
          builder:
              (context) => // ปุ่ม 3 ขีด
                  IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // เปิด Drawer
                },
              ),
        ),
      ),
      drawer: _drawermenu(),
      body: _getBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            // สมมติ Scan เป็นปุ่มที่ 3
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerPage()),
            );
          }
          if (index == 4) {
            // สมมติ Scan เป็นปุ่มที่ 3
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        indicatorColor: Colors.amber,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.messenger_sharp)),
            label: 'Messages',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await seedSampleData();
        },
        child: FaIcon(FontAwesomeIcons.database),
      ),
    );
  }
}
