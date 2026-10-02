import 'package:flutter/material.dart';

class StudentCampusServicesPage extends StatelessWidget {
  const StudentCampusServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      ('Library', 'Books, study spaces and digital resources', Icons.local_library_rounded),
      ('Transport', 'Campus transport and shuttle information', Icons.directions_bus_rounded),
      ('Health Services', 'Campus medical and health information', Icons.local_hospital_rounded),
      ('Sports & Recreation', 'Sports facilities and student activities', Icons.sports_soccer_rounded),
      ('Student Affairs', 'Student support and university services', Icons.groups_rounded),
      ('IT Helpdesk', 'Technical support and account assistance', Icons.computer_rounded),
      ('Campus Security', 'Security and emergency information', Icons.security_rounded),
      ('Cafeteria', 'Dining and campus food services', Icons.restaurant_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Services',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final service = services[index];

          return Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${service.$1} information will be connected here.',
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service.$3,
                      size: 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      service.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
