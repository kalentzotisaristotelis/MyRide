import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/garage_controller.dart';
import 'add_bike_screen.dart';
import 'edit_bike_screen.dart';

// ΑΛΛΑΓΗ: Έγινε ConsumerWidget
class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Παρακολουθούμε τον provider που φτιάξαμε
    final bikesAsyncValue = ref.watch(userBikesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      // 2. Το body αλλάζει ανάλογα με την κατάσταση (Loading, Error, Data)
      body: bikesAsyncValue.when(
        // Α. Αν φορτώνει ακόμα -> Κυκλάκι
        loading: () => const Center(child: CircularProgressIndicator()),

        // Β. Αν έγινε λάθος -> Κόκκινο μήνυμα
        error: (err, stack) => Center(child: Text('Error: $err')),

        // Γ. Αν ήρθαν τα δεδομένα (bikes)
        data: (bikes) {
          // Αν η λίστα είναι άδεια
          if (bikes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.two_wheeler, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Garage is empty', style: TextStyle(fontSize: 20)),
                  Text('Add your first bike below!'),
                ],
              ),
            );
          }

          // Αν έχει μηχανές, φτιάξε λίστα
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bikes.length,
            itemBuilder: (context, index) {
              final bike = bikes[index];

              return Dismissible(
                // Το κλειδί είναι ΑΠΑΡΑΙΤΗΤΟ για να ξέρει το Flutter ποιο σβήνει
                key: Key(bike.id),

                // Σέρνουμε από δεξιά προς τα αριστερά (End -> Start)
                direction: DismissDirection.endToStart,

                // Το κόκκινο φόντο που φαίνεται όταν σέρνεις
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // Τι συμβαίνει όταν ολοκληρωθεί το σύρσιμο
                onDismissed: (direction) {
                  // 1. Καλούμε τον controller να σβήσει τη μηχανή
                  ref.read(garageControllerProvider.notifier).deleteBike(bike.id);

                  // 2. Δείχνουμε μήνυμα επιβεβαίωσης
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${bike.make} deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          // Εδώ θα μπορούσαμε να βάλουμε λογική επαναφοράς (future feature)
                        },
                      ),
                    ),
                  );
                },

                // Εδώ είναι η κάρτα που είχαμε πριν
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: const Icon(Icons.motorcycle, color: Colors.deepOrange),
                    ),
                    title: Text(
                      '${bike.make} ${bike.model}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${bike.year} • ${bike.cc.toInt()}cc'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditBikeScreen(bike: bike),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBikeScreen()),
          );
        },
      ),
    );
  }
}