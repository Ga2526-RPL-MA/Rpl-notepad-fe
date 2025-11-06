import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/chat_detail_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/class_message_card.dart';

class ClassDiscussionPage extends StatelessWidget {
  const ClassDiscussionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Evolusi Perangkat Lunak',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
              // List of messages
              ChatMessageCard(
                name: 'Andina Pasha Rahmania',
                message:
                    'Kamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/paKamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/page jadi Kamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/page jadi ge jadi warna biru muda seperti tema biru (bukan hijau abu), tinggal kandjkandkakadkndaknkanajkdnaknand.....',
                replyCount: 3,
                isOnline: true,
                onTap: () {
                  _showMessageDetail(
                    context,
                    'Andina Pasha Rahmania',
                    'Kamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/paKamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/page jadi Kamu maksud biru yang di background figma tadi ya?Kalau kamu ingin ubah canvas/page jadi ge jadi warna biru muda seperti tema biru (bukan hijau abu), tinggal kandjkandkakadkndaknkanajkdnaknand.....',
                    3,
                    true,
                  );
                },
              ),
              const SizedBox(height: 16),
              ChatMessageCard(
                name: 'Mochammad Kolbi Nuron',
                message: 'SRD DANCOKKKKKKKK',
                replyCount: 1,
                onTap: () {
                  _showMessageDetail(
                    context,
                    'Mochammad Kolbi Nuron',
                    'SRD DANCOKKKKKKKK',
                    1,
                    false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDetail(
    BuildContext context,
    String name,
    String message,
    int replyCount,
    bool isOnline,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatDetailPage(name: name, message: message, isOnline: isOnline),
      ),
    );
  }
}
