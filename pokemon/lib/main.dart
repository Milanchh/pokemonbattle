import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon TCG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CardListPage()),
      );
    });

    return const Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/pok.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pokemon TCG',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 8,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  List<dynamic> cards = [];
  List<dynamic> filteredCards = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCards();
    _searchController.addListener(_filterCards);
  }

  Future<void> fetchCards() async {
    const apiUrl = "https://api.pokemontcg.io/v2/cards";
    const apiKey = "96f38d1c-2a50-4d4d-93e8-a148fe694b6c";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cards = data['data'];
          filteredCards = cards;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCards() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCards = cards
          .where((card) => card['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Cards'),
        backgroundColor: Colors.indigo.shade700,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BattlePage()),
                );
              },
              child: const Text(
                'Battle',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Color of the button text
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/bck.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardDetailPage(card: card),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  card['images']['small'],
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 13, 12, 12),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    if (card['supertype'] != null)
                                      Text(
                                        "Type: ${card['supertype']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    if (card['rarity'] != null)
                                      Text(
                                        "Rarity: ${card['rarity']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    if (card['set']['name'] != null)
                                      Text(
                                        "Set: ${card['set']['name']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class CardDetailPage extends StatelessWidget {
  final dynamic card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name']),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  card['images']['large'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (card['supertype'] != null)
                      Text(
                        "Type: ${card['supertype']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (card['rarity'] != null)
                      Text(
                        "Rarity: ${card['rarity']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (card['set']['name'] != null)
                      Text(
                        "Set: ${card['set']['name']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  dynamic card1;
  dynamic card2;
  bool isLoading = false;
  String winner = '';

  @override
  void initState() {
    super.initState();
    _loadRandomCards();
  }

  Future<void> _loadRandomCards() async {
    setState(() {
      isLoading = true;
      winner = '';
    });

    const apiUrl = "https://api.pokemontcg.io/v2/cards";
    const apiKey = "96f38d1c-2a50-4d4d-93e8-a148fe694b6c";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final random = Random();
        setState(() {
          card1 = data[random.nextInt(data.length)];
          card2 = data[random.nextInt(data.length)];
          _determineWinner();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _determineWinner() {
    if (card1 != null && card2 != null) {
      final hp1 = int.tryParse(card1['hp'] ?? '0') ?? 0;
      final hp2 = int.tryParse(card2['hp'] ?? '0') ?? 0;

      if (hp1 > hp2) {
        winner = '${card1['name']} wins!';
      } else if (hp1 < hp2) {
        winner = '${card2['name']} wins!';
      } else {
        winner = 'It\'s a tie!';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Battle'),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/bck.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (card1 != null) CardDisplay(card: card1),
                          if (card2 != null) CardDisplay(card: card2),
                        ],
                      ),
                    ),
                    Text(
                      winner,
                      style: const TextStyle(
                        fontSize: 32,  // Increased font size for winner text
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Changed text color to white
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 8,
                            color: Color.fromARGB(115, 241, 238, 238), // Added shadow for visibility
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadRandomCards,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,  // Increased vertical padding
                          horizontal: 40,  // Increased horizontal padding
                        ),
                      ),
                      child: const Text(
                        'Play',
                        style: TextStyle(
                          fontSize: 24,  // Increased font size for button text
                          color: Colors.white, // Button text color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        ],
      ),
    );
  }
}

class CardDisplay extends StatelessWidget {
  final dynamic card;

  const CardDisplay({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (card['images'] != null)
          Image.network(
            card['images']['large'],
            width: 180,  // Increased card width
            height: 270,  // Increased card height
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 16),  // Increased spacing
        Text(
          card['name'],
          style: const TextStyle(
            fontSize: 22,  // Increased font size for card name
            fontWeight: FontWeight.bold,
            color: Colors.white,  // Set text color to white
          ),
          textAlign: TextAlign.center,
        ),
        if (card['hp'] != null)
          Text(
            'HP: ${card['hp']}',
            style: const TextStyle(
              fontSize: 20,  // Increased font size
              color: Colors.white,  // Set text color to white
            ),
          ),
      ],
    );
  }
}
