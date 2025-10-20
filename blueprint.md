
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
  - **Firebase Auth:** Google ile kimlik doğrulama desteği.
- **Quiz İşlevselliği:**
  - Quizleri listeleme.
  - Bir quizi seçip başlatma.
  - Soruları cevaplama ve anında geri bildirim alma.
  - Quiz sonunda skoru görme ve yeniden başlatma.
- **Tema Yönetimi:** Uygulama içinde açık ve koyu mod arasında geçiş yapabilme.

## Mevcut Değişiklik Planı ve Adımları

Bu geliştirme oturumunda, uygulamaya iki yeni ana özellik eklenecektir: "Admin için Quiz Ekleme Ekranı" ve "Quiz Arama Ekranı".

### 1. Admin için Quiz Ekleme Ekranı

**Amaç:** Yöneticilerin (geliştirme aşamasında tüm kullanıcıların) uygulama içine yeni quizler ve soruları toplu halde ekleyebilmesi için bir arayüz oluşturmak.

**Adımlar:**
1.  **Yeni Ekran Oluşturma:** `lib/admin/screens/add_quiz_screen.dart` adında yeni bir dosya ve `StatefulWidget` oluşturulacak.
2.  **UI Tasarımı:**
    *   Quiz başlığı, açıklaması ve resim URL'si için `TextField`'lar eklenecek.
    *   Dinamik olarak soru ve cevap eklemek için bir arayüz tasarlanacak. Her soru için:
        *   Soru metni için bir `TextField`.
        *   Cevap seçenekleri için en az 4 adet `TextField`.
        *   Doğru cevabı işaretlemek için `Radio` butonları veya `DropdownButton`.
        *   Yeni soru eklemek için bir "Soru Ekle" butonu.
3.  **Veri Kaydetme İşlevi:**
    *   `FirestoreService` içinde `addQuizWithQuestions` adında yeni bir fonksiyon oluşturulacak. Bu fonksiyon, bir `Quiz` nesnesini ve ona ait `Question` listesini alacak.
    *   Fonksiyon, verileri tek bir atomik işlemle veritabanına yazmak için Firebase `WriteBatch` kullanacak. Önce `quizzes` koleksiyonuna yeni quiz'i, ardından `questions` koleksiyonuna ilgili soruları ekleyecek.
4.  **Navigasyon:**
    *   `HomeDrawer`'a "Yeni Quiz Ekle" adında bir menü öğesi eklenecek ve bu öğe, kullanıcıyı `AddQuizScreen`'e yönlendirecek. Bu öğe, geliştirme süresince herkese görünür olacak.

### 2. Quiz Arama Ekranı

**Amaç:** Kullanıcıların, quiz başlığına veya açıklamasına göre arama yaparak istedikleri quizleri kolayca bulabilmelerini sağlamak.

**Adımlar:**
1.  **Yeni Ekran Oluşturma:** `lib/search/screens/search_screen.dart` adında yeni bir dosya ve `StatefulWidget` oluşturulacak.
2.  **UI Tasarımı:**
    *   Ekranın üst kısmına bir `TextField` (arama çubuğu) yerleştirilecek.
    *   Arama sonuçları, arama çubuğunun altında `ListView` içinde `QuizCard`'lar kullanılarak gösterilecek.
    *   Arama sonucu bulunamadığında bilgilendirici bir metin gösterilecek.
3.  **Arama İşlevi:**
    *   `FirestoreService` içinde `searchQuizzes(String query)` adında yeni bir fonksiyon oluşturulacak.
    *   Bu fonksiyon, şimdilik tüm quizleri `Firestore`'dan çekecek ve istemci tarafında (client-side) filtreleme yapacak. Filtreleme, quiz `title` ve `description` alanlarının arama metnini (küçük/büyük harf duyarsız) içerip içermediğini kontrol edecek.
    *   Kullanıcı arama çubuğuna yazdıkça arama sonuçları anlık olarak güncellenecek. (Performans için `debounce` tekniği uygulanabilir).
4.  **Navigasyon:**
    *   `HomeScreen`'in `AppBar`'ına bir arama ikonu (`IconButton`) eklenecek. Bu ikona tıklandığında `SearchScreen` açılacak.
