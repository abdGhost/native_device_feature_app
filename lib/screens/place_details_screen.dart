import 'package:flutter/material.dart';
import 'package:native_device_feature/screens/map_screen.dart';

import '../models/place.dart';

class PlaceDetailsScreen extends StatelessWidget {
  String get locationImage {
    final lat = place.location.latitude;
    final lng = place.location.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C$lat,$lng&key=YOUR_API_KEY&signature=YOUR_SIGNATURE';
  }

  const PlaceDetailsScreen({
    super.key,
    required this.place,
  });
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            place.title,
          ),
        ),
        body: Stack(
          children: [
            Image.file(
              place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => MapScreen(
                            location: place.location,
                            isSelecting: false,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        locationImage,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                    child: Text(
                      place.location.address,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
