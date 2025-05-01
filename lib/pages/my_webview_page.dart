import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyWebViewPage extends StatefulWidget {
  const MyWebViewPage({super.key});

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    // สร้าง parameter ที่รองรับได้ทั้ง iOS และ Android
    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      // ถ้าเป็น iOS
      params = WebKitWebViewControllerCreationParams
          .fromPlatformWebViewControllerCreationParams(params);
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      // ถ้าเป็น Android
      params = AndroidWebViewControllerCreationParams
          .fromPlatformWebViewControllerCreationParams(params);
    }

    // สร้าง WebViewController
    webViewController = WebViewController.fromPlatformCreationParams(params);

    // สั่งให้โหลดเว็บไซต์
    webViewController.loadRequest(Uri.parse('https://www.rmutl.ac.th/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('หน้าเว็บไซต์')),
      body: WebViewWidget(controller: webViewController),
    );
  }
}
