import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(String location) async {
    // 1. Κωδικοποιούμε τη διεύθυνση (π.χ. το "Αθήνα, Ελλάδα" γίνεται "Αθήνα%2C%20Ελλάδα")
    final String encodedLocation = Uri.encodeComponent(location);

    // 2. Το ΕΠΙΣΗΜΟ URL format για αναζήτηση στο Google Maps
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedLocation");

    try {
      // Ελέγχουμε αν μπορεί να ανοίξει το URL
      // Στα νέα Android, το canLaunchUrl μπορεί να επιστρέψει false αν δεν έχει ρυθμιστεί το Manifest,
      // οπότε το τρέχουμε μέσα σε try-catch για σιγουριά.
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication, // Επιβάλλει το άνοιγμα της εφαρμογής Χάρτες
        );
      } else {
        // Εναλλακτική για Android (geo scheme) αν αποτύχει το https
        final Uri geoUrl = Uri.parse("geo:0,0?q=$encodedLocation");
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error launching maps: $e");
    }
  }
}