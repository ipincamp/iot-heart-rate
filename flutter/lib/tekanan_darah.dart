class TekananDarahData {
  final int sistolik;
  final int diastolik;
  final String waktu;

  TekananDarahData({
    required this.sistolik,
    required this.diastolik,
    required this.waktu,
  });

  factory TekananDarahData.fromJson(Map<String, dynamic> json) {
    return TekananDarahData(
      sistolik: json['sistolik'],
      diastolik: json['diastolik'],
      waktu: json['waktu'],
    );
  }
}
