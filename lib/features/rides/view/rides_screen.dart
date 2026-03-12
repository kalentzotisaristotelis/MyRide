import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/ride_controller.dart';
import 'add_ride_screen.dart';

class RidesScreen extends ConsumerWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Παρακολουθούμε τον provider που φέρνει τις βόλτες (Stream)
    final ridesAsyncValue = ref.watch(ridesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Rides'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ridesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming rides.\nBe the first to organize one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];

              // Μορφοποίηση ημερομηνίας και ώρας
              final dateStr = DateFormat('EEE, dd MMM yyyy').format(ride.date);
              final timeStr = DateFormat('HH:mm').format(ride.date);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Τίτλος Βόλτας
                      Text(
                        ride.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Ημερομηνία & Ώρα
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text('$dateStr at $timeStr', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Σημείο Συνάντησης
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(ride.meetingPoint),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Πόσοι θα πάνε (Participants)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people, size: 16, color: Colors.indigo),
                                const SizedBox(width: 6),
                                Text(
                                  '${ride.participants.length} going',
                                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // Εδώ αργότερα θα βάλουμε το κουμπί "Θα πάω!" (RSVP)
                          TextButton(
                            onPressed: () {
                              // TODO: Άνοιγμα λεπτομερειών βόλτας
                            },
                            child: const Text('DETAILS'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Κουμπί για δημιουργία νέας βόλτας
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road),
        label: const Text('ORGANIZE'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddRideScreen()),
          );
        },
      ),
    );
  }
}