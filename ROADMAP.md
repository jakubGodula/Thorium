# Thorium XDR - Mapa Implementacji (Roadmap)

Dokument opisuje plan rozwoju agenta Thorium XDR w celu przekształcenia go w pełnoprawną konkurencję dla komercyjnych rozwiązań klasy EDR/XDR i SIEM (jak Microsoft Defender XDR / Sentinel), ze szczególnym uwzględnieniem unikalnej architektury opartej na Web3 (Sui, Walrus).

## Faza 1: Niskopoziomowa Telemetria i Niezawodność (Fundament EDR)

Obecnie Thorium opiera się na podstawowym śledzeniu procesów. Celem Fazy 1 jest integracja z jądrem systemu operacyjnego w celu uzyskania precyzyjnych i trudnych do zafałszowania danych.

- [ ] **Wdrożenie eBPF (Linux):** Przejście z parsowania katalogów systemowych (`/proc`) na eBPF dla monitorowania wywołań systemowych (syscalls) w czasie rzeczywistym.
- [ ] **Telemetria Sieciowa (Network Telemetry):** Monitorowanie na poziomie socketów sieciowych powiązanych z konkretnym procesem (kierunek, porty, IP).
- [ ] **FIM (File Integrity Monitoring):** Moduł nasłuchujący na zmiany w krytycznych plikach konfiguracyjnych i systemowych (np. `/etc/passwd`, klucze SSH, pliki binarne systemd).
- [ ] **Mechanizm Self-Defense:** Ochrona procesu agenta przed zamknięciem przez nieautoryzowane procesy (np. ransomware).

## Faza 2: Zaawansowany Silnik Detekcji (Inteligencja XDR)

Zastąpienie statycznych wyrażeń regularnych standardowymi w branży silnikami detekcji i uczeniem behawioralnym.

- [ ] **Integracja silnika YARA:** Możliwość ładowania złośliwych sygnatur i skanowania plików na dysku oraz w pamięci podręcznej.
- [ ] **Wsparcie dla reguł Sigma:** Implementacja formatu Sigma pozwalająca na korzystanie z tysięcy gotowych, otwartoźródłowych reguł społecznościowych dotyczących logów i zachowań w systemie.
- [ ] **Moduł Threat Intelligence (IoC):** Mechanizm cyklicznego pobierania aktualnych list IoC (Indicators of Compromise - złe adresy IP, hashe plików) i automatycznego weryfikowania z nimi ruchu sieciowego i plików na hoście.
- [ ] **Moduł Aluminum (Email Analysis):** Silnik analityczny podpięty pod skrzynki pocztowe (Microsoft 365 / Google Workspace) automatycznie wychwytujący i analizujący próby phishingu oraz złośliwe załączniki.

## Faza 3: Automatyzacja, SOAR i XDR (Odpowiednik Sentinela)

Rozbudowa logiki C2 na Sui, umożliwiająca korelacje zdarzeń i tworzenie zaawansowanych polityk odpowiedzi na incydenty.

- [ ] **Korelacja Zdarzeń (Attack Trees):** Łączenie pojedynczych alertów w spójny incydent (np. anomalia logowania + podejrzany proces tworzą jeden incydent "Krytyczny").
- [ ] **Silnik Playbooków (SOAR):** Możliwość tworzenia skryptów (np. w języku Mowa), które definiują elastyczne kroki reakcji (np. najpierw wyślij webhook/Slack, poproś o aprobatę, jeśli brak odpowiedzi w 5 minut – odizoluj hosta).
- [ ] **Zdecentralizowana Analityka (Cross-Device XDR):** Wykorzystanie globalnego rejestru zdarzeń na Web3 (Sui/Walrus) do wykrywania ataków łańcuchowych rozprzestrzeniających się między maszynami w różnych podsieciach.

## Faza 4: Monitorowanie Podatności (CSPM / Vulnerability Management)

Działania prewencyjne minimalizujące ryzyko ataku.

- [ ] **Skanowanie pakietów:** Okresowe sprawdzanie zainstalowanego oprogramowania (np. używając Menedżerów pakietów DNF/APT) pod kątem znanych baz CVE (Common Vulnerabilities and Exposures).
- [ ] **Audyt konfiguracji (CIS Benchmarks):** Skrypt weryfikujący podstawowe utwardzenie systemu operacyjnego (np. czy logowanie root przez SSH jest wyłączone, polityki haseł).

