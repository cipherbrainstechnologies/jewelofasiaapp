// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/place_order_body.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/cancel_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final String? url;
  final int? orderId;
  const PaymentScreen({Key? key, this.orderId, this.url}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.url ?? '';
    _initData();
  }

  void _initData() async {
    browser = MyInAppBrowser(context, orderId: widget.orderId);
    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      bool swAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController = AndroidServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            return null;
          },
        ));
      }
    }

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          browser.webViewController!.reload();
        } else if (Platform.isIOS) {
          browser.webViewController!.loadUrl(urlRequest: URLRequest(url: await browser.webViewController!.getUrl()));
        }
      },
    );

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      options: InAppBrowserClassOptions(
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() => _exitApp(context).then((value) => value!)),
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              _isLoading ? Center(
                child: CustomLoader(color: Theme.of(context).primaryColor),
              ) : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp(BuildContext context) async {
    return showDialog(context: context,
        builder: (context) => CancelDialog(orderID: widget.orderId));
  }
}


class MyInAppBrowser extends InAppBrowser {
  final int? orderId;
  final bool? fromCheckout;
  final BuildContext context;
  MyInAppBrowser(this.context, {
    required this.orderId,
    int? windowId,
    UnmodifiableListView<UserScript>? initialUserScripts,
    this.fromCheckout
  })
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url, ) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _pageRedirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _pageRedirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if(_canRedirect) {
      Navigator.pushReplacementNamed(context, '${RouteHelper.orderSuccessful}/$orderId/payment-fail');
    }

    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    // print("Started at: " + response.startTime.toString() + "ms ---> duration: " + response.duration.toString() + "ms " + (response.url ?? '').toString());
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _pageRedirect(String url) {
    if(_canRedirect) {
      bool checkedUrl = (url.contains('${AppConstants.baseUrl}${RouteHelper.orderSuccessful}') || url.contains('${AppConstants.baseUrl}${RouteHelper.wallet}'));
      bool isSuccess = url.contains('success') && checkedUrl;
      bool isFailed = url.contains('fail') && checkedUrl;
      bool isCancel = url.contains('cancel') && checkedUrl;

      bool isWallet = url.contains('${AppConstants.baseUrl}${RouteHelper.wallet}');

      if (kDebugMode) {
        print('----------------payment status -----$isCancel -- $isSuccess -- $isFailed');
        print('------------------url --- $url');
      }

      if(isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }
      if(isSuccess){
        String token = url.replaceRange(0, url.indexOf('token='), '').replaceAll('token=', '');
        if(isWallet){
          Navigator.pushReplacementNamed(context, RouteHelper.getWalletRoute(token: token, status: 'success'));
        }else{
          if(token.isNotEmpty) {
            final orderProvider =  Provider.of<OrderProvider>(context, listen: false);
            String placeOrderString =  utf8.decode(base64Url.decode(orderProvider.getPlaceOrder()!.replaceAll(' ', '+')));

            String decodeValue = utf8.decode(base64Url.decode(token.replaceAll(' ', '+')));
            String paymentMethod = decodeValue.substring(0, decodeValue.indexOf('&&'));
            String transactionReference = decodeValue.substring(decodeValue.indexOf('&&') + '&&'.length, decodeValue.length);



            PlaceOrderBody? placeOrderBody =  PlaceOrderBody.fromJson(jsonDecode(placeOrderString)).copyWith(
              paymentMethod: paymentMethod.replaceAll('payment_method=', ''),
              transactionReference:  transactionReference.replaceRange(0, transactionReference.indexOf('transaction_reference='), '').replaceAll('transaction_reference=', ''),
            );

            Provider.of<OrderProvider>(context, listen: false).placeOrder(placeOrderBody, _callback);

          }else{
            Navigator.pushReplacementNamed(context, '${RouteHelper.orderSuccessful}/$orderId/payment-fail');
          }
        }

      }else if(isWallet){
        Navigator.pushReplacementNamed(context, RouteHelper.getWalletRoute(token: 'failed',status: 'failed'));

      }else if(isFailed) {
        Navigator.pushReplacementNamed(context, '${RouteHelper.orderSuccessful}/${'No'}/payment-fail');
      }else if(isCancel) {
        Navigator.pushReplacementNamed(context, '${RouteHelper.orderSuccessful}/${'No'}/payment-cancel');
      }
    }

  }

  void _callback(bool isSuccess, String message, String orderID) async {
    Provider.of<CartProvider>(context, listen: false).clearCartList();
    Provider.of<OrderProvider>(context, listen: false).stopLoader();
    if(isSuccess) {
      Navigator.pushReplacementNamed(context, '${RouteHelper.orderSuccessful}/$orderID/success');
    }else {
      showCustomSnackBar(message);
    }
  }

}
