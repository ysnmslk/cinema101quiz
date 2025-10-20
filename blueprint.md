
# Blueprint: Flutter Quiz Uygulaması

## Genel Bakış

Bu proje, kullanıcılara çeşitli konularda quizler sunan bir Flutter uygulamasıdır. Firebase Firestore'u arka uç olarak kullanarak quizleri, soruları ve kullanıcı cevaplarını yönetir. Uygulama, modern bir kullanıcı arayüzü, tema yönetimi (açık/koyu mod) ve Firebase entegrasyonu özelliklerini içerir.

## Uygulanan Stil, Tasarım ve Özellikler

### Proje Yapısı ve Mimarisi
- **State Management:** `provider` paketi kullanılarak uygulama genelindeki state (tema, kimlik doğrulama) yönetilir.
- **Servis Katmanı:** `FirestoreService` sınıfı, Firestore veritabanı ile olan tüm etkileşimleri soyutlar.
- **Modeller:** `Quiz`, `Question` gibi veri yapıları için özel model sınıfları oluşturulmuştur.
- **Klasör Yapısı:** Kod, `auth`, `home`, `quiz` gibi özelliklere göre modüler bir şekilde organize edilmiştir.

### Kullanıcı Arayüzü ve Tasarım
- **Tema:** `Material 3` kullanılarak modern bir tasarım benimsenmiştir. `ColorScheme.fromSeed` ile ana bir renkten (mor) türetilmiş açık ve koyu temalar bulunur.
- **Yazı Tipleri:** `google_fonts` paketi ile `Oswald` ve `Roboto` gibi özel fontlar kullanılarak tipografi zenginleştirilmiştir.
- **Görsel Bileşenler:**
  - Ana sayfada quizleri listeleyen kartlar (`QuizCard`).
  - Quiz başlangıcını gösteren bir giriş ekranı (`QuizIntro`).
  - Soruları ve cevap seçeneklerini gösteren interaktif bir arayüz (`QuestionDisplay`).
  - Quiz sonunda skoru ve cevapları gösteren bir sonuç ekranı (`QuizResults`).
  - Yan menü (`HomeDrawer`) ile tema değiştirme ve çıkış yapma işlevleri.
- **Animasyonlar:** `AnimatedSwitcher` ile ekran geçişlerinde yumuşak bir animasyon sağlanır. `LinearProgressIndicator` ile quiz ilerlemesi gösterilir.

### Özellikler
- **Firebase Entegrasyonu:**
  - **Firestore:** Quizler ve sorular veritabanında saklanır.
  - **Firebase Auth:** Google ile kimlik doğrulama desteği (henüz tam entegre edilmedi).
- **Quiz İşlevselliği:**
  - Quizleri listeleme.
  - Bir quizi seçip başlatma.
  - Soruları cevaplama.
  - Cevapların doğruluğunu anında görsel geri bildirimle (renk değişimi) görme.
  - Quiz sonunda toplam skoru görme.
  - Quizi yeniden başlatma.
- **Tema Yönetimi:** Kullanıcı, uygulama içinde açık ve koyu mod arasında geçiş yapabilir.

## Mevcut Değişiklik Planı ve Adımları (Tamamlandı)

Bu geliştirme oturumunda, "The getter 'questions' isn't defined for the type 'Quiz'" hatasının çözülmesi ve kod kalitesinin artırılması hedeflenmiştir.

**Plan:**
1.  **Hata Analizi:** Ana hatanın, `Quiz` modelinin `questions` listesini içermemesinden ve `FirestoreService`'in bu listeyi yüklememesinden kaynaklandığını tespit et.
2.  **Model Güncellemesi:** `lib/quiz/models/quiz_model.dart` dosyasındaki `Quiz` sınıfına `List<Question> questions` alanını ekle.
3.  **Servis Güncellemesi:** `lib/quiz/services/firestore_service.dart` dosyasındaki `getQuizById` fonksiyonunu, quiz'in ana verileriyle birlikte "quiz_questions" koleksiyonundan ilgili soruları da çekecek ve tam bir `Quiz` nesnesi oluşturacak şekilde güncelle.
4.  **Kod Analizi ve Linting:** Kod analizi yaparak ortaya çıkan linter uyarılarını (özellikle `use_build_context_synchronously` ve `deprecated_member_use`) tespit et.
5.  **Kritik Uyarıları Düzeltme:**
    - `quiz_screen.dart` ve `home_drawer.dart` dosyalarında, asenkron işlemlerden sonra `BuildContext` kullanmadan önce `mounted` kontrolü ekleyerek `use_build_context_synchronously` uyarısını çöz.
    - `home_drawer.dart` widget'ını `StatefulWidget`'a dönüştürerek ve `Navigator`'ı asenkron işlem öncesi değişkene atayarak bu hatayı kalıcı olarak düzelt.
    - `question_display.dart` dosyasında eski `withOpacity` ve `MaterialStateProperty` kullanımlarını, önerilen `withAlpha` ve `WidgetStateProperty` ile değiştir.
6.  **Doğrulama:** Tüm düzeltmelerden sonra son bir kod analizi yaparak projede kritik hata veya uyarı kalmadığını doğrula.

**Sonuç:** Belirtilen adımlar başarıyla tamamlanmış, ana hata ve ilgili tüm kritik uyarılar giderilmiştir. Uygulama artık kararlı ve çalışır durumdadır.
