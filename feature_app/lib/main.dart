import 'package:flutter/material.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  Future<void> _getWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await WeatherService.fetchWeather(_cityName);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white), // Text color set to white
        ),
        backgroundColor: const Color.fromARGB(255, 47, 2, 109), // AppBar background color
      ),
      backgroundColor: Colors.black, // Set the background color of the Scaffold to black
      body: Stack(
        children: [
          // Custom Background with Sun and Clouds
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          // Main Content of the app
          Container(
            color: Colors.transparent, // Transparent background to show custom background
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white), // Input text color
                    decoration: const InputDecoration(
                      labelText: 'Enter City Name',
                      labelStyle: TextStyle(color: Colors.white), // Label text color
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _cityName = _cityController.text.trim();
                      });
                      _getWeather();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cityName = _cityController.text.trim();
                      });
                      _getWeather();
                    },
                    child: const Text('Get Weather'),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_error != null)
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    )
                  else if (_weatherData != null)
                      WeatherDetails(weatherData: _weatherData!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherDetails extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherDetails({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = weatherData['current'];
    final temperature = current['temperature'];
    final description = current['weather_descriptions'][0];
    final windSpeed = current['wind_speed'];
    final humidity = current['humidity'];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // Semi-transparent black background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' $temperature°C',
            style: const TextStyle(fontSize: 100, color: Colors.white),
          ),
          Text(
            'Description: $description',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Wind Speed: $windSpeed km/h',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Humidity: $humidity%',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// CustomPainter to draw sun and clouds
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Draw the sun
    paint.color = Colors.yellow.withOpacity(1);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.65), 50, paint);

    // Draw clouds
    paint.color = Colors.white.withOpacity(1);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * 0.55, size.height * 0.7), radius: 50), paint);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * 0.60, size.height * 0.75), radius: 60), paint);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * 0.45, size.height * 0.7), radius: 55), paint);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * 0.40, size.height * 0.75), radius: 60), paint);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * 0.30, size.height * 0.75), radius: 55), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
