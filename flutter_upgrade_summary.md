# Flutter 项目升级问题排查与解决总结

本文档总结了在 Flutter 项目升级过程中遇到的各种编译和运行时问题，并提供了详细的报错原因分析和解决方案。

## 1. 初始问题：Gradle 版本与 Java 版本不兼容

### 报错信息
```
[!] Your project's Gradle version is incompatible with the Java version that Flutter is using for Gradle.
...
BUG! exception in phase 'semantic analysis' in source unit '_BuildScript_' Unsupported class file major version 65
```

### 报错原因
Flutter 环境正在使用 Java 21 (major version 65)，而项目配置的 Gradle 版本（7.5）过旧，无法兼容 Java 21。

### 解决方案
将 `android/gradle/wrapper/gradle-wrapper.properties` 中的 `distributionUrl` 更新为兼容 Java 21 的 Gradle 版本。我们选择了 Gradle 8.8。

**修改文件：** `D:\flutter\flutter3_getx_shop\android\gradle\wrapper\gradle-wrapper.properties`
**修改内容：**
```properties
# Old: distributionUrl=https://mirrors.cloud.tencent.com/gradle/gradle-7.5-all.zip
distributionUrl=https://mirrors.cloud.tencent.com/gradle/gradle-8.8-all.zip
```

## 2. 问题：`TextTheme.button` 属性未定义

### 报错信息
```
Error: The getter 'button' isn't defined for the class 'TextTheme'.
...
/D:/flutterSdk/pub_dev/hosted/pub.dev/pin_code_fields-7.4.0/lib/src/pin_code_fields.dart:669:56: Error: The getter 'button' isn't defined for the class 'TextTheme'.
```

### 报错原因
Flutter SDK 升级后，`TextTheme` 类中的 `button` 属性已被移除。项目中的 `pin_code_fields` 依赖包版本过旧，使用了已废弃的属性。

### 解决方案
升级 `pin_code_fields` 及其相关依赖到最新兼容版本。

**修改文件：** `D:\flutter\flutter3_getx_shop\pubspec.yaml`
**修改内容：**
```yaml
# Old:
#   get: 4.6.6
#   dio: ^4.0.6 #网络请求
#   pin_code_fields: ^7.4.0 #验证码

# New:
  get: ^4.7.2
  dio: ^5.8.0+1 #网络请求
  pin_code_fields: ^8.0.1 #验证码
```
**执行命令：** `flutter pub get`

## 3. 问题：`dio` 超时设置类型不匹配

### 报错信息
```
Error: A value of type 'int' can't be assigned to a variable of type 'Duration?'.
...
lib/app/units/httpsClient.dart:8:34: Error: A value of type 'int' can't be assigned to a variable of type 'Duration?'.
```

### 报错原因
`dio` 包升级后，`connectTimeout` 和 `receiveTimeout` 属性不再接受整数作为毫秒值，而是要求 `Duration` 类型。

### 解决方案
将 `httpsClient.dart` 中 `dio` 的超时设置从整数改为 `Duration` 对象。

**修改文件：** `D:\flutter\flutter3_getx_shop\lib\app\units\httpsClient.dart`
**修改内容：**
```dart
// Old:
// dio.options.connectTimeout = 5000; //5s
// dio.options.receiveTimeout = 5000;

// New:
    dio.options.connectTimeout = const Duration(milliseconds: 5000); //5s
    dio.options.receiveTimeout = const Duration(milliseconds: 5000);
```

## 4. 问题：`tobias` 插件 Kotlin JVM 目标不兼容

### 报错信息
```
Execution failed for task ':tobias:compileDebugKotlin'.
> Unknown Kotlin JVM target: 21
```

### 报错原因
`tobias` 插件内部使用的 Kotlin 编译器版本过旧，无法识别 Java 21 作为编译目标。主应用模块的 Java 编译目标是 17，而 `tobias` 模块需要更低的 JVM 目标。

### 解决方案
**方案一 (尝试但失败)：** 尝试在 `android/build.gradle` 中为所有 Kotlin 编译任务强制设置 `jvmTarget = "1.8"`。此方案导致主应用与 `tobias` 模块的 JVM 目标冲突。

**方案二 (最终解决)：** 升级 `tobias` 插件到最新版本，该版本应已解决与新版 Gradle 和 Java 的兼容性问题。

**修改文件：** `D:\flutter\flutter3_getx_shop\pubspec.yaml`
**修改内容：**
```yaml
# Old:
#   tobias: ^2.4.1 #支付宝支付插件

# New:
  tobias: ^5.1.2 #支付宝支付插件
```
**执行命令：** `flutter pub get`

## 5. 问题：Android Gradle Plugin (AGP) 版本过低

### 报错信息
```
[!] Using compileSdk 35 requires Android Gradle Plugin (AGP) 8.1.0 or higher.
...
Warning: Flutter support for your project's Android Gradle Plugin version (Android Gradle Plugin version 7.3.0) will soon be dropped.
```

### 报错原因
项目尝试使用 `compileSdk 35` 进行编译，但当前 Android Gradle 插件版本（7.3.0）过旧，不兼容新 SDK。

### 解决方案
将 `android/settings.gradle` 中的 AGP 版本升级到 8.4.1。

**修改文件：** `D:\flutter\flutter3_getx_shop\android\settings.gradle`
**修改内容：**
```groovy
// Old: id "com.android.application" version "7.3.0" apply false
    id "com.android.application" version "8.4.1" apply false
```

## 6. 问题：Java 和 Kotlin JVM 目标再次不一致

### 报错信息
```
'compileDebugJavaWithJavac' task (current target is 17) and 'compileDebugKotlin' task (current target is 1.8) jvm target compatibility should be set to the same Java version.
```

### 报错原因
在升级 `tobias` 插件之前，我们曾尝试在 `android/build.gradle` 中为所有 Kotlin 编译任务设置 `jvmTarget = "1.8"`。这导致主应用的 Java 编译目标 (17) 与 Kotlin 编译目标 (1.8) 再次冲突。

### 解决方案
将 `android/build.gradle` 中为所有 Kotlin 编译任务设置的 `jvmTarget` 从 `1.8` 改回 `17`，使其与主应用的 Java 编译目标保持一致。

**修改文件：** `D:\flutter\flutter3_getx_shop\android\build.gradle`
**修改内容：**
```groovy
// Old:
//             jvmTarget = "1.8"

// New:
            jvmTarget = "17"
```

## 7. 问题：`tobias` 插件 `aliPay` 方法未找到

### 报错信息
```
Error: Method not found: 'aliPay'.
    var aliPayResult = await aliPay(response.data);
```

### 报错原因
`tobias` 插件升级到 `^5.1.2` 后，其 API 发生了变化。全局的 `aliPay` 方法已被移除，需要通过 `Tobias` 类的实例方法 `pay()` 来调用。

### 解决方案
修改 `lib/app/modules/buy/views/buy_view.dart` 文件，使用 `Tobias().pay()` 方法。

**修改文件：** `D:\flutter\flutter3_getx_shop\lib\app\modules\buy\views\buy_view.dart`
**修改内容：**
```dart
// Old:
// var aliPayResult = await aliPay(response.data);

// New:
    var aliPayResult = await Tobias().pay(response.data);
```
