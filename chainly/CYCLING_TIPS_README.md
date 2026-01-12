# Cycling Tips Feature - Setup Instructions

## Overview
The Cycling Tips feature provides daily rotating cycling tips from reliable sources with proper citations. Tips change every 24 hours based on the current date.

## Setup Steps

### 1. Run the Database SQL
1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy the contents of `database/cycling_tips_table.sql`
4. Paste and execute the SQL

This will:
- Create the `cycling_tips` table
- Set up Row Level Security (RLS) policies
- Insert 30 cycling tips from reliable sources
- Add proper indexes for performance

### 2. Verify Installation
After running the SQL, verify in Supabase:
```sql
SELECT COUNT(*) FROM cycling_tips;
```
Should return: **30 tips**

### 3. Test in the App
1. Hot restart your Flutter app
2. Navigate to the Dashboard
3. Scroll to the bottom to see "Tip of the Day"
4. The tip will include:
   - Title
   - Tip text
   - Source citation (clickable link)

## How It Works

### Daily Rotation Algorithm
```dart
// Calculate index based on current date (changes daily at midnight)
final now = DateTime.now();
final daysSinceEpoch = now.difference(DateTime(2024, 1, 1)).inDays;
final tipIndex = daysSinceEpoch % totalTips;
```

- Same tip shows for the entire day (24 hours)
- Automatically rotates at midnight
- Cycles through all 30 tips
- No user action needed

### Sources Included
All tips are from reputable cycling sources:
- **BikeRadar** - Equipment and maintenance
- **CyclingTips** - Performance and technique
- **British Cycling** - Nutrition and training
- **Park Tool** - Technical maintenance
- **USA Cycling** - Training and safety
- **Cycling Weekly** - General cycling advice
- **TrainingPeaks** - Performance training
- **GCN (Global Cycling Network)** - Video tutorials
- **Sheldon Brown** - Classic cycling wisdom
- **League of American Bicyclists** - Safety

### Categories
Tips are categorized for future features:
- `maintenance` - Bike care and upkeep
- `safety` - Riding safety and equipment
- `performance` - Training and efficiency
- `technique` - Skills and handling
- `nutrition` - Eating and hydration
- `training` - Structured workouts
- `bike-fit` - Positioning and comfort
- `seasonal` - Weather-specific advice
- `upgrades` - Equipment improvements
- `comfort` - Saddle and body care

## Future Enhancements

### Browse All Tips
Create a dedicated tips screen:
```dart
// Get all tips
final allTips = await cyclingTipsService.getAllTips();

// Get tips by category
final maintenanceTips = await cyclingTipsService.getTipsByCategory('maintenance');
```

### Favorites
Add ability to save favorite tips for later reference.

### Custom Tips
Allow admin users to add custom tips via the app.

### Push Notifications
Send daily tip as a notification at a chosen time.

## Troubleshooting

### Tip Not Loading
If tip shows "Loading tip..." indefinitely:
1. Check Supabase connection
2. Verify RLS policies are correct
3. Check browser console for errors
4. Verify table has data: `SELECT * FROM cycling_tips LIMIT 5;`

### Fallback Tip
If database is unavailable, app shows a fallback tip:
```dart
CyclingTip(
  title: 'Tip of the Day',
  tipText: 'Clean your chain every 200-300km...',
  source: 'BikeRadar',
)
```

### Link Not Opening
If source link doesn't work:
1. Verify `url_launcher` package is installed
2. Check that `sourceUrl` field is not null
3. Test link manually in browser

## Adding More Tips

To add more tips to the database:
```sql
INSERT INTO cycling_tips (title, tip_text, source, source_url, category) VALUES
('Your Tip Title', 'Your tip text here with detailed explanation.', 'Source Name', 'https://source-url.com/article', 'category');
```

### Guidelines for New Tips
1. **Cite reliable sources only** - established cycling publications, coaches, or research
2. **Include full URL** - for users to read more
3. **Keep concise** - 1-2 sentences max
4. **Actionable advice** - specific numbers, frequencies, or techniques
5. **Category appropriately** - helps future filtering features

## Database Schema

```sql
CREATE TABLE cycling_tips (
    id UUID PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    tip_text TEXT NOT NULL,
    source VARCHAR(255) NOT NULL,
    source_url TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

## API Usage

```dart
// In your code
import '../../services/cycling_tips_service.dart';
import '../../core/di/service_locator.dart';

// Get today's tip
final tip = await cyclingTipsService.getDailyTip();

// Access tip data
print(tip.title);      // "Chain Maintenance"
print(tip.tipText);    // "Clean your chain every..."
print(tip.source);     // "BikeRadar"
print(tip.sourceUrl);  // "https://..."
print(tip.category);   // "maintenance"
```

## Performance Notes

- Tips are fetched on-demand (not cached)
- Fast query with index on `created_at`
- Fallback ensures UI never breaks
- Future: Add local caching for offline support
