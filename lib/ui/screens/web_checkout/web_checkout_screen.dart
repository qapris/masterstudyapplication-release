import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/ui/screens/orders/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebCheckoutScreenArgs {
  final String? url;

  WebCheckoutScreenArgs(this.url);
}

class WebCheckoutScreen extends StatelessWidget {
  static const routeName = "webCheckoutScreen";

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizations!.getLocalization("checkout_title"),
          textScaleFactor: 1.0,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: WebCheckoutWidget(url: args.url),
    );
  }
}

class WebCheckoutWidget extends StatefulWidget {
  final dynamic url;

  const WebCheckoutWidget({Key? key, this.url});

  @override
  State<StatefulWidget> createState() => WebCheckoutWidgetState();
}

class WebCheckoutWidgetState extends State<WebCheckoutWidget> {
  late WebViewController _webViewController;
  bool showLoading = true;

  @override
  Widget build(BuildContext context) => _buildWebView();

  _buildWebView() {
    return Stack(
      children: <Widget>[
        WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.url + "&app=123",
            onPageFinished: (some) async {
              print("page finished");
              setState(() {
                showLoading = false;
              });
            },
            onPageStarted: (some) {
              print("page started");
              setState(() {
                showLoading = true;
              });
            },
            onWebViewCreated: (controller) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? header = prefs.getString("apiToken");
              this._webViewController = controller;
              controller.clearCache();
              _webViewController.loadUrl(widget.url + "&app=123", headers: {"token": header!});
              print("MYHEADER: $header");
            },
            javascriptChannels: Set.from([
              JavascriptChannel(
                  name: "lmsEvent",
                  onMessageReceived: (JavascriptMessage result) {
                    print(result.message);

                    if (jsonDecode(result.message)["event_type"] == "order_created") {
                      if (jsonDecode(result.message)["payment_code"] == "paypal") {
                        openPaypalPayment(jsonDecode(result.message)["url"]);
                      } else {
                        _openOrders();
                      }
                    }
                    if (jsonDecode(result.message)["event_type"] == "plan_order_created") {
                      _closeScreen();
                    }
                  }),
            ])),
        Visibility(
          visible: showLoading,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  _closeScreen() {
    Navigator.of(context).pop();
  }

  _openOrders() {
    var future = Navigator.pushNamed(context, OrdersScreen.routeName);
    future.then((value) {
      Navigator.pop(context);
    });
  }

  void openPaypalPayment(url) {
    var future = Navigator.pushNamed(
      context,
      WebCheckoutScreen.routeName,
      arguments: WebCheckoutScreenArgs(url),
    );
    future.then((value) {
      Navigator.pop(context);
    });
  }
}
