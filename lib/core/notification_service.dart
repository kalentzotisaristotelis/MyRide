import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Ειδοποίηση στο Background/Κλειστό App: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      // 1. Ζητάμε άδεια (αυτό περνάει κανονικά όπως είδαμε)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Ο χρήστης έδωσε άδεια για ειδοποιήσεις!');

        // 2. Ενεργοποιούμε τους Listeners
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("Ήρθε ειδοποίηση (Foreground): ${message.notification?.title}");
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("Ο χρήστης πάτησε την ειδοποίηση!");
        });

        // 3. ΑΝΤΙ ΓΙΑ TOKEN: Κάνουμε εγγραφή στο κανάλι "all_riders"
        _subscribeToTopicSilently();

      } else {
        print('Ο χρήστης ΑΡΝΗΘΗΚΕ τις ειδοποιήσεις.');
      }
    } catch (e) {
      print('Γενικό σφάλμα αρχικοποίησης ειδοποιήσεων: $e');
    }
  }

  // Αυτή η συνάρτηση τρέχει αθόρυβα στο παρασκήνιο
  Future<void> _subscribeToTopicSilently() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // Το "μαγικό" κλειδί: Εγγραφή σε Topic
      await _fcm.subscribeToTopic('all_riders');
      print("======== ΕΠΙΤΥΧΙΑ! ========");
      print("Το κινητό γράφτηκε στο κανάλι 'all_riders'!");
      print("Μπορείς να στείλεις ειδοποίηση από το Firebase σε αυτό το Topic.");
      print("===========================");
    } catch (e) {
      print("Η εγγραφή στο κανάλι απέτυχε. Λόγος: $e");
    }
  }
}