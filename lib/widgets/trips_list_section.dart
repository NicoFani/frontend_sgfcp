import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/models/trip_data.dart';

class TripsListSection extends StatelessWidget {
  final List<TripData> trips;
  final void Function(TripData trip)? onTripTap;
  final bool showDriverNameSubtitle;

  const TripsListSection({
    super.key,
    required this.trips,
    this.onTripTap,
    this.showDriverNameSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          for (int i = 0; i < trips.length; i++) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(trips[i].route),
              subtitle: Text(
                showDriverNameSubtitle
                    ? (trips[i].driver.fullName.isNotEmpty
                          ? trips[i].driver.fullName
                          : 'Sin chofer')
                    : DateFormat('dd/MM/yyyy').format(trips[i].date),
              ),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                if (onTripTap != null) {
                  onTripTap!(trips[i]);
                }
              },
            ),

            // Divider solo entre elementos
            if (i < trips.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
