
# Blueprint: Flutter Quiz Uygulaması

## Genel Bakış

Bu proje, kullanıcılara çeşitli konularda quizler sunan bir Flutter uygulamasıdır. Firebase Firestore'u arka uç olarak kullanarak quizleri, soruları ve kullanıcı cevaplarını yönetir. Uygulama, modern bir kullanıcı arayüzü, gelişmiş tema yönetimi, Firebase kimlik doğrulama ve gerçek zamanlı veritabanı özelliklerini içerir.

## Uygulanan Stil, Tasarım ve Özellikler

### Proje Yapısı ve Mimarisi
- **State Management:** `provider` paketi kullanılarak uygulama genelindeki state (tema, kimlik doğrulama) yönetilir.
- **Servis Katmanı:** `FirestoreService` sınıfı, Firestore veritabanı ile olan tüm etkileşimleri (quiz okuma, yazma vb.) soyutlar.
- **Modeller:** `Quiz`, `Question`, `Option` gibi veri yapıları için özel model sınıfları (`lib/quiz/models/`) oluşturulmuştur. Bu modeller, `toMap` metotları sayesinde Firestore ile uyumlu çalışır.
- **Klasör Yapısı:** Kod, `login`, `home`, `quiz`, `settings` gibi özelliklere göre modüler bir şekilde organize edilmiştir.

### Kullanıcı Arayüzü ve Tasarım
- **Tema:** `Material 3` kullanılarak modern bir tasarım benimsenmiştir. `ColorScheme.fromSeed` ile ana bir renkten (mor) türetilmiş, tutarlı bir açık ve koyu tema bulunur.
- **Yazı Tipleri:** `google_fonts` paketi ile `Oswald` ve `Roboto` gibi özel fontlar kullanılarak tipografi zenginleştirilmiştir.
- **Görsel Bileşenler:**
  - Ana sayfada quizleri listeleyen, duyarlı bir grid yapısı içinde `QuizCard`'lar.
  - Quiz başlangıcını gösteren bir giriş ekranı (`QuizIntro`).
  - Soruları ve cevap seçeneklerini gösteren interaktif bir arayüz (`QuestionDisplay`).
  - Quiz sonunda skoru ve cevapları gösteren bir sonuç ekranı (`QuizResults`).
  - **Alt Navigasyon Çubuğu (`BottomNavBar`):** Ana sayfa, profil ve ayarlara kolay erişim sağlar.
- **Animasyonlar:** `AnimatedSwitcher` ile ekran geçişlerinde yumuşak bir animasyon sağlanır. `LinearProgressIndicator` ile quiz ilerlemesi gösterilir.

### Özellikler
- **Firebase Entegrasyonu:**
  - **Firestore:** Quizler ve alt koleksiyon olarak sorular veritabanında saklanır.
  - **Firebase Auth:** Google ile kimlik doğrulama desteği.
- **Quiz İşlevselliği:**
  - Quizleri listeleme ve anında arama/filtreleme.
  - Bir quizi seçip başlatma.
  - Soruları cevaplama ve anında geri bildirim alma.
  - Quiz sonunda skoru görme ve yeniden başlatma.
- **Yönetim Paneli:**
  - Uygulama içinden yeni quiz ve sorular eklemek için özel bir ekran (`AddQuizScreen`).
- **Tema Yönetimi (Ayarlar Ekranı):**
  - Kullanıcılar, özel bir "Ayarlar" ekranından **Açık**, **Koyu** veya **Sistem Varsayılanı** temalarından birini seçebilir.
  - Tema tercihleri, `ThemeProvider` ve `provider` aracılığıyla uygulama genelinde anlık olarak uygulanır.

## Tamamlanan Son Değişiklikler

- **Tema Yönetimi Ayarlar Ekranına Taşındı:**
  - **Amaç:** Tema değiştirme işlevini daha profesyonel bir yapıya kavuşturmak.
  - **Yapılanlar:**
    1. `ThemeProvider`, `setThemeMode` metodu ile daha esnek hale getirildi.
    2. `lib/settings/screens/settings_screen.dart` adında, kullanıcının tema tercihini `RadioListTile`'lar ile yapabildiği yeni bir ekran oluşturuldu.
    3. `lib/shared/bottom_nav.dart` dosyası güncellenerek "Ayarlar" sekmesi işlevsel hale getirildi ve `SettingsScreen`'e yönlendirme yapması sağlandı.

- **Kod Temizliği ve Hata Düzeltmeleri:**
  - Projede tekrar eden `add_quiz_screen.dart` dosyalarından biri (eski olan) silinerek kod tutarlılığı artırıldı.
  - `AddQuizScreen`'de karşılaşılan `Null` tipi hatası ve `addQuiz` metot hatası gibi kritik hatalar düzeltildi.
