# AI Weekly Mental Health Insights Generator

A Flutter app for psychosis symptom tracking, early-warning detection, and AI-powered weekly insight summaries.

---

## Features

| Screen | Description |
|--------|-------------|
| **Daily Journal** | Log positive symptoms (racing thoughts, suspicion), negative symptoms (low motivation, social withdrawal), sleep hours, and stress level via smooth sliders. |
| **7-Day Timeline** | `fl_chart` line chart visualising all six dimensions over the past week. |
| **AI Weekly Insights** | One tap sends the week's data to OpenAI (or Claude) and returns: patterns spotted, an early-warning flag, a CBT-aligned self-care suggestion, and a weekly narrative summary. |

---

## Architecture

```
lib/
├── core/
│   ├── di/          # GetIt dependency injection
│   ├── error/       # Failure classes
│   ├── router/      # go_router configuration
│   ├── theme/       # AppTheme (Material 3, calm clinical palette)
│   └── utils/       # AppConstants
└── features/
    ├── journal/
    │   ├── data/
    │   │   ├── datasources/  # Hive local data source
    │   │   ├── models/       # JournalEntryModel (Hive adapter)
    │   │   └── repositories/ # JournalRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/     # JournalEntry
    │   │   ├── repositories/ # Abstract JournalRepository
    │   │   └── usecases/     # SaveJournalEntry, GetWeeklyEntries
    │   └── presentation/
    │       ├── bloc/         # JournalBloc / Event / State
    │       └── pages/        # JournalPage, TimelinePage
    └── insights/
        ├── data/
        │   ├── datasources/  # InsightsRemoteDataSource (OpenAI / Claude)
        │   ├── models/       # WeeklyInsightsModel + prompt builder
        │   └── repositories/ # InsightsRepositoryImpl
        ├── domain/
        │   ├── entities/     # WeeklyInsights
        │   ├── repositories/ # Abstract InsightsRepository
        │   └── usecases/     # GenerateWeeklyInsights
        └── presentation/
            ├── bloc/         # InsightsBloc / Event / State
            └── pages/        # InsightsPage
```

**State management:** BLoC (`flutter_bloc`)  
**Navigation:** `go_router`  
**Local storage:** Hive  
**Charts:** `fl_chart`  
**AI:** OpenAI `gpt-4o-mini` (or Anthropic Claude)

---

## Getting Started

### 1 — Clone & install dependencies

```bash
flutter pub get
```

### 2 — Configure your API key

Copy the example env file and fill in your key:

```bash
cp .env.example .env
# then edit .env and replace 'replace_me' with your real key
```

`.env` format:

```dotenv
OPENAI_API_KEY=sk-...
AI_PROVIDER=openai        # or "claude"
# CLAUDE_API_KEY=sk-ant-...
```

### 3 — Regenerate Hive adapters (if you change the model)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4 — Run

```bash
flutter run
```

---

## Running Tests

```bash
flutter test
```

---

## Environment Variables

| Key | Required | Description |
|-----|----------|-------------|
| `OPENAI_API_KEY` | Yes (if provider=openai) | Your OpenAI secret key |
| `CLAUDE_API_KEY` | Yes (if provider=claude) | Your Anthropic secret key |
| `AI_PROVIDER` | No (default: `openai`) | `openai` or `claude` |

> ⚠️ **Never commit your real API keys.** The tracked `.env` contains only placeholder values.
