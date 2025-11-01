# Proje Mimarisi ve Geliştirme Planı

Bu doküman, Flutter projesinin mimarisini, tasarım prensiplerini ve geliştirme yol haritasını ana hatlarıyla belirtir.

## **1. Genel Bakış**

Bu proje, kullanıcıların çeşitli konularda quizler çözerek bilgi seviyelerini test edebilecekleri bir mobil uygulamadır. Uygulama, Firebase entegrasyonu ile modern, etkileşimli ve kişiselleştirilebilir bir deneyim sunmayı hedefler.

### **Temel Bileşenler**

- **Uygulama Mimarisi:** `Provider` paketi kullanılarak basit ve etkili bir durum yönetimi mimarisi benimsenmiştir.
- **Veritabanı:** Quizler, sorular ve kullanıcı verileri için `Cloud Firestore`.
- **Kimlik Doğrulama:** `Firebase Auth` ile Google Sign-In. Oturum kalıcılığı ve güvenli çıkış desteği.
- **Tasarım:** `Material 3` prensiplerine uygun, açık ve koyu tema seçenekli modern bir arayüz.
- **Yazı Tipleri:** `google_fonts` paketi ile zenginleştirilmiş tipografi.

### **Kullanıcı Arayüzü ve Tasarım**

- **Tema:** `Material 3` kullanılarak modern bir tasarım benimsenmiştir. `ColorScheme.fromSeed` ile ana bir renkten (mor) türetilmiş, tutarlı bir açık ve koyu tema bulunur.
- **Yazı Tipleri:** `google_fonts` paketi ile `Oswald` ve `Roboto` gibi özel fontlar kullanılarak tipografi zenginleştirilmiştir.
- **Görsel Bileşenler:**
  - Ana sayfada quizleri listeleyen, duyarlı bir grid yapısı içinde `QuizCard`'lar.
  - Quiz başlangıcını gösteren bir giriş ekranı (`QuizIntro`).
  - Soruları ve cevap seçeneklerini gösteren interaktif bir arayüz (`QuestionDisplay`).
  - Quiz sonunda skoru ve cevapları gösteren bir sonuç ekranı (`QuizResults`).
  - **Alt Navigasyon Çubuğu (`BottomNavBar`):** Ana sayfa, profil ve ayarlara kolay erişim sağlar.
- **Animasyonlar:** `AnimatedSwitcher` ile ekran geçişlerinde yumuşak bir animasyon sağlanır. `LinearProgressIndicator` ile quiz ilerlemesi gösterilir.

### **Özellikler**

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

## **Geliştirme Planı (Devam Eden)**

- **Ana Ekran İyileştirmeleri:**
  - Quizler son eklenenden başa doğru sıralanacak.
  - Kullanıcının daha önce çözdüğü quizler soluk renkte ve "ÇÖZÜLDÜ" etiketiyle gösterilecek.
  - Son 10 gün içinde eklenen quizlerde "YENİ" etiketi bulunacak.

## **Tamamlanan Son Değişiklikler**

- Projedeki tüm statik analiz hataları ve uyarıları giderildi.
- Kod tabanı temizlendi ve en iyi pratiklere uygun hale getirildi.
- Eksik olan `add_quiz_screen.dart`, `quiz_card.dart` ve `theme_provider.dart` dosyaları oluşturuldu.
- `shared_preferences` paketi eklenerek tema kalıcılığı sağlandı.
