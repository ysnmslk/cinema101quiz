# Cinema 101 Quiz - Proje Mavi Kopyası

## Genel Bakış

Cinema 101 Quiz, kullanıcılara sinema ve filmlerle ilgili eğlenceli ve bilgilendirici bir quiz deneyimi sunmayı amaçlayan bir Flutter uygulamasıdır. Kullanıcılar farklı kategorilerdeki soruları yanıtlayarak sinema bilgilerini test edebilirler.

## Mevcut Özellikler (v0.1)

- **Temel Flutter Proje Yapısı:** Standart Flutter proje iskeleti oluşturuldu.
- **Firebase Entegrasyonu (Android):**
  - Firebase projesiyle bağlantı kuruldu.
  - Android uygulaması için `google-services.json` yapılandırıldı.
  - Gerekli SHA-1 ve SHA-256 parmak izleri Firebase projesine eklendi.
- **Sürüm Kontrolü:**
  - Proje için yerel Git deposu başlatıldı.
  - Hassas ve gereksiz dosyaları hariç tutmak için `.gitignore` dosyası eklendi.
  - Proje, GitHub'daki `cinema101quiz` adlı uzak depoya başarıyla gönderildi.

## Stil ve Tasarım Notları

- Henüz özel bir tasarım veya tema uygulanmadı.
- Varsayılan Flutter Material Design bileşenleri kullanılıyor.

## Sonraki Adımlar İçin Plan

1.  **Görsel Arayüz (UI) Tasarımı:**
    - Uygulama için modern ve çekici bir tema oluşturulacak (renk paleti, tipografi).
    - Ana ekran, quiz ekranı ve sonuç ekranı gibi temel sayfaların arayüzleri tasarlanacak.
2.  **Temel Navigasyon:**
    - Sayfalar arası geçişi yönetmek için bir yönlendirme (routing) çözümü (örn. `go_router`) eklenecek.
3.  **Quiz Mantığı:**
    - Soru ve cevapları yönetecek veri modelleri (`Question`, `Answer`) oluşturulacak.
    - Kullanıcının cevaplarını kontrol edecek ve skoru hesaplayacak temel bir quiz motoru geliştirilecek.
4.  **Veri Kaynağı:**
    - Başlangıçta, sorular ve cevaplar doğrudan kod içindeki bir listede (`List<Question>`) tutulacak.
    - İlerleyen aşamalarda soruları Firebase Firestore'dan çekmek için altyapı hazırlanacak.
