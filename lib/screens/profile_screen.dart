import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/profileField.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Pegawai> _pegawaiFuture;

  @override
  void initState() {
    super.initState();
    _pegawaiFuture = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Pegawai>(
        future: _pegawaiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak tersedia'));
          } else {
            final pegawai = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: pegawai.foto.isNotEmpty
                        ? NetworkImage(pegawai.foto)
                        : const AssetImage('assets/icon/user.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                    child: Text(
                  pegawai.namaPegawai,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 8),
                Center(child: Text(pegawai.email)),
                const SizedBox(height: 24),

                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ProfileField(label: "NIK", value: pegawai.nik),
                        ProfileField(label: "Tempat Lahir", value: pegawai.tempatLahir),
                        ProfileField(label: "Tanggal Lahir", value: pegawai.tanggalLahir),
                        ProfileField(label: "Umur", value: pegawai.umur),
                        ProfileField(label: "Jenis Kelamin", value: pegawai.jenisKelamin),
                        ProfileField(label: "Agama", value: pegawai.agama),
                        ProfileField(label: "Alamat", value: pegawai.alamat),
                        ProfileField(label: "Telpon", value: pegawai.telpon),
                      ],
                    ),
                  ),
                ),

                // Informasi Karyawan
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ProfileField(label: "Nomor Pegawai", value: pegawai.nomorPegawai),
                        ProfileField(label: "Status Pegawai", value: pegawai.statusPegawai),
                        ProfileField(label: "Tanggal Gabung", value: pegawai.tanggalGabung),
                        ProfileField(label: "Masa Kerja", value: pegawai.masaKerja),
                        ProfileField(label: "Branch", value: pegawai.branch),
                        ProfileField(label: "Organisasi", value: pegawai.organisasi),
                        ProfileField(label: "Jabatan", value: pegawai.jobPosition),
                        ProfileField(label: "Level", value: pegawai.jobLevel),
                        ProfileField(label: "Grade", value: pegawai.grade),
                        ProfileField(label: "Class", value: pegawai.class_),
                        ProfileField(label: "Approval Line", value: pegawai.approvalLine),
                        ProfileField(label: "Manager", value: pegawai.manager),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}