## Faza 5: C2 Dashboard i Użyteczność (SOC Frontend)

Zbudowanie przejrzystego panelu dla analityków bezpieczeństwa, aby narzędzie było praktyczne w codziennej pracy.

- [ ] **Interfejs Svelte UI:** Rozbudowa katalogu `/ui` do pełnoprawnego pulpitu nasłuchującego na eventy z blockchaina Sui.
- [ ] **Widok Timeline:** Graficzna oś czasu procesów i sieci dla łatwego analizowania przebiegu infekcji (Forensics).
- [ ] **Zarządzanie Flotą:** Widok wszystkich wdrożonych agentów, ich aktualnych statusów, kluczy kryptograficznych oraz możliwość ręcznego egzekwowania reguł zziolowania lub zablokowania IP z poziomu interfejsu przeglądarki.

## Faza 6: Enterprise Readiness & Zero-Trust IAM

Mechanizmy korporacyjne umożliwiające sprzedaż systemu dla największych graczy rynkowych (model MSSP i korporacyjny).

- [ ] **Moduł Hydrogen (PAM & Zero-Password):** Zastąpienie haseł jądra systemowego (Linux PAM) autoryzacją za pomocą portfeli sprzętowych i FIDO2, wymuszające fizyczny "dotyk" przy odblokowaniu maszyny.
- [ ] **Własny Interfejs GUI (Mowa):** Natywna graficzna aplikacja z menedżerem kluczy pozwalająca na parowanie kluczy sprzętowych pracowników oraz synchronizację z systemem tożsamości Sui On-Chain.
- [ ] **Integracja ITSM i Auto-Updater:** Wysyłanie ticketów do ServiceNow/Jira oraz mechanizm nieprzerwanego, bezpiecznego samoaktualizowania agenta.
- [ ] **Offline Lockdown (Dark Mode):** Tryb paranoiczny odcinający komunikację, z buforowaniem dowodów w bezpiecznej enklawie po zerwaniu połączenia z siecią dowodzenia (C2).

## Faza 7: Prywatność Telemetrii (Zero-Knowledge Proofs) i R&D

Gwarancja absolutnej prywatności dla firm i pracowników (100% zgodności z RODO/GDPR), przy zachowaniu mocy analizy detekcyjnej.

- [ ] **Zero-Knowledge Telemetry (ZKP):** Wykorzystanie "Zobowiązań Pedersena" na maszynie brzegowej (ekstremalnie szybkich) i oddelegowanie generowania ciężkich dowodów ZK-SNARK o weryfikacji zagrożenia do klastra obliczeniowego (Magnesium).
- [ ] **Selective Disclosure (Delegowanie Analitykom):** Opcja udostępniania autentycznych (kryptograficznie zweryfikowanych) logów zewnętrznym analitykom Tier-3 z zasłonięciem wrażliwych danych osobowych (IP, Nazwa konta) bez przerywania dowodu autentyczności sygnatury Walrus.

## Faza 8: Ekosystem Rozszerzony (Extended XDR Suite)

Budowa potężnych, w pełni wyposażonych filarów komplementarnych do Thorium, aby stworzyć kompletny produkt do walki z każdym wektorem zagrożeń.

- [ ] **Moduł Lithium (Cloud Native Security):** eBPF jako K8s Admission Controller oraz izolowana analityka ucieczek z kontenerów (Container Escapes) do jądra hosta.
- [ ] **Moduł Neon (NDR & SSL Inspection):** Uprobes w eBPF zapinające się na OpenSSL/BoringSSL w celu deszyfrowania i analizowania zagrożeń typu C2 beaconing w pamięci RAM, przed szyfrowaniem HTTPS.
- [ ] **Moduł Xenon (Deception / Honeypoty):** Wstrzykiwanie w pamięć i dysk fałszywych poświadczeń oraz pułapek na intruzów z 0% False Positive rate.
- [ ] **Moduł Silicon (AI Behavior Analytics - UEBA):** Zintegrowane, lokalne uczyenie maszynowe do behawioralnego profilowania zachowań i zapobiegania użyciu skradzionych danych uwierzytelniających.
- [ ] **Moduł Titanium (Data Loss Prevention - DLP):** Monitorowanie wektorów wycieku danych (schowek, drukarki, exfiltracja do chmury) wykorzystujące wzorce PII (karty kredytowe, PESEL).
