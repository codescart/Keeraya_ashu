import 'dart:developer';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './helpers/api_helper.dart';
import './helpers/app_config.dart';
import './helpers/current_user.dart';
import './providers/categories.dart';
import './providers/languages.dart';
import './providers/location_provider.dart';
import './providers/products.dart';
import './screens/all_categories_screen.dart';
import './screens/auth_screen.dart';
import './screens/chat_screen.dart';
import './screens/custom_fields_screen.dart';
import './screens/edit_ad_screen.dart';
import './screens/expire_ads_screen.dart';
import './screens/filter_screen.dart';
import './screens/invoices_and_billings_screen.dart';
import './screens/invoices_screen.dart';
import './screens/location_search_screen.dart';
import './screens/membership_plan_screen.dart';
import './screens/new_ad_screen.dart';
import './screens/notifications_screen.dart';
import './screens/payment_methods_screen.dart';
import './screens/privacy_screen.dart';
import './screens/product_details_screen.dart';
import './screens/products_by_category_screen.dart';
import './screens/search_ad_screen.dart';
import './screens/select_language_screen.dart';
import './screens/seller_details_screen.dart';
import './screens/settings_screen.dart';
import './screens/start_screen.dart';
import './screens/sub_categories_screen.dart';
import './screens/tabs_screen.dart';
import './screens/transactions_screen.dart';
import '../screens/color_helper.dart';
import '../screens/location_search_screen_first.dart';
import 'firebase_options.dart';
//import 'package:advertising_id/advertising_id.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

//* configure revenueCat API key for apple project
final _configuration = PurchasesConfiguration(
  AppConfig.revenueCatApiKey,
);

void main() async {
  // Import package

// Show tracking authorization dialog and ask for permission

// Now you can safely initialize admob and start to show ads. Admob should use
// advertising identifier automatically.
// FirebaseAdMob.instance.initialize(...)
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: HexColor()));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppTrackingTransparency.requestTrackingAuthorization();
  // If the system can show an authorization request dialog

  await Purchases.configure(_configuration);
  // await AppConfig.initialize();
  await CurrentUser.initialize();
  //! # native_admob_flutter: ^1.5.0+1 deprecated
  // await MobileAds.initialize();
  // MobileAds.setTestDeviceIds([
  //   '9345804C1E5B8F0871DFE29CA0758842',
  //   '1036b8ee-39e2-40a7-bd12-537efb0e26ae',
  //   'A50CFC9A556A27BFDA4005E3B90F7019',
  //   '745FD4A0981807548C46C1EDCBF8696B'
  // ]);

  //1036b8ee-39e2-40a7-bd12-537efb0e26ae

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }
  var sharePref = await SharedPreferences.getInstance();
  var isFreshInstalled = sharePref.getBool("is_fresh_install") ?? true;

  //isFreshInstalled = true;

  var spTokenID = sharePref.getString("token_id");
  if (spTokenID == null) {
    AppConfig.FCM_ID = await FirebaseMessaging.instance.getToken();
    sharePref.setString("token_id", AppConfig.FCM_ID);
  } else {
    AppConfig.FCM_ID = spTokenID;
  }

  log("userId:::: ${AppConfig.FCM_ID}");

  return runApp(
    Phoenix(
      child: new MyApp(
        isFreshInstalled: isFreshInstalled,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final isFreshInstalled;

  const MyApp({Key key, @required this.isFreshInstalled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FacebookAudienceNetwork.init(
      testingId: "745FD4A0981807548C46C1EDCBF8696B", //optional
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Categories(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => APIHelper(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrentUser(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Languages(),
        ),
      ],
      child: Directionality(
        textDirection: CurrentUser.textDirection,
        child: new MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Keeraya',
          theme: new ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light, // 2
            ),
            scaffoldBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(
                color: Colors.grey,
              ),
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: HexColor()
                    //Colors.grey[800],
                    ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: HexColor()
                    //Colors.grey[800],
                    ),
              ),
            ),
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
            // counter didn't reset back to zero; the application is not restarted.
            primarySwatch: Colors.red,
            primaryColor: HexColor(),
          ),
          // home: TabsScreen(
          //   title: 'Classified',
          // ),
          home: isFreshInstalled
              ? LocationSearchScreenFirst()
              : TabsScreen(
                  title: 'Keeraya',
                ),
          routes: {
            ChatScreen.routeName: (ctx) => ChatScreen(),
            InvoicesAndBillingScreen.routeName: (ctx) =>
                InvoicesAndBillingScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            // MyOrdersScreen.routeName: (ctx) => MyOrdersScreen(),
            InvoicesScreen.routeName: (ctx) => InvoicesScreen(),
            PrivacyScreen.routeName: (ctx) => PrivacyScreen(),
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            AllCategoriesScreen.routeName: (ctx) => AllCategoriesScreen(),
            SubCategoriesScreen.routeName: (ctx) => SubCategoriesScreen(),
            StartScreen.routeName: (ctx) => StartScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            TabsScreen.routeName: (ctx) => TabsScreen(),
            NewAdScreen.routeName: (ctx) => NewAdScreen(),
            MembershipPlanScreen.routeName: (ctx) => MembershipPlanScreen(),
            SearchAdScreen.routeName: (ctx) => SearchAdScreen(),
            SelectLanguageScreen.routeName: (ctx) => SelectLanguageScreen(),
            ProductsByCategoryScreen.routeName: (ctx) =>
                ProductsByCategoryScreen(),
            PaymentMethodsScreen.routeName: (ctx) => PaymentMethodsScreen(),
            NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
            SellerDetailsScreen.routeName: (ctx) => SellerDetailsScreen(),
            TransactionsScreen.routeName: (ctx) => TransactionsScreen(),
            ExpireAdsScreen.routeName: (ctx) => ExpireAdsScreen(),
            EditAdScreen.routeName: (ctx) => EditAdScreen(),
            FilterScreen.routeName: (ctx) => FilterScreen(),
            LocationSearchScreen.routeName: (ctx) => LocationSearchScreen(),
            CustomFieldsScreen.routeName: (ctx) => CustomFieldsScreen(),
          },
        ),
      ),
    );
  }
}
