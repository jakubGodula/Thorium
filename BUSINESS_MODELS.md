# Thorium XDR — Modele Biznesowe

Rozwiązanie Thorium XDR, ze względu na swoją hybrydową, zdecentralizowaną naturę (Web3, Sui, Walrus) oraz zaawansowane mechanizmy detekcji brzegowej, stwarza unikalne możliwości komercjalizacji. Poniżej przedstawiono przykładowe modele biznesowe.

---

## 1. Model B2B SaaS (Zdecentralizowany XDR)

Klasyczny model subskrypcyjny B2B, w którym organizacje płacą za ochronę swoich endpointów, ale z kluczową przewagą nad konkurencją (np. CrowdStrike, SentinelOne) w postaci prywatności i suwerenności danych.

* **Sposób licencjonowania:** Opłata miesięczna/roczna per Agent (Endpoint) + ew. opłata za transfer dowodów do sieci Walrus.
* **Grupa docelowa:** Średnie i duże przedsiębiorstwa, instytucje finansowe, branża medyczna.
* **Propozycja Wartości (USP):**
  * Brak jednego centralnego punktu awarii (C2 na blockchainie Sui).
  * Dane telemetryczne nie są wysyłane do chmury dostawcy (edge computing) – chroni to prywatność firmy.
  * Pełna transparentność i korelacja rozproszona, bez uzależnienia od jednej firmy.
  * Wsteczna kompatybilność – możliwość zrzucania logów do istniejących już w firmie klastrów SIEM (Splunk, QRadar) przez format CEF/Syslog.
  * Natywne uwierzytelnianie Zero-Password (Hydrogen) – rozwiązanie działa nie tylko jako XDR, ale całkowicie zabezpiecza lokalny dostęp do maszyn (Linux PAM) kluczami sprzętowymi.

## 2. Model MSSP (Managed Security Service Provider)

Sprzedaż Thorium XDR do firm zewnętrznych świadczących usługi cyberbezpieczeństwa (SOC as a Service) dla mniejszych podmiotów.

* **Sposób licencjonowania:** Pakiety (np. dla 500, 1000, 5000 agentów) ze zniżką hurtową (White-labeling UI Polonium).
* **Grupa docelowa:** Firmy wdrażające IT i lokalne firmy cybersecurity obsługujące rynek SME.
* **Propozycja Wartości (USP):**
  * MSSP otrzymuje potężne narzędzie (SIEM, EDR, SOAR) w jednym pakiecie.
  * Inteligentna korelacja rozproszona (Sui Events) pozwala MSSP zablokować atak na firmie X, zanim dotrze on do firmy Y, ponieważ heurystyka rozchodzi się siecią P2P.
  * Minimalne zapotrzebowanie na infrastrukturę centralną (Sui i Walrus przyjmują obciążenie).
  * Możliwość bezinwazyjnego wpięcia agenta do centralnego dashboardu (SOC) usługodawcy dzięki standardowym Webhookom JSON.
  * ZK Selective Disclosure – firmy mogą delegować badanie najbardziej złożonych incydentów do niezależnych analityków z pominięciem danych osobowych i adresacji IP; analityk weryfikuje dowód ZK bez łamania RODO klienta.

## 3. Compliance & Forensics as a Service (NIS2, DORA, KSC)

Monetyzacja głównego wyróżnika Thorium – czyli kryptograficznego, niezmiennego dowodu incydentów zapisywanego na łańcuchu. 

* **Sposób licencjonowania:** Płatność w modelu "Pay-as-you-go" za incydent lub stała licencja "Compliance" za gwarancję ciągłości rejestracji logów audytowych.
* **Grupa docelowa:** Operatorzy Usług Kluczowych (energetyka, woda), urzędy, kancelarie prawne, ubezpieczyciele cybernetyczni.
* **Propozycja Wartości (USP):**
  * Zgodność z dyrektywą NIS2 i KSC wymaga udowadniania ścieżki ataku.
  * Zrzuty pamięci, logi i dowody zapisywane w Walrus, rejestrowane na blockchainie, stanowią żelazny dowód (niepodważalny kryptograficznie), który może posłużyć przed sądem lub firmą ubezpieczeniową po ataku ransomware.

## 4. Decentralized Threat Intelligence Network (Tokenomia / Web3)

Wykorzystanie tokenomii do budowy globalnej sieci odporności. Model zorientowany całkowicie na Web3.

* **Sposób licencjonowania:** Udział w sieci jest darmowy, ale wymaga "stakowania" tokenów, aby chronić węzły przed sybillem. Uczestnicy zarabiają tokeny.
* **Grupa docelowa:** Globalna społeczność entuzjastów bezpieczeństwa, firmy chcące tańszego EDR w zamian za współdzielenie danych.
* **Propozycja Wartości (USP):**
  * Kiedy Agent z firmy A wykryje nowy rodzaj złośliwego oprogramowania (zero-day) i przekaże o nim informacje do sieci (np. poprzez Magnesium MPC), firma A otrzymuje nagrodę w postaci tokenów $THOR.
  * Firmy kupujące dostęp do globalnej bazy reguł płacą za nią tokenami, finansując nagrody dla odkrywców.
  * Tworzy to potężny efekt sieciowy – im więcej użytkowników, tym mądrzejsza staje się baza IoC (Indicator of Compromise).

## 5. Model Freemium (Open-Core Edge)

Rozdawanie rdzenia agenta za darmo, aby szybko przejąć rynek deweloperów, i monetyzacja funkcji korporacyjnych.

* **Sposób licencjonowania:** Agent lokalny (telemetria eBPF, prosta izolacja, edge caching) jest darmowy i Open Source. Złożony offloading (Magnesium MPC), SOAR, korelacja sieciowa na Sui i agregacja dowodów w Walrus (Polonium SOC) są płatne.
* **Grupa docelowa:** Programiści, startupy (darmowo), z płynnym przejściem w wersję korporacyjną po skalowaniu firmy.
* **Propozycja Wartości (USP):**
  * Bardzo niski próg wejścia. Instalacja agenta jednym poleceniem.
  * Zbudowanie masowej lojalności wokół marki (podobnie jak Elasticsearch lub Tailscale).
