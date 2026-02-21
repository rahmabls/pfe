class Weather {
  final double temp;
  final String description;
  final int humidity;
  final int pressure;
  final double wind;

  Weather({
    required this.temp,
    required this.description,
    required this.humidity,
    required this.pressure,
    required this.wind,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: (json["main"]["temp"] as num).toDouble(),
      description: json["weather"][0]["description"],
      humidity: json["main"]["humidity"],
      pressure: json["main"]["pressure"],
      wind: (json["wind"]["speed"] as num).toDouble(),
    );
  }
}
