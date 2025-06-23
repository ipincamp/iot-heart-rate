class JarakData { 
  final int id; 
  final double jarak; 
  final String waktu; 
 
  JarakData({required this.id, required this.jarak, required 
this.waktu}); 
 
  factory JarakData.fromJson(Map<String, dynamic> json) { 
    return JarakData( 
      id: json['id'], 
      jarak: (json['jarak'] as num).toDouble(), 
      waktu: json['waktu'], 
    ); 
  } 
} 