class Pegawai {
  final String namaPegawai;
  final String nik;
  final String no_passport;
  final String tempatLahir;
  final String tanggalLahir;
  final String umur;
  final String telpon;
  final String email;
  final String jenisKelamin;
  final String agama;
  final String perkawinan;
  final String kodePos;
  final String alamat;
  final String alamatDomisili;
  final String wna;
  final String foto;

  final String nomorPegawai;
  final String statusPegawai;
  final String tanggalGabung;
  final String masaKerja;
  final String branch;
  final String organisasi;
  final String jobPosition;
  final String jobLevel;
  final String grade;
  final String class_;
  final String approvalLine;
  final String manager;

  Pegawai({
    required this.namaPegawai,
    required this.nik,
    required this.no_passport,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.umur,
    required this.telpon,
    required this.email,
    required this.jenisKelamin,
    required this.agama,
    required this.perkawinan,
    required this.kodePos,
    required this.alamat,
    required this.alamatDomisili,
    required this.wna,
    required this.foto,

    required this.nomorPegawai,
    required this.statusPegawai,
    required this.tanggalGabung,
    required this.masaKerja,
    required this.branch,
    required this.organisasi,
    required this.jobPosition,
    required this.jobLevel,
    required this.grade,
    required this.class_,
    required this.approvalLine,
    required this.manager
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    final data = json['profile'];
    return Pegawai(
      namaPegawai: data['nama_pegawai'] ?? '',
      nik: data['nik'] ?? '',
      no_passport: data['no_passport'] ?? '' ,
      tempatLahir: data['tempat_lahir'] ?? '' ,
      tanggalLahir: data['tanggal_lahir'] ?? '' ,
      umur: data['umur'] ?? '' ,
      telpon: data['nomor_hp'] ?? '' ,
      email: data['email'] ?? '' ,
      jenisKelamin: data['jenis_kelamin'] ?? '' ,
      agama: data['agama'] ?? '' ,
      perkawinan: data['status_perkawinan'] ?? '' ,
      kodePos: data['kode_pos'] ?? '' ,
      alamat: data['alamat'] ?? '' ,
      alamatDomisili: data['alamat_domisi'] ?? '' ,
      wna: data['wna'] ?? '' ,
      foto: data['foto'] ?? '' ,

      nomorPegawai: data['nomor_pegawai'] ?? '' ,
      statusPegawai: data['status_pegawai'] ?? '' ,
      tanggalGabung: data['tanggal_mulai'] ?? '' ,
      masaKerja: data['masa_kerja'] ?? '' ,
      branch: data['branch'] ?? '' ,
      organisasi: data['organisasi'] ?? '' ,
      jobPosition: data['job_position'] ?? '' ,
      jobLevel: data['job_level'] ?? '' ,
      grade: data['grade'] ?? '' ,
      class_: data['class'] ?? '' ,
      approvalLine: data['nama_pegawai_atasan_1'] ?? '' ,
      manager: data['nama_pegawai_atasan_2'] ?? ''
    );
  }
}