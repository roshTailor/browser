import 'dart:io';

import 'package:browser/utils/Variable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Variable.pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          await Variable.inAppWebViewController.reload();
        } else if (Platform.isIOS) {
          Uri? url = await Variable.inAppWebViewController.getUrl();
          Variable.inAppWebViewController.loadUrl(
            urlRequest: URLRequest(url: url),
          );
        }
      },
      options: PullToRefreshOptions(color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50,
              width: width,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: CupertinoSearchTextField(
                controller: Variable.textEditingController,
                onSuffixTap: () {
                  setState(() {
                    Variable.search = "";
                    Variable.textEditingController.clear();
                  });
                },
                onSubmitted: (val) async {
                  Variable.search = val;
                  Variable.textEditingController.text = Variable.search;
                  Variable.inAppWebViewController.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse(
                          'https://www.google.com/search?q=${Variable.search}'),
                    ),
                  );
                  Variable.history
                      .add('https://www.google.com/search?q=${Variable.search}');
                },
              ),
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'https://www.google.com/search?q=${Variable.search}'),
                ),
                onWebViewCreated: (val) {
                  setState(() {
                    Variable.inAppWebViewController = val;
                  });
                },
                pullToRefreshController: Variable.pullToRefreshController,
                onLoadStop: (context, uri) {
                  Variable.pullToRefreshController.endRefreshing();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: (Variable.search != '')
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                elevation: 0,
                onPressed: () {
                  setState(() {
                    Variable.bookmark.add(
                        'https://www.google.com/search?q=$Variable.search');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("BookMark Added Successfully"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                },
                child: const Icon(CupertinoIcons.bookmark_fill),
              ),
            )
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: Variable.index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        onTap: (val) async {
          setState(() {
            Variable.index = val;
          });
          if (Variable.index == 0) {
            if (await Variable.inAppWebViewController.canGoBack()) {
              await Variable.inAppWebViewController.goBack();
              Uri? uri = await Variable.inAppWebViewController.getUrl();
              Variable.textEditingController.text = uri.toString();
            }
          } else if (Variable.index == 1) {
            if (await Variable.inAppWebViewController.canGoForward()) {
              await Variable.inAppWebViewController.goForward();
              Uri? uri = await Variable.inAppWebViewController.getUrl();
              Variable.textEditingController.text = uri.toString();
            }
          } else if (Variable.index == 2) {
            Variable.search = "";
            Variable.textEditingController.clear();
          } else if (Variable.index == 3) {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(50))),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  expand: false,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child:
                              Text("History", style: TextStyle(fontSize: 22)),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: Variable.history.map((e) {
                                return TextButton(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Variable.search = e;
                                      Navigator.pop(context);
                                      Variable.inAppWebViewController.loadUrl(
                                        urlRequest: URLRequest(
                                          url: Uri.parse(e),
                                        ),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(50))),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  expand: false,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child:
                              Text("BookMark", style: TextStyle(fontSize: 22)),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: Variable.bookmark.map((e) {
                                return TextButton(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Variable.search = e;
                                      Navigator.pop(context);
                                      Variable.inAppWebViewController.loadUrl(
                                        urlRequest: URLRequest(
                                          url: Uri.parse(e),
                                        ),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.back),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.forward),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off),
            activeIcon: Icon(Icons.history),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark),
            activeIcon: Icon(CupertinoIcons.bookmark_fill),
            label: '',
          ),
        ],
      ),
    );
  }
}
