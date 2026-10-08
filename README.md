# HydroFlow - Water Flow & Volume Monitoring Mobile App

HydroFlow is a production-ready mobile application built in Flutter for real-time water flow and volume telemetry monitoring, historical logging, anomaly alerts, and consumption analytics.

---

## 🌊 Core Features

### 1. Real-Time Dashboard
- **Current Flow Rate Hero Card**: Displays instantaneous flow rate in Liters/minute (`L/min`), with status badges (`NORMAL` vs `WARNING`), live wave visualization, and minimum/peak/safe threshold markers.
- **Total Water Volume Card**: Displays cumulative metered volume in Liters (`L`) and cubic meters (`m³`), alongside daily quota progress.
- **Prominent High Flow Alert Banner**: Appears immediately whenever the flow rate breaches the safe threshold (default: `25.0 L/min`), complete with pulsing animation, percentage exceeded, and diagnostic advice.
- **Telemetry Quick Stats**: At-a-glance cards showing today's peak flow rate and threshold warning incidents.

### 2. Smart Consumption Charts
- **Hourly Trends (Past 24 Hours)**: High-resolution bar charts illustrating hourly water consumption patterns.
- **Daily Trends (Past 7 Days)**: Weekly overview for monitoring daily usage cycles against baseline averages.
- **Interactive Tooltips**: Tap on any bar to inspect exact volume (Liters) and peak velocity.
- **Surge Highlighting**: Intervals that experienced flow surges or warning states are flagged with amber/red indicators.
- **Analytics Insights**: Summary cards calculating Peak Interval, Average Draw, Total Metered Volume, and Flow Stability score.

### 3. History & Event Logs
- **Event History List**: Chronological record of water flow cycles, session start/end timestamps, elapsed duration, metered volume, and peak velocity.
- **Status Tags**: Clear `NORMAL` (emerald) and `WARNING` (red/amber) visual badges for rapid triaging.
- **Filter Chips**: Instant filtering by `All Events`, `Warnings Only`, or `Normal Only`.
- **Search**: Real-time filtering by keyword or notes.
- **Detailed Modal Sheet**: Tap any log entry to view an in-depth breakdown of the water draw event.

### 4. Interactive Telemetry Simulator
- Non-hardware testing toolbar allowing immediate verification of all states:
  - **Normal Flow**: Simulates typical residential/utility draw (~16 L/min).
  - **Surge Alert**: Simulates high-pressure surge (>25 L/min) to test the warning banner and alerts.
  - **Zero Flow**: Simulates idle/shut-off state (0.0 L/min).
  - **Safe Limit Slider**: Interactively adjust the safe threshold between 10.0 and 40.0 L/min to verify alert trigger logic.
  - **Play / Pause**: Freeze or resume real-time telemetry stream.

---

## 🏛️ Clean Architecture & Project Structure

```
lib/
├── main.dart                          # App initialization, Theme and Service bindings
├── models/
│   ├── flow_data_point.dart           # Real-time instantaneous telemetry model
│   ├── alert_model.dart               # Threshold breach alert model & severity
│   ├── flow_log_entry.dart            # History log item with status tags
│   └── consumption_metric.dart        # Aggregated hourly & daily metrics for charts
├── services/
│   └── water_monitoring_service.dart  # Central telemetry engine, volume accumulator & alerts
├── theme/
│   └── app_theme.dart                 # Oceanic dark theme, glassmorphism cards & tokens
├── utils/
│   ├── constants.dart                 # Thresholds, units, colors, and durations
│   └── formatters.dart                # Pure-Dart volume, flow rate, and date formatters
├── widgets/
│   ├── alert_banner.dart              # Pulsing warning banner for threshold breaches
│   ├── flow_rate_card.dart            # Live flow rate hero card with wave background
│   ├── total_volume_card.dart         # Cumulative volume card with quota indicator
│   ├── water_wave_gauge.dart          # Animated sinusoidal canvas water wave
│   ├── smart_consumption_chart.dart   # Custom interactive bar chart with touch tooltips
│   ├── flow_stat_card.dart            # Compact telemetry metric card
│   ├── log_entry_tile.dart            # History log card with status badge & details sheet
│   └── simulation_controller.dart     # Testing bar for simulating flow states & thresholds
└── screens/
    ├── main_navigation_screen.dart    # Bottom navigation bar with alert badging
    ├── dashboard_screen.dart          # Core monitoring dashboard & real-time telemetry
    ├── charts_screen.dart             # In-depth hourly and daily consumption analytics
    └── history_screen.dart            # Filterable event logs with search and modal inspection
```

---

## 🚀 How to Run

1. Open your terminal in the project root:
   ```bash
   cd water_flow_app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on your connected device or emulator (Android / iOS / Web / Desktop):
   ```bash
   flutter run
   ```
4. Run tests:
   ```bash
   flutter test
   ```
