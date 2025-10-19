import 'package:myapp/quiz/models/quiz_model.dart';

final List<Quiz> dummyQuizzes = [
  const Quiz(
    id: 'q1',
    title: 'Yüzüklerin Efendisi Serisi',
    description: 'Orta Dünya bilgini bu epik seriyle test et!',
    category: 'Fantastik',
    isPublished: true,
    durationMinutes: 10,
    totalQuestions: 15,
    createdByUid: 'admin_user_1',
    imageUrl: 'https://wallpapercave.com/wp/wp2541629.jpg', // Örnek resim URL'si
  ),
  const Quiz(
    id: 'q2',
    title: 'Marvel Sinematik Evreni',
    description: "Demir Adam'dan End Game'e tüm filmler hakkında ne biliyorsun?",
    category: 'Aksiyon / Bilim Kurgu',
    isPublished: true,
    durationMinutes: 15,
    totalQuestions: 20,
    createdByUid: 'admin_user_1',
    imageUrl: 'https://wallpapercave.com/wp/wp2541629.jpg', // Örnek resim URL'si
  ),
  const Quiz(
    id: 'q3',
    title: 'Christopher Nolan Filmleri',
    description: "Inception, Interstellar ve daha fazlası... Nolan'ın dünyasına ne kadar hakimsin?",
    category: 'Gerilim / Bilim Kurgu',
    isPublished: true,
    durationMinutes: 8,
    totalQuestions: 12,
    createdByUid: 'admin_user_2',
    imageUrl: 'https://wallpapercave.com/wp/wp2541629.jpg', // Örnek resim URL'si
  ),
  const Quiz(
    id: 'q4',
    title: 'Game of Thrones Dizisi',
    description: "Westeros'un entrika dolu dünyasından kim sağ çıkacak? Bilgini sına",
    category: 'Tarihi Dizi / Fantastik',
    isPublished: false, // Bu quiz henüz yayınlanmadı
    durationMinutes: 12,
    totalQuestions: 18,
    createdByUid: 'admin_user_2',
    imageUrl: 'https://wallpapercave.com/wp/wp2541629.jpg', // Örnek resim URL'si
  ),
];
