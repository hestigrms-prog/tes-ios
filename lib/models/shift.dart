class Shift {
  final String tanggal;
  final String shiftId;
  final String kodeShift;
  final String namaShift;
  final String jamMasuk;
  final String jamPulang;
  final String istirahatMulai;
  final String istirahatSelesai;
  final String toleransiKeterlambatan;
  final String fotoSelfie;
  final String absenLokasi;
  final String gpsRadius;
  final String latitude;
  final String longitude;
  final String jamMasukAbsen;
  final String jamPulangAbsen;
  final String alasanTelatAbsen;
  final String statusTelatAbsen;
  final String statusPulangCepatAbsen;
  final String idAbsen;
  final String jmlCutiDl;
  final String tglLibur;
  final String namaLibur;
  final String ketLibur;

  Shift({
    required this.tanggal, 
    required this.shiftId, 
    required this.kodeShift,
    required this.namaShift,
    required this.jamMasuk,
    required this.jamPulang,
    required this.istirahatMulai,
    required this.istirahatSelesai,
    required this.toleransiKeterlambatan,
    required this.fotoSelfie,
    required this.absenLokasi,
    required this.gpsRadius,
    required this.latitude,
    required this.longitude,
    required this.jamMasukAbsen,
    required this.jamPulangAbsen,
    required this.alasanTelatAbsen,
    required this.statusTelatAbsen,
    required this.statusPulangCepatAbsen,
    required this.idAbsen,
    required this.jmlCutiDl,
    required this.tglLibur,
    required this.namaLibur,
    required this.ketLibur

  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    final data = json['shift'];
    return Shift(
      tanggal: data['tanggal'],
      shiftId: data['shift_id'],
      kodeShift: data['kode_shift'],
      namaShift: data['nama_shift'],
      jamMasuk: data['jam_masuk'],
      jamPulang: data['jam_pulang'],
      istirahatMulai: data['istirahat_mulai'],
      istirahatSelesai: data['istirahat_selesai'],
      toleransiKeterlambatan: data['toleransi_keterlambatan'],
      fotoSelfie: data['foto_selfie'],
      absenLokasi: data['absen_lokasi'],
      gpsRadius: data['gps_radius'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      jamMasukAbsen: data['jam_masuk_absen'],
      jamPulangAbsen: data['jam_pulang_absen'],
      alasanTelatAbsen: data['alasan_telat_absen'],
      statusTelatAbsen: data['status_telat_absen'],
      statusPulangCepatAbsen: data['status_pulang_cepat_absen'],
      idAbsen: data['id_absen'],
      jmlCutiDl: data['jml_cuti_dl'],
      tglLibur: data['tanggal_libur'],
      namaLibur: data['nama_libur'],
      ketLibur: data['keterangan_libur']
    );
  }
}