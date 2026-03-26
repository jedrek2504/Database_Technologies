# README — Jak uruchomić projekt (PostgreSQL + PostGIS, WSL)

## 📌 Wymagania

- WSL (Ubuntu)
- PostgreSQL
- PostGIS

---

## 🔧 1. Instalacja

W terminalu WSL:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib postgis
```

Uruchom PostgreSQL:

```bash
sudo service postgresql start
```

---

## 🗄️ 2. Utworzenie bazy danych

Wejdź do PostgreSQL:

```bash
sudo -u postgres psql
```

W środku:

```sql
CREATE DATABASE gis_project;
\c gis_project
```

---

## 📂 3. Przejście do katalogu projektu

W terminalu:

```bash
cd /home/ekosjed/gitrepos/TPBD
```

(ścieżka może się różnić u Ciebie)

---

## ▶️ 4. Uruchomienie projektu

Najprościej jednym poleceniem:

```bash
sudo -u postgres psql -d gis_project -f tables_creation.sql -f proc.sql -f calls.sql
```

---

## 📊 5. Co się stanie po uruchomieniu

Projekt:

1. Utworzy tabele:
   - parks
   - paths
   - facilities

2. Utworzy indeksy przestrzenne (GiST)

3. Doda procedury (logika systemu)

4. Wstawi przykładowe dane:
   - parki
   - ścieżki
   - obiekty

5. Wykona przykładowe operacje:
   - pokaże listę parków
   - pokaże ścieżki
   - pokaże obiekty
   - znajdzie obiekty w pobliżu
   - policzy długości i odległości

---

## ⚠️ 6. Ważne uwagi

### 🔹 Uruchamianie drugi raz

Jeśli uruchomisz skrypt drugi raz, zobaczysz błędy typu:

```
relation already exists
```

To normalne — tabele już istnieją.

### ✔️ Rozwiązanie (czysta baza)

```sql
DROP DATABASE IF EXISTS gis_project;
CREATE DATABASE gis_project;
```

---

### 🔹 Błąd „park przecina się z istniejącym”

To nie jest błąd systemu — to **walidacja danych**.

Projekt celowo blokuje:
- nakładające się parki,
- błędne geometrie.

---

## 🧪 7. Uruchamianie ręczne (opcjonalne)

Możesz wejść do bazy:

```bash
sudo -u postgres psql -d gis_project
```

i uruchamiać pojedyncze pliki:

```sql
\i tables_creation.sql
\i proc.sql
\i calls.sql
```

---

## 🧠 8. Co robi ten projekt

To system zarządzania parkami z wykorzystaniem danych przestrzennych.

Umożliwia:
- dodawanie parków (obszary),
- dodawanie ścieżek (linie),
- dodawanie obiektów (punkty),
- analizę przestrzenną (odległości, długości, obiekty w pobliżu),
- walidację danych (np. brak nakładania parków).

---

## ✅ Gotowe!

Po wykonaniu powyższych kroków projekt działa i można go prezentować.
