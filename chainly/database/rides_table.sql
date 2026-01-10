-- Create rides table in Supabase
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS rides (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    bike_id UUID NOT NULL REFERENCES bikes(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    distance DECIMAL(10, 2) NOT NULL CHECK (distance > 0),
    duration_minutes INTEGER CHECK (duration_minutes > 0),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_rides_user_id ON rides(user_id);
CREATE INDEX IF NOT EXISTS idx_rides_bike_id ON rides(bike_id);
CREATE INDEX IF NOT EXISTS idx_rides_date ON rides(date DESC);
CREATE INDEX IF NOT EXISTS idx_rides_user_date ON rides(user_id, date DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy: Users can only view their own rides
CREATE POLICY "Users can view own rides"
    ON rides
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own rides
CREATE POLICY "Users can insert own rides"
    ON rides
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own rides
CREATE POLICY "Users can update own rides"
    ON rides
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own rides
CREATE POLICY "Users can delete own rides"
    ON rides
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_rides_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER trigger_update_rides_updated_at
    BEFORE UPDATE ON rides
    FOR EACH ROW
    EXECUTE FUNCTION update_rides_updated_at();

-- Optional: Create a view for ride statistics
CREATE OR REPLACE VIEW ride_statistics AS
SELECT 
    user_id,
    bike_id,
    COUNT(*) as total_rides,
    SUM(distance) as total_distance,
    SUM(duration_minutes) as total_duration_minutes,
    AVG(distance) as avg_distance,
    MAX(distance) as max_distance,
    MIN(date) as first_ride_date,
    MAX(date) as last_ride_date
FROM rides
GROUP BY user_id, bike_id;

-- Grant access to the view
GRANT SELECT ON ride_statistics TO authenticated;

-- Comments for documentation
COMMENT ON TABLE rides IS 'Stores user ride records for tracking cycling activities';
COMMENT ON COLUMN rides.distance IS 'Distance in kilometers';
COMMENT ON COLUMN rides.duration_minutes IS 'Ride duration in minutes (optional)';
COMMENT ON COLUMN rides.notes IS 'Optional notes about the ride (weather, conditions, etc.)';
