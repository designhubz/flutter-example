At **Designhubz** we empower brands around the world to connect with shoppers in a complete immersive way.

We’re transforming the online shopping experience with next generation eCommerce interfaces using our leading AR technology that’s being adopted by some of the largest brands and retailers globally.

---

# Designhubz | Eyewear VTO Flutter plugin

This project highlights the integration of [DesignHubz Try-On AR](https://designhubz.com/try-on-eyewear-ar) into your Flutter app.

|             | Android | iOS     |
| ----------- | ------- | ------- |
| **Support** | SDK 21+ | iOS 10+ |

## Usage

### Depend on it
Run this command:

With Flutter:

```groovy
$ flutter pub add designhubz
```
This will add a line like this to your package's pubspec.yaml (and run an implicit `flutter pub get`):
```groovy
dependencies:
designhubz: ^0.0.5
```
Alternatively, your editor might support `flutter pub get`. Check the docs for your editor to learn more.

### Import it
Now in your Dart code, you can use:
```groovy
import 'package:designhubz/designhubz.dart';
```
## Getting Started

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### Flutter

Grant the camera permission on both Android and iOS using any package of your choice. For example, [permission_handler](https://pub.dev/packages/permission_handler) before starting `TryOnWidget`.

Add `TryOnWidget` to your widget tree.

The widget can be controlled with the `TryOnController` that is passed to the `TryOnWidget`'s `onTryOnReady` callback.

See the [example](./example) directory for a complete example app, and some highlights below.

### Snippets

1. Add `TryOnWidget`

```dart
import 'package:designhubz/designhubz.dart';
import 'package:flutter/material.dart';

class DesignHubzDemo extends StatefulWidget {
  const DesignHubzDemo({super.key});

  @override
  State<DesignHubzDemo> createState() => _DesignHubzDemoState();
}

class _DesignHubzDemoState extends State<DesignHubzDemo> {
  late TryOnController _tryOnController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TryOnWidget(
        organizationId: "your_organization_id",
        onTryOnReady: (controller) {
          _tryOnController = controller;
        },
      ),
    );
  }
}

```

2. Once the `TryOnController` is received from `onTryOnReady` callback, you can call various methods on it.

# TryOnController Methods

## `setUserId()`

You will need to call setUserId function before loading any product.

### Request

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `userId`  | `string` | **Required**. Your User Id |

### example

```dart
_tryOnController.setUserId('user_id');
```

### Response

This function does not have any return value.

## `loadProduct()`

It will load the provided `productId` associated product.

### Request

| Parameter   | Type     | Description                  |
| :---------- | :------- | :--------------------------- |
| `productId` | `string` | **Required**. The Product ID |

### Response

It returns `EyewearProduct` if succeeds.

```dart
EyewearProduct {
  String productKey;
  List<String> variations;
}
```

## `switchMode()`

It will switch the mode between `3d` and `tryon`

### Request

This function does not have any required parameters.

### Response

This function does not have any return value.

## `takeSnapshot()`

It will take a snapshot image

### Request

This function does not have any required parameters.

### Response

It and return as the image data as a `Uint8List` that can be used in a `Image` Widget to display it.

```dart
FutureBuilder(
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
      return Image.memory(image);
    } else {
      return const Text(
        "Loading...",
        textAlign: TextAlign.center,
      );
    }
  },
);
```

## `fetchRecommendations()`

It will fetch certain number of recommendations.

### Request

| Parameter | Type     | Description                             |
| :-------- | :------- | :-------------------------------------- |
| `count`   | `number` | **Required**. Number of recommendations |

### Response

It returns List of `ScoredRecommendation` which has product data including variations if succeeds.

```dart
class ScoredRecommendation {
  final String productKey;
  final num score;
}
```

Example response:

```dart
[
  ScoredRecommendation(
    productKey: "000209-0107",
    score: 10,
  ),
  ScoredRecommendation(
    productKey: "000838-0118",
    score: 10,
  ),
  ScoredRecommendation(
    productKey: "000241-2906",
    score: 10,
  ),
];
```

# Event Handlers

`TryOnWidget` provide the following event handlers callbacks:

## `onUpdateTryonStatus`

It will be called when the status of widget is changed.

### Params

| Parameter | Type          | Description                                      |
| :-------- | :------------ | :----------------------------------------------- |
| `status`  | `TryOnStatus` | Status of the widget (`idle`, `loading`, `read`) |

## `onUpdateUserInfo`

It will be called when the user info is updated.

### Params

| Parameter  | Type            | Description        |
| :--------- | :-------------- | :----------------- |
| `userInfo` | `TryOnUserInfo` | Detailed user info |

The `TryOnUserInfo` type will look like this:

```dart
class TryOnUserInfo {
  /// can be one of the following: "Small", "Medium", "Large"
  String size;

  /// Distance from the midpoint between the eyes
  num eyeSize;

  /// Inter-Pupillary Distance
  num ipd;
}
```

## `onUpdateTrackingStatus`

It will be called when the **face** tracking status is changed.

### Params

| Parameter        | Type                  | Description            |
| :--------------- | :-------------------- | :--------------------- |
| `trackingStatus` | `TryOnTrackingStatus` | Status of the tracking |

The `trackingStatus` will be one of these values

- `idle`
- `cameraNotFound`
- `faceNotFound`
- `analyzing`
- `tracking`

## `onError`

It will be called when any error is happened.

### Params

| Parameter | Type     | Description             |
| :-------- | :------- | :---------------------- |
| `error`   | `string` | Error while interacting |

Copyright 2023 Designhubz. All rights reserved.
