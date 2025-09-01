import 'package:flutter/material.dart';

class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/album_art.jpg'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Can\'t Stop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Red Hot Chili Peppers',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('0:00', style: TextStyle(color: Colors.white70)),
                  Text('4:29', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Slider(
              value: 0.0,
              min: 0.0,
              max: 4.29,
              onChanged: (value) {},
              activeColor: Colors.red,
              inactiveColor: Colors.white24,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white70,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  iconSize: 40,
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.loop, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
