# ⚡ ElecBill Estimator

A Flutter Android application that estimates monthly electricity bills based on 
Malaysia's TNB domestic tiered tariff. Built as part of a Mobile Technology course assignment.

---

## Features

- Calculate electricity bill using the official TNB tiered tariff blocks
- Adjustable rebate percentage (0% – 5%) via a slider
- Stores all records locally using SQLite (offline, no internet required)
- View bill history in a list (month & final cost)
- Tap any record to view full details, edit, or delete
- About page with app instructions and developer info

---

## Tariff Rates (TNB Domestic)

| Block         | Rate (sen/kWh) |
|---------------|----------------|
| 1 – 200 kWh   | 21.8           |
| 201 – 300 kWh | 33.4           |
| 301 – 600 kWh | 51.6           |
| 601 – 1000 kWh| 54.6           |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **Database:** SQLite via `sqflite`
- **Platform:** Android

---

## How to Run

1. Clone the repository
```bash
   git clone https://github.com/aranamanj/electricity_bill_estimator
```
2. Install dependencies
```bash
   flutter pub get
```
3. Run the app
```bash
   flutter run
```

---

## Screenshots

> Coming soon

---

## License

© 2026 Aran Amanj Othman. All Rights Reserved.