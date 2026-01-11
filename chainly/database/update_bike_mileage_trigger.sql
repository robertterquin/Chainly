-- Trigger to automatically update bike total_mileage when rides are added/updated/deleted
-- Run this SQL in your Supabase SQL Editor

-- Function to update bike total mileage
CREATE OR REPLACE FUNCTION update_bike_total_mileage()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the bike's total_mileage by summing all ride distances
    UPDATE bikes
    SET total_mileage = COALESCE((
        SELECT SUM(distance)
        FROM rides
        WHERE bike_id = COALESCE(NEW.bike_id, OLD.bike_id)
    ), 0)
    WHERE id = COALESCE(NEW.bike_id, OLD.bike_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT: Update bike mileage when a new ride is added
CREATE TRIGGER trigger_update_bike_mileage_on_insert
    AFTER INSERT ON rides
    FOR EACH ROW
    EXECUTE FUNCTION update_bike_total_mileage();

-- Trigger for UPDATE: Update bike mileage when a ride distance is modified
CREATE TRIGGER trigger_update_bike_mileage_on_update
    AFTER UPDATE OF distance, bike_id ON rides
    FOR EACH ROW
    EXECUTE FUNCTION update_bike_total_mileage();

-- Trigger for DELETE: Update bike mileage when a ride is deleted
CREATE TRIGGER trigger_update_bike_mileage_on_delete
    AFTER DELETE ON rides
    FOR EACH ROW
    EXECUTE FUNCTION update_bike_total_mileage();

-- Optional: Update all existing bikes with current ride totals
-- Run this once to sync existing data
UPDATE bikes b
SET total_mileage = COALESCE((
    SELECT SUM(distance)
    FROM rides r
    WHERE r.bike_id = b.id
), 0);
