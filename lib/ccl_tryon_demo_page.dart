import 'package:designhubz/designhubz.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CCLTryOnDemoPage extends StatefulWidget {
  const CCLTryOnDemoPage({super.key});

  @override
  State<CCLTryOnDemoPage> createState() => _CCLTryOnDemoPageState();
}

class _CCLTryOnDemoPageState extends State<CCLTryOnDemoPage> {
  /// Once the [CCLTryOnWidget] is ready, it will provide the [CCLTryOnController]
  /// through its [onTryOnReady] callback, you can use this controller to set
  /// userId, load product, switch context, take snapshot and fetch recommendations
  late CCLTryOnController _tryOnController;

  /// In this example, [CCLTryOnWidget] will not be shown until camera
  /// permission is granted
  bool isCameraPermissionGranted = false;

  /// In this example, we are using a dummy user id and product id,
  /// make sure to use your own user id and product id
  String userId = "1234";
  String productId = "cost3mo-lay-lens-p02-golden-brown";
  String productId2 = "cost3mo-lay-2021-p02-skye-blue";

  final List<String> statusUpdates = [];

  bool isTryOnRecovering = false;

  /// [CCLTryOnWidget] have many callbacks for different statuses like [onUpdateTrackingStatus]
  ///  which we are showing above the [CCLTryOnWidget] in this example
  void addStatusUpdate(String status) {
    setState(() {
      statusUpdates.insert(0, status);
    });
  }

  @override
  void initState() {
    _checkForCameraPermission();
    super.initState();
  }

  void initARExperience() async {
    await _tryOnController.setUserId(userId);
    await _tryOnController.loadProduct(productId, progressHandler: (progress) {
      addStatusUpdate("Product Loading Progress: $progress");
    });
  }

  /// before starting the [CCLTryOnWidget] try-on mode, make sure to check for camera permission
  /// and request for permission if not granted using [permission_handler](https://pub.dev/packages/permission_handler)
  /// or any other such package package
  _checkForCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        isCameraPermissionGranted = true;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        isCameraPermissionGranted = result.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CCL Try-On Example'),
      ),
      body: Stack(
        children: [
          Builder(builder: (context) {
            if (!isCameraPermissionGranted) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Camera Permission is required to use Try-On',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              );
            }
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Opacity(
                  opacity: isTryOnRecovering ? 0.1 : 1,
                  child: CCLTryOnWidget(
                    /// make sure to provided your own organization id
                    organizationId: "23049412",

                    onTryOnRecovering: (isRecovering) {
                      setState(() {
                        isTryOnRecovering = isRecovering;
                      });
                    },

                    /// all these callbacks provide different statuses updates
                    /// In this example, we are showing it in UI through [buildStatusUpdatesWidget()]

                    onUpdateTryOnStatus: (tryOnStatus) {
                      addStatusUpdate("TryOn Status: $tryOnStatus");
                    },

                    onError: (error) {
                      addStatusUpdate("Error: $error");
                    },

                    /// [onTryOnReady] will be called once the [CCLTryOnWidget] is ready
                    onTryOnReady: (controller) {
                      /// save the controller for later use, see buttons in bottom of
                      /// the page for its usage
                      _tryOnController = controller;
                      initARExperience();
                    },
                  ),
                ),
              ),
            );
          }),
          if (isTryOnRecovering)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Try-On is recovering, please wait',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),

          /// show the status updates in bottom of the page
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: buildStatusUpdatesWidget(),
            ),
          ),
          // uncomment to show memory overlay
          // buildMemoryOverlay(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,

            /// buttons to call different methods of [CCLTryOnController]
            children: [
              buildSetUserIdWidgetButton(),
              buildLoadProductButton(productId, "Prod 1"),
              buildLoadProductButton(productId2, "Prod 2"),
              buildTakeSnapshotButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Sets the identifier that can pair with your user stats.
  /// show a [SnackBar] to indicate success or failure
  Widget buildSetUserIdWidgetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: userId,
                      onChanged: (value) async {
                        userId = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            await _tryOnController.setUserId(userId);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("User ID Set Successfully"),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error:$e")));
                          }
                        },
                        child: const Text('Set User Id')),
                  ],
                ));
              });
        },
        child: const Text('Set User Id'),
      ),
    );
  }

  /// load the product defined by [productToLoadId]
  /// show a [SnackBar] to indicate loaded product detail or failure
  Widget buildLoadProductButton(String productToLoadId, String buttonTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          try {
            final loadedProduct =
                await _tryOnController.loadProduct(productToLoadId,
                    // optional callback to get progress updates
                    // related to loading product
                    progressHandler: (progress) {
              // show loading progress in UI overlay for this example
              addStatusUpdate("Product Loading Progress: $progress");
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Product Loaded Successfully $loadedProduct")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Error:$e")));
          }
        },
        child: Text(buttonTitle),
      ),
    );
  }

  /// Take a snapshot of what is currently displayed in [CCLTryOnWidget]
  /// show a [Dialog] to show the captured image
  Widget buildTakeSnapshotButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: FutureBuilder(
                    future: _tryOnController.takeSnapshot(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.hasError) {
                          return Text("Error:${snapshot.error}");
                        }
                        final image = snapshot.data;
                        if (image == null) {
                          return const Text("No image captured");
                        }

                        /// after getting the snapshot, you can show it in the UI
                        /// through [Image.memory] like here, or upload it somewhere
                        return Image.memory(image);
                      } else {
                        return const Text(
                          "Loading...",
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                );
              });
        },
        child: const Text('Take Snapshot'),
      ),
    );
  }

  /// show status updates in a [ListView] from [CCLTryOnWidget] callbacks
  Widget buildStatusUpdatesWidget() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: ListView(
        children: statusUpdates
            .map(
              (e) => Text(
                e,
                style: const TextStyle(color: Colors.white),
              ),
            )
            .toList(),
      ),
    );
  }

  /// (Android only) show available memory and if device is low on
  /// memory. Useful to evaluate TryOn on low-end devices
  /// **not** a requirement to use [CCLTryOnWidget]
  Widget buildMemoryOverlay() {
    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          return FutureBuilder(
            future: TryonHelpers.getAndroidMemoryInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final memInfo = snapshot.data;
                if (memInfo == null) return Container();
                return Container(
                  color: Colors.white.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Available Memory: ${memInfo.availableMemoryInMB} MB\nIs Low On Memory: ${memInfo.isLowOnMemory}",
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
