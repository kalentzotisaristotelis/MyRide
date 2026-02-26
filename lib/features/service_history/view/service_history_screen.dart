import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Βοηθάει να δείχνουμε ωραία την ημερομηνία
import '../../garage/domain/bike_model.dart';
import '../controller/service_controller.dart';
import 'add_service_screen.dart';

class ServiceHistoryScreen extends ConsumerWidget {
  final Bike bike; // Παίρνουμε τη μηχανή για να ξέρουμε ποιανού είναι τα services

  const ServiceHistoryScreen({super.key, required this.bike});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Διαβάζουμε τα services ΜΟΝΟ για αυτή τη μηχανή (περνάμε το bike.id)
    final servicesAsync = ref.watch(bikeServicesProvider(bike.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${bike.make} Services'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (services) {
          if (services.isEmpty) {
            return const Center(
              child: Text('No service records yet.\nTap + to add one!', textAlign: TextAlign.center),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              // Μετατρέπουμε την ημερομηνία σε ωραίο format (π.χ. 25 Oct 2023)
              final dateStr = DateFormat('dd MMM yyyy').format(service.date);

              return Dismissible(
                key: Key(service.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(serviceControllerProvider.notifier).deleteService(service.id);
                },
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.build, color: Colors.white, size: 20),
                    ),
                    title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$dateStr  •  ${service.mileage} km\n${service.notes}'),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddServiceScreen(bike: bike),
            ),
          );
        },
      ),
    );
  }
}