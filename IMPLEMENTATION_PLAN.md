    # Thorium XDR — Plan Implementacji

    > Dokument opisuje architekturę i zakres funkcjonalny systemu Thorium XDR — agenta bezpieczeństwa klasy EDR/XDR/SIEM opartego na Web3. Plan podzielony jest na niezależne segmenty techniczne. Każdy segment może być implementowany równolegle lub sekwencyjnie.

    ---

    ## Segment 1 — Telemetria Niskopoziomowa (Jądro Systemu)

    Warstwa odpowiedzialna za bezpośrednie pozyskiwanie danych z jądra systemu operacyjnego. Stanowi fundament całego systemu — bez rzetelnych danych źródłowych detekcja jest niemożliwa.

    ### 1.1 Monitorowanie Procesów (eBPF — Linux)

    Zamiast odpytywania katalogu `/proc` w cyklach czasowych, agent powinien korzystać z mechanizmu eBPF, który pozwala na asynchroniczne, niskokosztowe przechwytywanie zdarzeń bezpośrednio z jądra.

    - Przechwytywanie zdarzeń uruchamiania procesów: `execve` (syscall lub tracepoint `sched_process_exec`)
    - Rejestrowanie PID, PPID, UID, pełnej ścieżki binarki oraz argumentów wywołania
    - Deduplikacja zdarzeń na poziomie kernela (HashMap eBPF per PID)
    - Wykluczenie szumu: filtrowanie procesów systemowych o niskim ryzyku

    ### 1.2 Telemetria Sieciowa i Zapytań DNS

    Monitorowanie aktywności sieciowej powiązanej z konkretnym procesem na poziomie socketów, a nie interfejsów sieciowych.

    - Przechwytywanie wychodzących połączeń TCP/UDP: kprobe `tcp_v4_connect`, `tcp_v6_connect`
    - Monitorowanie zapytań DNS (UDP 53) w celu wczesnego wykrywania DGA (Domain Generation Algorithms) oraz DNS Tunneling.
    - Rejestrowanie: PID, protokół, adres źródłowy/docelowy (IPv4/IPv6), domena, port
    - Deduplikacja połączeń sieciowych na poziomie kernela (klucz: PID + daddr + dport)
    - Filtrowanie ruchu loopback (`127.x.x.x`, `::1`) jako nieistotnego

    ### 1.3 FIM — Monitorowanie Integralności Plików

    Nasłuchiwanie na zmiany w krytycznych plikach systemowych i konfiguracyjnych w czasie rzeczywistym.

    - Użycie mechanizmu `inotify` lub eBPF `vfs_write` kprobe
    - Monitorowane ścieżki (konfigurowalne): `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, klucze SSH, pliki konfiguracyjne systemd, binaria systemowe
    - Rejestrowanie: ścieżka pliku, PID procesu dokonującego zmiany, typ operacji (zapis, usunięcie, zmiana nazwy), timestamp, hash SHA-256 przed/po
    - Alerty na zmiany poza oknem serwisowym lub przez nieoczekiwane procesy

    ### 1.4 Kontrola Urządzeń Peryferyjnych (DLP / USB)
    Ochrona przed fizycznymi wektorami infekcji i wyciekiem danych.
    - Nasłuch na zdarzenia montowania urządzeń typu Mass Storage (np. integracja z udev).
    - Możliwość wymuszenia trybu Read-Only dla niezaufanych nośników USB lub całkowita blokada dla wybranych grup użytkowników.

    ---

    ## Segment 2 — Silnik Detekcji (Architektura Hybrydowa: Edge + MPC)

    Warstwa analityczna przetwarzająca surowe zdarzenia telemetryczne w ustrukturyzowane alerty bezpieczeństwa. 
    Segment ten został podzielony na **dwie strefy obliczeniowe**, aby uniknąć przeciążenia zasobów monitorowanych endpointów (CPU/RAM).

    ### 2.1 Architektura i Przepływ Danych (Data Flow)

    **Faza 1: Edge Computing (Lokalny Agent Thorium)**
    1. **Przechwycenie (eBPF):** Jądro systemu rejestruje zdarzenie (np. `PROCES_START`, `POŁĄCZENIE`).
    2. **Szybki Cache IoC (L1):** Agent `thorium_agent.mowa` natychmiastowo weryfikuje hash binarki lub adres IP ze swoim lokalnym słownikiem `bezpieczne_hashe` w pamięci RAM.
    3. **Reguły Behawioralne:** Lekkie sprawdzanie wyrażeń regularnych (Regex) np. wzorców `curl | bash` oraz detekcja dostępu do krytycznych plików (FIM, `/etc/shadow`).
    4. **Werdykt Edge:** Jeśli zdarzenie jest ewidentnie złośliwe, proces jest natychmiast ubijany (Zero-Lag Response). Jeśli hash jest czysty i zbuforowany – proces przechodzi dalej. Jeśli hash jest **nieznany**, przechodzimy do Fazy 2.

    **Faza 2: Offloading do Klastra (Magnesium / Polonium / MPC)**
    1. **Wstrzymanie Procesu:** Lokalny agent używa sygnału `SIGSTOP` do zawieszenia nieznanej binarki.
    2. **Asynchroniczny Call RPC:** Agent wywołuje `uruchom_w_tle()`, wysyłając żądanie analizy do węzła w rozproszonym klastrze Magnesium.
    3. **Sandboxing i YARA:** Serwer klastra skanuje binarkę pełnymi, potężnymi regułami YARA, których lokalny host nie uniósłby wydajnościowo.
    4. **Talus AI i Sigma:** Centralny klaster analizuje korelację logów sieciowych i behawioralnych na poziomie Big Data.
    5. **Multi-Party Computation (MPC):** Organizacje kryptograficznie przeliczają wspólny model zaufania, uzgadniając nowy podpis IoC na zero-day malware bez deanonimizacji lokalnych incydentów.
    6. **Werdykt z Klastra:** Klaster asynchronicznie zwraca wynik (ZŁOŚLIWY / BEZPIECZNY). Lokalny agent zabija proces (`SIGKILL`) albo wznawia go (`SIGCONT`), po czym odświeża swój lokalny Cache L1.

    ### 2.2 Zaimplementowane Mechanizmy Edge (Thorium Agent)

    - **Lekka detekcja wzorców:** Błyskawiczne ubijanie procesów powiązanych z ransomware, minerami i popularnymi one-linerami deweloperskimi uzywanymi w atakach.
    - **FIM (File Integrity Monitoring):** Deterministyczna ochrona złotych obrazów i plików konfiguracyjnych systemów.
    - **Micro-Cache IoC:** Dynamiczna tablica bezpiecznych/złośliwych skrótów bez spowalniania maszyny-hosta.

    ### 2.3 Skanowanie Spoczynkowe (On-Demand Sweep)
    Obok aktywnego monitorowania w locie, agent musi pozwalać na zaplanowane skanowanie klasyczne.
    - Okresowe, rekursywne sprawdzanie katalogów podwyższonego ryzyka (np. `/tmp`, katalogi użytkowników) przy użyciu silnika YARA, aby wykryć malware, który został pobrany, ale jeszcze nie uruchomiony.

    ### 2.4 Offloadowane Mechanizmy Klastra (Magnesium MPC)

    - **Silnik YARA:** Skanowanie plików wywoływanych przez `execve` w odizolowanych środowiskach chmurowych (Sandbox) z bazą dziesiątek tysięcy sygnatur z GitHub: Neo23x0/signature-base.
    - **Zaawansowana Sigma:** Agregowanie i parowanie wielu mniejszych, niewinnie wyglądających alertów z różnych hostów w jeden skoordynowany łańcuch ataku (Lateral Movement).
    - **Threat Intelligence Network:** Automatyczne pobieranie list IoC (AlienVault OTX, AbuseCH) oraz weryfikacja nowych wektorów ataku kryptograficznym protokołem rozproszonym MPC.

    ---

    ## Segment 3 — Reakcja na Incydenty (SOAR)

    Warstwa automatycznej odpowiedzi — agent nie tylko wykrywa, ale aktywnie reaguje na zagrożenia zgodnie z predefiniowanymi lub dynamicznie ładowanymi playbookami.

    ### 3.1 Akcje Podstawowe

    Podstawowy zestaw działań naprawczych możliwych do wywołania zarówno ręcznie (z dashboardu), jak i automatycznie przez silnik detekcji.

    - `zabij_proces(pid)` — Natychmiastowe zakończenie procesu przez SIGKILL
    - `izoluj_siec()` — Blokada ruchu sieciowego za pomocą reguł iptables/nftables (z wyjątkiem komunikacji z C2 w celu dalszego zarządzania)
    - `przywroc_siec()` — Cofnięcie izolacji sieciowej
    - `kwarantanna(sciezka)` — Przeniesienie pliku do zaszyfrowanego katalogu kwarantanny (odebranie uprawnień, zmiana właściciela)

    ### 3.2 Silnik Playbooków

    Mechanizm definiowania wieloetapowych procedur reagowania na incydenty (ang. runbooks), uruchamianych automatycznie lub po aprobecie operatora.

    - Format playbooków: plik konfiguracyjny (YAML lub własny DSL)
    - Obsługa warunków: `jeśli alert.poziom == "Krytyczny" && agent.status == "Online"`
    - Obsługa opóźnień: `czekaj(300s)` przed eskalacją akcji
    - Obsługa powiadomień: webhook (Slack, Teams, PagerDuty), e-mail
    - Obsługa oczekiwania na aprobatę operatora (interaktywny SOAR)
    - Przykładowy playbook: `Wykryto malware → Powiadom Slack → Poczekaj 5 min → Jeśli brak odpowiedzi → Izoluj hosta → Zapisz dowody w Walrus`

    ### 3.3 Zarządzanie Dowodami (Forensic Evidence)

    Bezpieczne, odporne na modyfikację przechowywanie dowodów incydentu.

    - Agregacja logów z okna czasowego przed i po incydencie (ring buffer)
    - Obliczanie kryptograficznego skrótu paczki dowodów (SHA-256 lub Blake3)
    - Zapis dowodów w zdecentralizowanym magazynie Walrus (Sui ecosystem)
    - Rejestracja identyfikatora Blob na blockchainie Sui jako dowód niezmienności

    ---

    ## Segment 4 — Korelacja Zdarzeń (XDR)

    Warstwa łącząca zdarzenia z pojedynczego hosta oraz z wielu hostów w spójne incydenty. Odpowiednik funkcji SIEM.

    ### 4.1 Korelacja Lokalna (Single-Host)

    Łączenie pojedynczych alertów z jednej maszyny w logiczne drzewa ataków.

    - Mechanizm czasowego łączenia zdarzeń (`time window correlation`): zdarzenia w oknie 60 sekund dotyczące tego samego PID lub procesu-rodzica
    - Budowanie drzew procesów: wizualizacja łańcucha `parent → child → grandchild` z powiązanymi zdarzeniami sieciowymi i plikowymi
    - Scoring incydentu: suma poziomów ryzyka składowych zdarzeń z wagami
    - Przykład: `anomalne_logowanie(5pkt) + podejrzany_execve(30pkt) + połączenie_z_C2_IoC(50pkt) = INCYDENT Krytyczny (85pkt)`

    ### 4.2 Korelacja Rozproszona (Cross-Device XDR)

    Wykrywanie ataków łańcuchowych przemieszczających się między maszynami w sieci (ang. Lateral Movement, APT Campaigns).

    - Globalny rejestr zdarzeń na blockchainie Sui dostępny dla wszystkich agentów
    - Subskrypcja zdarzeń z innych agentów w tej samej organizacji (Sui Events)
    - Detekcja wzorców wielohostowych: ten sam adres IP atakujący kolejno wiele maszyn, te same hasze plików pojawiające się na wielu hostach w krótkim czasie
    - Agregacja globalnej mapy incydentów z perspektywy całej organizacji

    ### 4.3 Integracja z Tradycyjnym SIEM
    Pomost dla firm posiadających już istniejącą architekturę monitorowania.
    - Natywny zrzut zdarzeń telemetrycznych i incydentów Thorium XDR za pośrednictwem Sysloga (format CEF) lub Webhooków (JSON).
    - Kompatybilność wsteczna pozwalająca przesyłać zdarzenia do Splunk, QRadar lub Elasticsearch.

    ---

    ## Segment 5 — Zarządzanie Podatnościami (CSPM)

    Działania prewencyjne redukujące powierzchnię ataku, niezależne od aktywnego monitorowania.

    ### 5.1 Skanowanie Pakietów pod kątem CVE

    - Pobieranie listy zainstalowanych pakietów z menedżera systemu (DNF/APT/RPM)
    - Porównywanie wersji z bazą NVD (National Vulnerability Database) lub OSV
    - Raportowanie podatności z oceną CVSS (Critical/High/Medium/Low)
    - Cykliczne uruchamianie skanu (domyślnie: raz dziennie)

    ### 5.2 Audyt Konfiguracji (CIS Benchmarks)

    - Weryfikacja kluczowych ustawień hartowania systemu operacyjnego
    - Kontrolowane punkty: wyłączenie logowania root przez SSH, brak pustych haseł, aktywne SELinux/AppArmor, aktualizacje automatyczne, brak otwartych portów bez właściciela
    - Generowanie raportu z punktacją zgodności (np. `72/100 punktów CIS Level 1`)
    - Integracja z dashboardem w formie widoku `Security Posture`

    ---

    ## Segment 6 — Rejestr Tożsamości i C2 (Web3 / Sui)

    Warstwa komunikacji i kontroli agentów, oparta na blockchainie Sui zamiast centralnego serwera C2.

    ### 6.1 Rejestracja Agenta

    - Każdy agent przy pierwszym uruchomieniu generuje lokalnie parę kluczy Ed25519
    - Obliczenie fingerprintu sprzętowego (CPU, RAM, OS) jako unikalnego identyfikatora maszyny
    - Rejestracja agenta w kontrakcie Move na Sui: `(fingerprint, klucz_publiczny, ip, hostname, owner)`
    - Weryfikacja duplikatów: ten sam fingerprint nie może być zarejestrowany dwukrotnie

    ### 6.2 Raportowanie Zdarzeń On-Chain

    - Publikowanie alertów bezpieczeństwa jako transakcje Sui (`zglos_incydent()`)
    - Każde zdarzenie zawiera: hash danych, timestamp, poziom ryzyka, PID, typ ataku
    - Dane szczegółowe zdarzenia przechowywane w Walrus (off-chain), tylko hash on-chain
    - Możliwość weryfikacji integralności zdarzenia przez dowolną stronę trzecią

    ### 6.3 Polityki Bezpieczeństwa On-Chain (Polonium)

    - Kontrakt Move zarządzający regułami organizacyjnymi: które adresy IP są blokowane, które procesy są dozwolone/zabronione, poziomy ryzyka
    - Agenci pobierają polityki przy starcie i subskrybują zmiany w czasie rzeczywistym (Sui Events)
    - Możliwość wydawania rozkazów do agentów przez dashboard: izoluj hosta, zaktualizuj reguły, pobierz logi

    ### 6.4 Multi-Sig Autoryzacja Akcji Krytycznych

    - Akcje nieodwracalne (np. izolacja hosta produkcyjnego) wymagają podpisu N-of-M właścicieli organizacji
    - Implementacja multi-signature na poziomie kontraktu Move
    - Integracja z kluczami sprzętowymi WebAuthn (FIDO2) po stronie dashboardu

    ---

    ## Segment 7 — Dashboard Analityczny (SOC Frontend)

    Graficzny interfejs webowy dla analityków bezpieczeństwa.

    ### 7.1 Panel Główny (Overview)

    - Lista aktywnych agentów z ich statusami (Online/Offline/Izolowany) w czasie rzeczywistym
    - Mapa cieplna aktywności alertów w ostatnich 24 godzinach
    - Liczniki: aktywne incydenty, agenci offline, wykryte IoC, polityki naruszone

    ### 7.2 Widok Hosta (Agent Detail)

    - Dane identyfikacyjne: hostname, IP, OS, wersja agenta, fingerprint, klucz publiczny
    - Metryki zasobów: CPU, RAM, I/O dysku (odświeżane w czasie rzeczywistym przez WebSocket)
    - Historia alertów chronologicznie
    - Akcje dostępne z poziomu UI: Izoluj / Przywróć / Wymuś skan / Pobierz logi

    ### 7.3 Widok Incydentu (Timeline / Forensics)

    - Oś czasu graficzna: zdarzenia sieciowe, procesy i zmiany plików na osi czasu
    - Drzewo procesów interaktywne: rozwijalne węzły z detalami każdego procesu
    - Eksport raportu incydentu do PDF z sygnaturą kryptograficzną (Blake3 hash)

    ### 7.4 Zarządzanie Politykami

    - Edytor reguł Sigma i reguł behawioralnych
    - Zarządzanie listami IoC: import/eksport, dodawanie ręczne, subskrypcje feedów
    - Konfiguracja playbooków SOAR z wizualnym edytorem przepływu
    - Historia zmian polityk z atrybutami: kto zmienił, kiedy, jaka była poprzednia wartość

    ### 7.5 Zarządzanie Flotą (Fleet Management)

    - Deployment agentów na nowe maszyny przez Vagrant / SSH / skrypt instalacyjny
    - Aktualizacja agentów do nowej wersji (rolling update)
    - Grupowanie agentów w segmenty sieciowe (np. `DMZ`, `Serwery Produkcyjne`, `Stacje Robocze`)
    - Reguły polityk przypisywane do grup, a nie do pojedynczych maszyn

    ---

    ## Segment 8 — Technologie Eksperymentalne (R&D)

    Innowacyjne mechanizmy przewidziane do integracji w kolejnych generacjach architektury Thorium, stawiające platformę o krok przed tradycyjnymi rozwiązaniami EDR/XDR.

    ### 8.1 Active Pre-Execution Mitigation (BPF LSM)
    - Zmiana podejścia z reaktywnego (`SIGKILL` po wykryciu) na prewencyjne.
    - Użycie wtyczek *Linux Security Modules* zasilanych przez eBPF do przechwytywania żądań `security_bprm_check_security`.
    - Blokowanie ładowania do pamięci nieznanych lub niebezpiecznych binarek bez generowania wyścigów czasowych (race conditions).

    ### 8.2 Federated Learning (FL) i Zdecentralizowane AI
    - Trening modeli uczenia maszynowego (np. sieci neuronowych detekujących anomalie) bezpośrednio na maszynach brzegowych.
    - Agenci wymieniają się jedynie wagami (gradientami) modelu poprzez blockchain Sui, bez przesyłania ani fragmentu logu w plain-textcie.
    - Ochrona gradientów przez **Microsoft SEAL** (Szyfrowanie Homomorficzne) w celu zapobiegania atakom na model sztucznej inteligencji.

    ### 8.3 Hardware Root of Trust i Atestacja TPM 2.0
    - Kryptograficzne powiązanie tożsamości Agenta bezpośrednio z modułem TPM 2.0 na płycie głównej.
    - Weryfikacja rejestrów PCR w smart kontrakcie na Sui, gwarantująca, że system operacyjny nie został zainfekowany bootkitem przed załadowaniem Agenta (tzw. Remote Attestation).

    ### 8.4 ZTNA (Zero Trust Network Access) via eBPF
    - Wbudowanie mikro-firewalla bezpośrednio w jądro (XDP/eBPF) filtrującego pakiety nie tylko po IP, ale po weryfikowalnej tożsamości Web3.
    - Każdy strumień TCP musi posiadać zaszyfrowany token autoryzacyjny (np. mTLS lub sygnaturę Sui), w przeciwnym razie eBPF upuszcza pakiet w warstwie sieciowej, czyniąc maszynę niewidoczną dla skanerów.

    ### 8.5 Automated Memory Forensics (Walrus Dump)
    - Automatyczne wyzwalanie snapshotów mapy pamięci RAM po zawieszeniu procesu sygnałem `SIGSTOP`.
    - Integracja analizy heurystycznej (odpowiednik frameworka Volatility) i zamrażanie surowych zrzutów heap/stack bezpośrednio w zdecentralizowanej pamięci Walrus dla audytorów.

    ### 8.6 PQC (Post-Quantum Cryptography)
    - Zabezpieczenie danych telemetrycznych i logów audytowych przesyłanych do Walrus przed atakami kwantowymi wariantu "Harvest Now, Decrypt Later".
    - *Uwaga: Wdrożenie standardów kryptografii postkwantowej (NIST) w architekturze Thorium zakłada płynne dziedziczenie tej funkcjonalności, w miarę jak sam blockchain Sui będzie natywnie rozwijał obsługę PQC.*

    ### 8.7 Prawdziwe Zmylenie (eBPF Kernel Honeytokens)
    - Zintegrowanie agenta z koncepcją sieci Honeypot, ale realizowaną całkowicie wewnątrz jednego endpointu na poziomie jądra.
    - Agent symuluje obecność niezabezpieczonych kluczy SSH, baz danych lub ścieżek sieciowych. Programy skanujące intruza (np. LinPEAS, BloodHound) uruchamiają fałszywe tokeny, gwarantując 100% precyzję wykrycia intruza (zero false-positives).

    ### 8.8 DAIR (Decentralized Autonomous Incident Response)
    - Przeniesienie funkcji analityka pierwszego kontaktu (Tier 1 SOC) na inteligentne kontrakty działające na łańcuchu.
    - Smart Kontrakt (Polonium) agreguje zdarzenia w locie i na podstawie weryfikacji Multi-Party w klastrze samodzielnie egzekwuje akcje SOAR (uruchomienie firewalla, zabicie PIDs), redukując czas odpowiedzi (MTTR) do milisekund.

    ### 8.9 Spatial SOC (Wizualizacja Kill-Chain w 3D)
    - Integracja panelu WebUI z trójwymiarowymi grafami topologii środowiska rozproszonego.
    - Mapowanie wektorów ruchu bocznego (Lateral Movement) na przestrzenny diagram MITRE ATT&CK.
    - Wykorzystanie unikalnej integracji silnika Mowa z renderowaniem zasobów `.glb` (GL Transmission Format). Skrypty Mowa mogłyby w locie manipulować wierzchołkami obiektów 3D reprezentujących zarażone węzły i emitować te modele prosto na frontend analityka.

    ### 8.10 Deklaratywny DSL Bezpieczeństwa w Języku Mowa
    - Rozszerzenie rdzenia języka Mowa o specjalną składnię ułatwiającą definiowanie polityk bezpieczeństwa (Domain Specific Language).
    - Zamiast żmudnego parsowania plików zewnętrznych (YARA/Sigma), analityk definiuje zachowanie systemu za pomocą czytelnych polskich instrukcji, np.: `reguła "Ransomware" kiedy vfs.plik_zmieniony i sciezka_zawiera(".enc") => kwarantanna(pid)`. 

    ### 8.11 Natywna Kompilacja JIT Mowa -> eBPF Bytecode
    - Obecnie Mowa funkcjonuje w trybie User-Space, reagując na sygnały wysyłane z kernela.
    - Opracowanie warstwy tłumaczącej proste playbooki napisane w Mowie (np. blokady IP, filtrowanie portów) bezpośrednio na kod maszynowy eBPF. Taki kod byłby wstrzykiwany prosto do jądra Linuxa (Ring-0), co zagwarantowałoby natywną wydajność C/Rust z użyciem prostej polskiej składni.

    ### 8.12 Wbudowana Orkiestracja "Mesh" (Zdalne Wywołania)
    - Rozbudowa wbudowanych funkcji środowiska Mowa o natywną komunikację między-agentową (P2P), omijając nawet C2.
    - Instrukcje takie jak `niech logi = zdalne_wykonanie(id_agenta_B, funkcja_analizy)` pozwalałyby agentom na dynamiczną "rozmowę" i koordynację defensywy bezpośrednio ze skryptu roboczego Mowy bez infrastruktury pośredniczącej.

    ---

    ## Segment 9 — Funkcjonalności Korporacyjne (Enterprise Readiness)

    Kluczowe "nudne", lecz bezwzględnie wymagane przez rynek mechanizmy przed wdrożeniem komercyjnym na serwery i stacje robocze instytucji finansowych, korporacji i rządów.

    ### 9.1 Niezawodny Agent Auto-Updater (A/B Partitions)
    - Wbudowany w agenta kanał do tzw. *silent updates* binarek i reguł konfiguracyjnych Mowy.
    - Każda paczka walidowana przez podpis Ed25519 przed zrzutowaniem na dysk.
    - Podejście A/B (znane z Androida/ChromeOS): nowa wersja ładuje się na "zapasową partycję". W razie wystąpienia kernel panic po aktualizacji modułów eBPF, Watchdog odzyskuje stabilny system ze snapshotu.

    ### 9.2 Wewnętrzne Logi Audytowe (Analyst Audit Trails)
    - Mechanizm ochrony przed złośliwymi administratorami (Insider Threat).
    - Zapis on-chain (na blockchainie Sui jako log transakcyjny) każdej krytycznej operacji wykonanej w dashboardzie SOC: logowanie, odizolowanie systemu, zamknięcie alertu, czy pobranie logów (naruszenie prywatności).

    ### 9.3 Dark Mode / Offline Lockdown
    - Samoczynny, agresywny mechanizm zapasowy w przypadku przerwania połączenia internetowego lub kablowego (np. izolacja kabla przez malware).
    - Detekcja odcięcia od C2 (Sui) i automatyczne zaostrzenie lokalnych polityk do poziomu paranoicznego: blokowanie powoływania nieznanych child-procesów, blokowanie logowań konsolowych i buforowanie zaszyfrowanych dowodów śledczych do czasu powrotu połączenia.

    ### 9.4 Integracja z zewnętrznymi systemami ITSM (REST API)
    - Wystawienie w pełni udokumentowanego API (OpenAPI/Swagger).
    - Możliwość dwukierunkowej komunikacji dla zewnętrznych systemów biletowych (Jira Service Management, ServiceNow, PagerDuty). Zmiana statusu incydentu w Jirze automatycznie rozwiązuje i zamyka alarm w sieci Thorium.

    ### 9.5 Integracja Tożsamości (Active Directory / Okta / LDAP)
    - Surowe `uid` i `gid` dostarczane z eBPF nie wystarczą analitykowi. 
    - Integracja z usługami katalogowymi, by podczas wyświetlania Drzewa Procesów, Thorium mapował proces `jakub` natychmiastowo na "Jakub Nowak, Dział Bezpieczeństwa (VIP)".

    ### 9.6 Live Terminal (Web-based Remote Shell for DFIR)
    - Bezpieczny, w pełni audytowalny interaktywny terminal CLI osadzony w przeglądarce analityka SOC.
    - Pozwala specjalistom Digital Forensics (DFIR) na wejście do wyizolowanej stacji (np. za pomocą dedykowanych komend wysyłanych rurą WebSockets / P2P) w celu poszukiwania żywych artefaktów złośliwego oprogramowania, nie przerywając kwarantanny sieciowej maszyny.

    ---

    ## Segment 10 — Zaawansowana Analityka Tożsamości i Sieci (UEBA & NDR)

    Gromadzenie surowych logów (procesy, pliki) to dopiero początek. System XDR najwyższej klasy musi rozumieć kontekst tożsamości oraz anomalie w ruchu sieciowym na dużą skalę.

    ### 10.1 UEBA (User and Entity Behavior Analytics)
    - Profilowanie zachowań użytkowników i kont serwisowych z użyciem modeli statystycznych i AI.
    - System uczy się, w jakich godzinach pracują pracownicy i jakich narzędzi używają (tzw. "Baseline").
    - Jeżeli użytkownik `jakub` (który zazwyczaj używa tylko przeglądarki i IDE) nagle uruchamia `nmap` w środku nocy lub próbuje odczytać `/etc/shadow`, system generuje natychmiastowy alert o anomalii tożsamości, nawet jeśli samo polecenie nie figuruje w czarnej liście YARA.

    ### 10.2 NDR (Network Detection and Response)
    - Pogłębiona agregacja meta-danych o ruchu sieciowym poza zwykłym logowaniem adresów IP.
    - Wykrywanie zjawisk takich jak: *Beaconing* (regularne pakiety do tego samego serwera charakterystyczne dla serwerów C2), *Data Exfiltration* (nagły transfer gigabajtów danych na dziwny port) oraz *DGA* (odpytywanie setek losowo wygenerowanych domen w poszukiwaniu żywego C2).
    - Mapowanie ruchu sieciowego w grafy w celu wykrywania tunelowania ukrytego w z pozoru zwykłym ruchu HTTPS.

    ### 10.3 Pasywne Wykrywanie Urządzeń (Shadow IT / Network Discovery)
    - Odpowiednik funkcji Device Discovery z Microsoft Defender.
    - Agenci nasłuchują pasywnie na ruch rozgłoszeniowy (ARP, DHCP, mDNS) w sieciach LAN, identyfikując urządzenia (drukarki, telefony, serwery BYOD), na których nie ma zainstalowanego agenta Thorium, co zapobiega rozrostowi tzw. *Shadow IT*.

    ### 10.4 Integracja z Globalnym Threat Intel (STIX/TAXII & MISP)
    - Zasilanie bazy IoC (Indicator of Compromise) zewnętrznymi danymi wywiadowczymi.
    - Oprócz natywnej korelacji P2P na Sui, węzły klastra potrafią zasysać miliony sygnatur z rządowych i komercyjnych feedów (jak MISP czy OpenCTI) wykorzystując standard STIX/TAXII.

    ### 10.5 eBPF TLS/SSL Uprobes (Alternatywa dla Zscaler SWG)
    - Zastąpienie ciężkich, inwazyjnych rozwiązań SASE/SWG. Thorium wstrzykuje *uprobes* bezpośrednio do bibliotek przestrzeni użytkownika (OpenSSL, GnuTLS).
    - Pozwala to na pełną analizę zapytań HTTP/HTTPS (adresy URL, nagłówki, zapytania do chmury CASB) *zanim* zostaną zaszyfrowane przez przeglądarkę lub aplikację, co omija potrzebę instalacji fałszywych certyfikatów MITM.
    - Zainstalowanie agenta na głównym routerze Linux (Edge Gateway) automatycznie rozszerza tę inspekcję TLS (Clear-text visibility) na wszystkie urządzenia sieciowe za nim, zachowując minimalny narzut wydajnościowy eBPF.

    ---

    ## Segment 11 — Prywatność Telemetrii (Zero-Knowledge Proofs)

    Aby zachować absolutną prywatność danych bez obciążania stacji końcowych ciężką kryptografią asymetryczną, Thorium wykorzysta hybrydowy model ZK (Zero-Knowledge).

    ### 11.1 Lekkie Zobowiązania na stacji (Endpoint Commitments)
    - Stacja końcowa (Agent) **nie generuje** ciężkich dowodów ZK-SNARK/STARK. To zajęłoby zbyt dużo cykli CPU.
    - Agent stosuje jedynie błyskawiczne Zobowiązania Pedersena (Pedersen Commitments) oraz szybkie szyfrowanie symetryczne (np. AES-GCM lub ChaCha20) dla każdego logu.
    - Do klastra wysyłany jest zaszyfrowany log + krótki hash (zobowiązanie), co kosztuje agenta zaledwie mikrosekundy.

    ### 11.2 Ciężka Generacja ZKP w Chmurze (Magnesium Cluster)
    - To węzły Magnesium MPC (wyposażone w akceleratory GPU/FPGA) przejmują cały ciężar obliczeniowy.
    - Używając technologii takich jak *RISC Zero* (ZK-VM), Magnesium wykonuje skanowanie YARA/Sigma na zaszyfrowanym strumieniu.
    - Magnesium generuje twardy matematycznie dowód (Zero-Knowledge Proof), oświadczający: *"Ten zaszyfrowany log zawiera sygnaturę ransomware, co udowadniamy tym certyfikatem SNARK, ale nie wiemy, jaki to był plik ani jaki użytkownik go otworzył"*.

    ### 11.3 Warunkowa Dekryptacja (SOC Admin)
    - ZK-Proof trafia na blockchain Sui i wyzwala alarm na dashboardzie (Smart Contract zgadza się na akcję SOAR, bo matematyka dowodu ZKP jest poprawna).
    - Analityk SOC (posiadający fizyczny klucz prywatny w portfelu sprzętowym) może opcjonalnie zdekodować log, aby poznać dokładną nazwę pliku i kontekst użytkownika. Jeśli incydent to fałszywy alarm, dane wrażliwe pracownika nigdy nie opuściły formy zaszyfrowanej.

    ### 11.4 Selective Disclosure (Delegowanie Analitykom Zewnętrznym)
    - W sytuacji braku kompetencji in-house, w pełni zdekodowany log może zostać wysłany do zewnętrznego freelancera / analityka Tier-3.
    - Oprogramowanie generuje dowód ZK udowadniający autentyczność logu z sygnatury Walrus, ale **zaciemniający wybrane pola** (np. wymazuje `user="jakub.ceo"` oraz `ip="10.0.1.5"` pozostawiając jawny jedynie payload wirusa).
    - Zewnętrzny ekspert otrzymuje pewność, że log jest autentycznym zapisem z prawdziwej stacji klienta, ale nie wie z jakiej i kogo dotyczy (tzw. ZK Selective Disclosure).

    ---

    ## Segment 12 — Moduł Hydrogen (Zero-Password PAM & Identity)

    Aby zagwarantować pełne bezpieczeństwo ekosystemu, trzeba zacząć od fizycznego dostępu do samej maszyny klienta. Hasła tekstowe to najsłabsze ogniwo.

    ### 12.1 Logowanie Kluczem Sprzętowym (Sui Wallets / FIDO2)
    - Stworzenie własnego modułu uwierzytelniania *PAM (Pluggable Authentication Module)*.
    - Zastąpienie monitu o hasło do konta systemu operacyjnego (Linux/macOS/Windows) żądaniem fizycznej interakcji z kluczem sprzętowym YubiKey lub sprzętowym portfelem kryptograficznym Sui.
    - Brak haseł w pamięci RAM gwarantuje całkowitą odporność na Keyloggery i ataki Phishingowe.

    ### 12.2 Restrykcyjny Tryb IdP (Okta / Google / Entra)
    - Możliwość integracji z globalnymi dostawcami tożsamości z jednym żelaznym zastrzeżeniem.
    - Moduł Hydrogen dopuści logowanie za pomocą konta Google/Entra/Okta do komputera stacjonarnego *wyłącznie* wtedy, gdy to konto posiada twardo przypisany wymóg logowania przez sprzętowy token WebAuthn.
    - Każde logowanie to niezależny, kryptograficzny podpis weryfikowany w tle przez agenta Thorium.

    ### 12.3 Zarządzanie Cyklem Życia Kluczy (Key Provisioning)
    - **Lokalne parowanie:** Możliwość fizycznego dodania klucza przez pracownika bezpośrednio na nowej maszynie przy pomocy wbudowanego polecenia Agenta (np. `thorium-cli hydrogen --enroll`).
    - **Zdalna dystrybucja (Blockchain):** Dla wdrożonych już maszyn (np. 1000 stacji roboczych), administrator SOC rejestruje adresy publiczne nowych kluczy w smart-kontrakcie na Sui. Agenci automatycznie synchronizują te zmiany, aktualizując lokalne zasady dostępu, co pozwala na zdalne "odcinanie" lub dodawanie dostępu bez dotykania maszyn.

    ---

    ## Diagram Architektury

    ```
    ┌──────────────────────────────────────────────────────┐
    │                   HOST ENDPOINT                      │
    │                                                      │
    │  ┌──────────────┐          ┌────────────────────┐    │
    │  │ Hydrogen PAM │          │   Thorium Agent    │    │
    │  │ (FIDO2/IdP)  │          │                    │    │
    │  └──────┬───────┘          │  ┌──────────────┐  │    │
    │         │                  │  │ Silnik Detekcji│  │    │
    │  ┌──────▼───────┐   eBPF   │  │ YARA/Sigma   │  │    │
    │  │  Linux Kernel│ ───────► │  │ IoC / Reguły │  │    │
    │  │  (syscalls,  │  events  │  └──────────────┘  │    │
    │                             │  │ IoC / Reguły │  │   │
    │                             │  └──────────────┘  │   │
    │                             │  ┌──────────────┐  │   │
    │                             │  │ SOAR Engine  │  │   │
    │                             │  │ Playbooki    │  │   │
    │                             │  └──────────────┘  │   │
    │                             │  ┌──────────────┐  │   │
    │                             │  │ HTTP API     │  │   │
    │                             │  │ :9090 / WS   │  │   │
    │                             │  └──────────────┘  │   │
    │                             └────────────────────┘   │
    └──────────────────────────────────────┬───────────────┘
                                        │ HTTPS / WSS
                        ┌──────────────────▼───────────────┐
                        │        SUI BLOCKCHAIN (C2)        │
                        │  Kontrakt Rejestracji Agentów     │
                        │  Polityki (Polonium)               │
                        │  Rejestr Incydentów               │
                        │  Walrus (dowody forensyczne)      │
                        └──────────────────┬───────────────┘
                                        │
                        ┌──────────────────▼───────────────┐
                        │        SOC DASHBOARD (Svelte)    │
                        │  Panel Agentów / Incydentów       │
                        │  Timeline / Forensics             │
                        │  Zarządzanie Politykami           │
                        │  Fleet Management                 │
                        └──────────────────────────────────┘
    ```

    ---

    ## Priorytety Implementacji

    | Status       | Priorytet   | Segment                      | Uzasadnienie                                |
    | ------------ | ----------- | ---------------------------- | ------------------------------------------- |
    | ✅ Gotowe     | 🔴 Krytyczny | 1.1 — eBPF Procesy           | Fundament — bez tego brak rzetelnych danych |
    | ✅ Gotowe     | 🔴 Krytyczny | 1.2 — Telemetria Sieciowa    | Większość ataków wymaga sieci               |
    | ✅ Gotowe     | 🟠 Wysoki    | 2.1 — Reguły Behawioralne    | Pierwsza linia detekcji                     |
    | ✅ Gotowe     | 🟠 Wysoki    | 3.1 — Akcje Podstawowe       | Możliwość reagowania                        |
    | ✅ Gotowe     | 🟠 Wysoki    | 6.1–6.2 — Rejestracja i C2   | Zarządzanie flotą                           |
    | ✅ Gotowe     | 🟡 Średni    | 1.3 — FIM                    | Detekcja persistence                        |
    | ⚪ Oczekujące | 🟡 Średni    | 2.2 — YARA                   | Detekcja złośliwego kodu                    |
    | ✅ Gotowe     | 🟡 Średni    | 4.1 — Korelacja Lokalna      | Redukcja szumu alertów                      |
    | ⚪ Oczekujące | 🟡 Średni    | 7.1–7.3 — Dashboard          | Użyteczność dla analityka                   |
    | ⚪ Oczekujące | 🟢 Niski     | 2.3 — Sigma                  | Gotowe reguły społecznościowe               |
    | ⚪ Oczekujące | 🟢 Niski     | 2.4 — IoC                    | Uzupełnienie detekcji                       |
    | ✅ Gotowe     | 🟢 Niski     | 3.2 — Playbooki SOAR         | Automatyzacja reagowania                    |
    | ⚪ Oczekujące | 🟢 Niski     | 4.2 — Cross-Device XDR       | Zaawansowana korelacja                      |
    | ⚪ Oczekujące | 🟢 Niski     | 5.1–5.2 — CSPM/CVE           | Prewencja                                   |
    | ✅ Gotowe     | 🟢 Niski     | 6.3–6.4 — Polityki Multi-Sig | Zaawansowane zarządzanie                    |

    ---

    ## Ewolucja Post-Deweloperska (Faza Produkcyjna)

    ### Mechanizm Self-Defense Agenta (Hardened)

    Agent musi być odporny na próby dezaktywacji przez złośliwe oprogramowanie (np. ransomware typowo wyłącza agenty bezpieczeństwa jako pierwszy krok). Mechanizm ten zostaje wdrożony dopiero w końcowej fazie, by nie blokować procesu deweloperskiego:

    - Ochrona przed `SIGKILL` z nieautoryzowanych procesów (mechanizm `CAP_SYS_PTRACE` lub twardy eBPF LSM hook odmawiający dostępu EPERM)
    - Watchdog: proces nadzorujący systemd / niezależny deamon restartujący agenta po awarii
    - Mechanizm uniemożliwiający usunięcie samej binarki agenta (chattr +i lub fpolicy)
