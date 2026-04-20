import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_ride/features/rides/view/ride_details_screen.dart';
import '../controller/ride_controller.dart';
import 'add_ride_screen.dart';

class RidesScreen extends ConsumerWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          // --- ΛΟΓΙΚΗ ΤΑΞΙΝΟΜΗΣΗΣ (SORTING) ---
          final now = DateTime.now();

          // 1. Μελλοντικές βόλτες (Upcoming): Από την πιο κοντινή στην πιο μακρινή
          final upcomingRides = rides
              .where((r) => r.date.isAfter(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          // 2. Παλιές βόλτες (Done): Από την πιο πρόσφατη στην πιο παλιά
          final pastRides = rides
              .where((r) => r.date.isBefore(now))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          // Ενοποίηση λίστας: Πρώτα τα Upcoming, μετά τα Past
          final sortedRides = [...upcomingRides, ...pastRides];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedRides.length,
            itemBuilder: (context, index) {
              final ride = sortedRides[index];

              // Έλεγχος αν η βόλτα έχει περάσει
              final bool isDone = ride.date.isBefore(now);

              final dateStr = DateFormat('EEE, dd MMM yyyy').format(ride.date);
              final timeStr = DateFormat('HH:mm').format(ride.date);

              return Card(
                elevation: isDone ? 1 : 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDone
                      ? BorderSide(color: Colors.grey.withOpacity(0.2))
                      : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: Opacity(
                  opacity: isDone ? 0.5 : 1.0, // Ακόμα πιο αχνό για τις "Done" βόλτες
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RideDetailsScreen(ride: ride),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ride.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              if (isDone)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PAST',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Text('$dateStr at $timeStr', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Text(ride.meetingPoint),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.grey.withOpacity(0.1) : Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.people, size: 16, color: isDone ? Colors.grey : Colors.indigo),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${ride.participants.length} riders',
                                      style: TextStyle(
                                          color: isDone ? Colors.grey : Colors.indigo,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
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