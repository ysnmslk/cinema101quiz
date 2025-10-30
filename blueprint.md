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

## **Tamamlanan Son Değişiklikler**

- **Profil Ekranı İyileştirmesi:**
  - **Amaç:** Çözülen quizlerin profil ekranında görünmemesi sorununu çözmek.
  - **Yapılanlar:**
    1. `lib/quiz/services/firestore_service.dart` içindeki `getUserResultsWithQuizDetails` fonksiyonu yeniden yazılarak daha verimli ve hataya dayanıklı hale getirildi.
    2. Yeni mantık, kullanıcının sonuçlarını ve tüm quizleri paralel olarak çekip, bu verileri uygulama içinde (bellekte) birleştirerek Firestore'a yapılan çağrıları azalttı ve veri tutarlılığı sorunlarını giderdi.

## **Güncel Plan: Oturum Yönetimi ve Çıkış Özelliği**

- **Amaç:** Kullanıcının her seferinde giriş yapmak zorunda kalmamasını sağlamak (oturum kalıcılığı) ve istediği zaman güvenli bir şekilde çıkış yapabilmesi için bir mekanizma eklemek.

- **Yapılacaklar:**
  1.  **Merkezi Kimlik Doğrulama Servisi (`AuthService`) Oluşturma:**
      - `lib/auth/services/auth_service.dart` adında yeni bir dosya oluşturulacak.
      - Google ile giriş yapma ve oturumu kapatma (`signOut`) mantığı bu sınıfta toplanacak.
  2.  **Giriş Ekranı (`LoginScreen`) Oluşturma:**
      - `lib/auth/screens/login_screen.dart` adında, sadece "Google ile Giriş Yap" düğmesini içeren özel bir ekran oluşturulacak.
  3.  **Yönlendirme Kapısı (`AuthGate`) Oluşturma:**
      - `lib/auth/widgets/auth_gate.dart` adında bir widget oluşturulacak.
      - Bu widget, `FirebaseAuth.instance.authStateChanges()` stream'ini dinleyerek, aktif bir kullanıcı oturumu olup olmadığını kontrol edecek.
      - Oturum varsa kullanıcıyı `HomeScreen`'e, yoksa `LoginScreen`'e yönlendirecek.
  4.  **`main.dart` Güncellemesi:**
      - Uygulamanın başlangıç noktası (`home`) olarak yeni oluşturulan `AuthGate` widget'ı ayarlanacak.
  5.  **Oturumu Kapat Düğmesi Ekleme:**
      - `lib/settings/screens/settings_screen.dart` ekranına, `AuthService`'teki `signOut` metodunu çağıran bir "Oturumu Kapat" seçeneği (örneğin bir `ListTile`) eklenecek.
  6.  **Kod Temizliği:** `HomeScreen` gibi diğer ekranlardaki mevcut giriş yapma mantığı kaldırılacak, çünkü artık tüm kontrol `AuthGate` ve `LoginScreen`'de olacak.
