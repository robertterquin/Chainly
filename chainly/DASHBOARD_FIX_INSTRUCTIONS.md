# Dashboard Data Issues - Fix Instructions

## Issues Fixed

### 1. Bike Total Mileage Not Updating
**Problem**: When rides are added, the bike's `total_mileage` field was not being updated automatically.

**Solution**: Created database triggers that automatically update bike mileage when rides are added, updated, or deleted.

**Action Required**: 
1. Open your Supabase SQL Editor
2. Run the SQL file: `database/update_bike_mileage_trigger.sql`
3. This will:
   - Create triggers to auto-update bike mileage
   - Sync all existing bikes with their current ride totals

### 2. Dashboard Not Showing Latest Data
**Problem**: Dashboard was showing cached data and not refreshing when navigating to it.

**Solution**: 
- Converted DashboardScreen from `ConsumerWidget` to `ConsumerStatefulWidget`
- Added automatic data refresh in `initState()` when dashboard loads
- Added debug logging to help identify data issues

### 3. Debugging Added
Added debug print statements to help troubleshoot:
- Number of bikes, maintenance records, and reminders loaded
- Active bike details (name and mileage)
- Maintenance filtering logic

## How to Test

1. **Run the database trigger SQL**:
   - Copy content from `database/update_bike_mileage_trigger.sql`
   - Paste in Supabase SQL Editor
   - Execute the SQL

2. **Hot restart your app** (not just hot reload):
   ```bash
   flutter run -d chrome
   ```
   Or press `R` in the terminal

3. **Check the console/debug output**:
   Look for lines like:
   ```
   Dashboard - Bikes: 1
   Dashboard - Maintenance: 3
   Dashboard - Active Bike: Sam, Mileage: 100.0
   ```

4. **Navigate to different tabs and back to Dashboard**:
   - This will trigger the data refresh
   - You should see your 100km ride reflected in the total distance
   - You should see your 3 maintenance records (most recent one displayed)

## Expected Results

After running the trigger SQL:
- ✅ Bike card shows correct total mileage (100 km)
- ✅ Last Maintenance card shows your most recent maintenance record
- ✅ Status badge shows "Due" or "Done" with correct color
- ✅ Data refreshes every time you navigate to Dashboard

## Still Not Working?

If data still doesn't show after running the trigger:

1. Check the debug console output for data counts
2. Verify in Supabase that:
   - Your bike has `total_mileage = 100`
   - Your maintenance records have the correct `bike_id` matching your bike
3. Try manually running in Supabase SQL:
   ```sql
   SELECT * FROM bikes WHERE user_id = auth.uid();
   SELECT * FROM maintenance WHERE user_id = auth.uid();
   SELECT * FROM rides WHERE user_id = auth.uid();
   ```

If the data is in Supabase but not showing in the app, share the debug output from the console.
