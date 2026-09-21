# 💪 Aplikace pro Silový Trénink (iOS SwiftUI & PWA)

Kompletní aplikace pro záznam a plánování silového tréninku s podporou progresivního přetížení (+2.5 kg), jednotlivých vah pro každou sérii, dynamických tréninkových dnů (A, B, C...) a 100% offline režimem.

Aplikace je dostupná ve dvou variantách:
1. **PWA (Progressive Web App)** – Určená pro okamžité spuštění na iPhonu (i v prohlížeči Firefox / Safari) bez nutnosti instalace přes App Store či Mac.
2. **Nativní iOS kód (Swift / SwiftUI)** – Modulární architektura pro Xcode a macOS.

---

## 📱 PWA Verze (Pro iPhone & Android & PC)

Všechny soubory se nachází ve složce [`pwa/`](file:///c:/Users/Tom%C3%ADk/Documents/Projekty/Fitnes/pwa).

### Hlavní funkce:
- **Správa tréninkových dnů**: Možnost vytvářet (+ Přidat den), přejmenovávat, upravovat zaměření i mazat libovolné tréninkové dny (Trénink A, B, C, D...).
- **Váhy pro každou sérii zvlášť**: Každá série má vlastní nastavení hmotnosti v kg (např. série 1: 12.5 kg, série 2: 15.0 kg, série 3: 17.5 kg) a počtu opakování.
- **Progresivní přetížení (Overload)**: Jakmile odcvičíte a odškrtnete všechny série daného cviku, aplikace vám automaticky nabídne navýšení o +2.5 kg (nebo libovolný krok) do dalšího tréninku.
- **100% Offline fungování**: Díky Service Workeru a `localStorage` funguje aplikace v telefonu i v posilovně bez internetu a bez zapnutého PC.
- **Striktně textový a čistý design**: Žádné obrázky ani rušivé elementy, rychlé a přehledné ovládání s velkými dotykovými tlačítky.
- **Sdílení tréninku**: Jedním kliknutím vygenerujete textový rozpis pro kamaráda nebo do poznámek.

### 🚀 Spuštění PWA na iPhonu:
1. Spusťte soubor **`spustit_pwa.bat`**.
2. Na iPhonu (ve stejné Wi-Fi síti) otevřete prohlížeč (Firefox nebo Safari) a zadejte zobrazenou IP adresu (např. `http://172.20.10.5:8080`).
3. Přidejte si aplikaci na plochu telefonu (PWA).

---

## 📂 Struktura Projektu

```
Fitnes/
├── pwa/                              # PWA Webová aplikace (HTML5, CSS3, JS, Service Worker)
│   ├── index.html                    # Uživatelské rozhraní
│   ├── styles.css                    # Responzivní iOS Dark/Light typografický styl
│   ├── app.js                        # Aplikační logika, perzistence, progresivní overload
│   ├── sw.js                         # Offline Service Worker cache
│   ├── manifest.json                 # PWA manifest
│   └── exercises.json                # Databáze silových cviků
├── spustit_pwa.bat                   # 1-click skript pro spuštění lokálního serveru
├── FitnessApp.swift                  # Hlavní vstupní bod SwiftUI aplikace (@main)
├── Models/                           # Datové modely (WorkoutItem, DatabaseExercise, WorkoutDay)
├── Services/                         # Služby pro čtení JSON a perzistentní ukládání
├── ViewModels/                       # Stavová logika a ViewModel
├── Views/                            # SwiftUI pohledy a komponenty
└── Resources/
    └── exercises.json                # Předpřipravená databáze cviků pro iOS
```

---

## 🛠️ Nasazení do Xcode (Nativní iOS aplikace)

1. Otevřete **Xcode** a zvolte **Create New Project** -> **iOS App** -> **SwiftUI** -> **Swift**.
2. Pojmenujte projekt např. `Fitnes`.
3. Přetáhněte složky `Models`, `Services`, `ViewModels`, `Views`, `Resources` a soubor `FitnessApp.swift` do projektu v Xcode.
4. Ujistěte se, že `exercises.json` je zaškrtnutý v **Target Membership**.
5. Spusťte na simulátoru nebo reálném iOS zařízení s iOS 16.0+.

