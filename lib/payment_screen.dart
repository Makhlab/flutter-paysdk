import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const String jsWidgetCdnUrl = "https://js.dev.treezpay.com/widget.js";
const String treezPayObjectName = "_treezpay";
const String flutterCallbackHandlerName = "flutterCallbackHandler";
const String widgetElementId = "paysdk-widget";

class PaymentScreen extends StatefulWidget {
  final String? amount;
  final String channel;

  const PaymentScreen({
    super.key,
    this.amount,
    this.channel = "virtual_terminal",
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final String _amount;
  final String _taxes = '100';
  final String _discount = '50';
  final String _rewards = '0.00';
  final String _customerFirstName = 'John';
  final String _customerLastName = 'Doe';
  final String _customerEmail = 'max@treez.io';
  final String _customerPhone = '2403249145';
  late final String _channel;

  InAppWebViewController? _webViewController;
  String? _paymentResult;

  bool _isWebViewReady = true;

  final List<String> _logMessages = [];
  bool _showLogs = false;

  bool _isBrowserOpen = false;

  final MyBrowser _browser = MyBrowser();

  Future<void> _openUrlInBrowser(String url) async {
    debugPrint("Opening URL in InAppBrowser: $url");

    try {
      _isBrowserOpen = true;

      _browser.onBrowserClosed = () {
        debugPrint("Browser closed callback triggered");
      };

      await _browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(url)),
        options: InAppBrowserClassOptions(
          crossPlatform: InAppBrowserOptions(
            hideUrlBar: true,
            toolbarTopBackgroundColor: const Color(0xFF8ccc52),
          ),
          android: AndroidInAppBrowserOptions(
            hideTitleBar: false,
            toolbarTopFixedTitle: "Checkout Reinvented with TreezPay",
            closeOnCannotGoBack: true,
          ),
          ios: IOSInAppBrowserOptions(
            presentationStyle: IOSUIModalPresentationStyle.FULL_SCREEN,
            transitionStyle: IOSUIModalTransitionStyle.COVER_VERTICAL,
            closeButtonCaption: "Done",
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error opening InAppBrowser: $e");
      _isBrowserOpen = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening payment page: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _amount = widget.amount ?? '100';
    _channel = widget.channel;
  }

  @override
  void dispose() {
    _closeBrowser();
    super.dispose();
  }

  void _closeBrowser() {
    if (_isBrowserOpen || _browser.isActuallyOpen()) {
      debugPrint("Closing InAppBrowser");
      try {
        _browser.close();
      } catch (e) {
        debugPrint("Error closing InAppBrowser: $e");
      } finally {
        _isBrowserOpen = false;
      }
    }
  }

  void _showPaymentSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Payment Successful!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(data['userMessage'] ?? 'Your payment was successful'),
                const SizedBox(height: 16),
                const Text('Payment Details:'),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _prettyJson(data),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentErrorDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Payment Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  data['userMessage'] ??
                      'There was an error processing your payment',
                ),
                const SizedBox(height: 16),
                const Text('Error Details:'),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _prettyJson(data),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _prettyJson(dynamic jsonInput) {
    var spaces = ' ' * 2;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(jsonInput);
  }

  String _createHtmlContent() {
    const String dispensaryShortName = "test-ach1";
    final String channel = _channel; // ecommerce, virtual_terminal, ffd
    const String authToken = "";
    const String entityId = "";

    final String baseHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta charset="UTF-8" />
    <base href="https://localhost/" />
          <title>TreezPay Host</title>
          <style>
            #paysdk-widget {
              background-color: #fff;
              min-height: 500px;
              padding: 10px;
              margin: 10px 0;
            }
            .tz-virtualTerminal-rootEmbed {
              width: 380px!important;
            }
            .tz-styles-button {
              background-color: #8ccc52!important;
              color: #fff!important;
            }
            .tz-QRCode-vtCanvas.tz-QRCode-canvas {
              background-color: #8ccc52!important;
            }
          </style>
      </head>
      <body>
          <div id="$widgetElementId"></div>

          <script>
              console.log("Page loaded, initializing payment widget");
              
              // Global state tracking
              window.treezPayState = {
                scriptLoaded: false,
                initialized: false,
                error: null
              };
              
              // Function to notify Flutter of state changes
              function updateFlutterState() {
                // window.flutter_inappwebview.callHandler('stateUpdateHandler', JSON.stringify({
                //   type: 'STATE_UPDATE',
                //   state: window.treezPayState
                // }));
              }
              
      setTimeout(() => {
        (function (w, d, s, o, f, js, fjs) {
          w[o] =
            w[o] ||
            function () {
              (w[o].q = w[o].q || []).push(arguments);
            };
          (js = d.createElement(s)), (fjs = d.getElementsByTagName(s)[0]);
          js.id = o;
          js.src = f;
          js.async = 1;
          fjs.parentNode.insertBefore(js, fjs);
        })(window, document, 'script', '_treezpay', '$jsWidgetCdnUrl');

                      window._treezpay('init', {
                        element: document.querySelector('#$widgetElementId'),
                        debug: true,
                        authTokenFactory: () => Promise.resolve('$authToken'),
                        getEntityId: () => Promise.resolve('$entityId'),
                        // theme: {
                        //     positionFixed: true,
                        // },
                        dispensaryShortName: '$dispensaryShortName',
                        channel: '$channel',
                        onReady: function() {
                          console.log("TreezPay widget is ready");
                          callFlutterCallback({ 'action': 'handlePayNow' });
                        }
                    });
                             
              }, 1000);
              // --- Bridge function for JS to call Flutter ---
              function callFlutterCallback(data) {
                try {
                  const message = typeof data === 'string' ? data : JSON.stringify(data);
                  console.log('Sending message to Flutter:', message);
                  window.flutter_inappwebview.callHandler('$flutterCallbackHandlerName', message);
                } catch (e) {
                  console.error('Error sending message to Flutter:', e);
                }
              }
          </script>
      </body>
      </html>
    ''';

    // Add console logging override
    final String modifiedHtml = '''
      $baseHtml
      <script>
        (function() {
          const originalLog = console.log;
          const originalError = console.error;
          const originalWarn = console.warn;
          
          console.log = function(...args) {
            originalLog.apply(console, args);
            // window.flutter_inappwebview.callHandler('consoleLogHandler', 'LOG: ' + args.map(arg => 
            //   typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' '));
          };
          
          console.error = function(...args) {
            originalError.apply(console, args);
            window.flutter_inappwebview.callHandler('consoleLogHandler', 'ERROR: ' + args.map(arg => 
              typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' '));
          };
          
          console.warn = function(...args) {
            originalWarn.apply(console, args);
            window.flutter_inappwebview.callHandler('consoleLogHandler', 'WARN: ' + args.map(arg => 
              typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' '));
          };
        })();
      </script>
    ''';

    return modifiedHtml;
  }

  void _handlePayNow() {
    final double? amountInDollars = double.tryParse(_amount);
    final int? originalAmount =
        amountInDollars != null ? (amountInDollars * 100).toInt() : null;
    final double? taxes = double.tryParse(_taxes);
    final double? discount = double.tryParse(_discount);
    final double? rewardDollars = double.tryParse(_rewards);

    final uuid = Uuid();
    final randomTicketId = uuid.v4();

    final paymentData = {
      'originalAmount': originalAmount,
      'taxes': taxes,
      'discount': discount,
      'rewardDollars': rewardDollars,
      'employeeReferenceId': '777',
      'customer': {
        'firstName': _customerFirstName,
        'lastName': _customerLastName,
        'phone': _customerPhone,
        'email': _customerEmail,
      },
      'ticketId': randomTicketId,
      'ticketAlphaNumId': "ZBC${DateTime.now().millisecondsSinceEpoch % 1000}",
      'entityName': 'entityName',
    };

    final String paymentDataJson = jsonEncode(paymentData);

    final jsCall = '''
      (function() {
        const paymentPayload = $paymentDataJson;
        console.log('TreezPay payload called with:', JSON.stringify(paymentPayload));

        paymentPayload.handlePaymentResponse = function(response) {
          console.log('TreezPay handlePaymentResponse called with:', JSON.stringify(response));
          callFlutterCallback(response);
        };
        window._treezpay('event', 'payment', paymentPayload);
      })();
    ''';

    if (_webViewController == null) {
      setState(() {
        _paymentResult = "Error: WebView controller not initialized";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Payment widget not ready")),
      );
      return;
    }

    _webViewController!
        .evaluateJavascript(source: jsCall)
        .then((result) {
          debugPrint("JS evaluation result: $result");
          if (result != null) {
            try {
              final Map<String, dynamic> resultMap = jsonDecode(result);
              debugPrint("Parsed result: $resultMap");

              // Update UI based on the result
              setState(() {
                _paymentResult =
                    "Payment process: ${resultMap['status']} - ${resultMap['message']}";
              });

              if (resultMap['status'] == 'error' ||
                  resultMap['status'] == 'exception') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resultMap['message'] ?? "Unknown error"),
                  ),
                );
              }
            } catch (e) {
              debugPrint("Error parsing JS result: $e");
            }
          }
        })
        .catchError((error) {
          debugPrint("Error executing JS via evaluateJavascript: $error");
          setState(() {
            _paymentResult = "Flutter Error: Could not execute JS ($error)";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error triggering payment widget: $error")),
          );
        });
  }

  void _handlePaymentCompletion(Map<String, dynamic> responseData) {
    debugPrint("Payment flow completed, closing browser if open");

    // force close browser when payment flow completes
    _closeBrowser();

    if (responseData['eventType'] == 'PAYMENT_APPROVED') {
      _showPaymentSuccessDialog(responseData);
    } else if (responseData['eventType'] == 'PAYMENT_ERROR') {
      _showPaymentErrorDialog(responseData);
    }
  }

  void _handlePaymentCallback(Map<String, dynamic> args) {
    debugPrint("Received message from JS: $args");

    _handlePaymentCompletion(args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8ccc52),
        foregroundColor: Colors.white,
        title: const Text('Checkout Reinvented with TreezPay'),
        actions: [
          IconButton(icon: const Icon(Icons.payment), onPressed: _handlePayNow),
          IconButton(
            icon: const Icon(Icons.developer_mode),
            onPressed: () {
              setState(() {
                _showLogs = !_showLogs;
              });
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            javaScriptEnabled: true,
            allowUniversalAccessFromFileURLs: true,
            supportZoom: false,
          ),
          android: AndroidInAppWebViewOptions(useHybridComposition: true),
          ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
        ),
        initialData: InAppWebViewInitialData(
          data: _createHtmlContent(),
          mimeType: 'text/html',
          encoding: 'utf-8',
          baseUrl: WebUri("https://test-ach1.treez.io"),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;

          // Set up JavaScript handlers
          controller.addJavaScriptHandler(
            handlerName: flutterCallbackHandlerName,
            callback: (args) {
              if (args.isNotEmpty) {
                debugPrint("Received message from JS: ${args[0]}");
                try {
                  // Parse the data from JS
                  final data = jsonDecode(args[0].toString());

                  // Check if this is a specific action request
                  if (data is Map && data['action'] == 'handlePayNow') {
                    _handlePayNow();
                    return;
                  }

                  // Update payment result in UI for regular callbacks
                  setState(() {
                    _paymentResult = "Callback Received:\n${_prettyJson(data)}";
                  });

                  // Handle payment response
                  _handlePaymentCompletion(data);

                  // Show confirmation or navigate
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Received payment response from widget."),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    _paymentResult = "Error processing callback: ${args[0]}";
                  });
                  debugPrint("Error decoding JS message: $e");
                }
              }
            },
          );

          // Set up console log handler
          controller.addJavaScriptHandler(
            handlerName: 'consoleLogHandler',
            callback: (args) {
              if (args.isNotEmpty) {
                setState(() {
                  _logMessages.add(args[0].toString());
                  // Optional: Limit log size
                  if (_logMessages.length > 20) {
                    _logMessages.removeAt(0);
                  }
                });
              }
            },
          );

          // Set up state update handler
          controller.addJavaScriptHandler(
            handlerName: 'stateUpdateHandler',
            callback: (args) {
              if (args.isNotEmpty) {
                debugPrint("Received state update: ${args[0]}");
              }
            },
          );
        },
        onLoadStart: (controller, url) {
          debugPrint('Page started loading: $url');
          setState(() {
            _isWebViewReady = false; // Reset ready state
          });
        },
        onLoadStop: (controller, url) {
          debugPrint('Page finished loading: $url');
          setState(() {
            _isWebViewReady = true; // WebView is ready for JS calls
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment Widget Ready."),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onLoadError: (controller, url, code, message) {
          debugPrint('Error loading page: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading payment widget: $message")),
          );
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final finalUri = navigationAction.request.url;
          debugPrint('Navigating to: $finalUri');

          // Check if this is a navigation we want to handle externally
          if (finalUri != null &&
              (finalUri.toString().startsWith('http://') ||
                  finalUri.toString().startsWith('https://'))) {
            try {
              await _openUrlInBrowser(finalUri.toString());

              return NavigationActionPolicy.CANCEL;
            } catch (e) {
              debugPrint('Error launching URL: $e');
              try {
                await launchUrl(finalUri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              } catch (e2) {
                debugPrint('Error launching fallback URL: $e2');
                return NavigationActionPolicy.CANCEL;
              }
            }
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}

class MyBrowser extends InAppBrowser {
  bool _isOpen = false;
  Function? onBrowserClosed;

  bool get isOpen => _isOpen;

  bool isActuallyOpen() {
    return _isOpen;
  }

  @override
  void onBrowserCreated() {
    debugPrint("InAppBrowser created");
    _isOpen = true;
  }

  @override
  void onExit() {
    debugPrint("InAppBrowser closed");
    _isOpen = false;
    if (onBrowserClosed != null) {
      onBrowserClosed!();
    }
  }

  @override
  void onLoadStart(url) {
    debugPrint("InAppBrowser load started: $url");
  }

  @override
  void onLoadStop(url) {
    debugPrint("InAppBrowser load stopped: $url");
  }

  @override
  void onLoadError(url, code, message) {
    debugPrint("InAppBrowser load error: $message (code: $code) for URL: $url");
  }
}
