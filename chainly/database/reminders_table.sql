-- Reminders Table for Chainly App
-- Stores maintenance reminders (time-based and usage-based)

-- Drop existing table if needed (uncomment to reset)
-- DROP TABLE IF EXISTS public.reminders CASCADE;

-- Create reminders table
CREATE TABLE IF NOT EXISTS public.reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE CASCADE,
  maintenance_id UUID REFERENCES public.maintenance(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  reminder_type VARCHAR(20) NOT NULL CHECK (reminder_type IN ('time_based', 'usage_based')),
  
  -- Time-based reminder fields
  interval_days INTEGER, -- For recurring reminders (e.g., every 30 days)
  due_date TIMESTAMP WITH TIME ZONE,
  last_completed_date TIMESTAMP WITH TIME ZONE,
  
  -- Usage-based reminder fields
  interval_distance DECIMAL(10, 2), -- Distance in km (e.g., every 500 km)
  last_completed_mileage DECIMAL(10, 2),
  
  -- Common fields
  is_enabled BOOLEAN DEFAULT true,
  is_recurring BOOLEAN DEFAULT true,
  category VARCHAR(50) DEFAULT 'other' CHECK (category IN ('chain', 'brakes', 'tires', 'service', 'other')),
  priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high')),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON public.reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_bike_id ON public.reminders(bike_id);
CREATE INDEX IF NOT EXISTS idx_reminders_due_date ON public.reminders(due_date);
CREATE INDEX IF NOT EXISTS idx_reminders_enabled ON public.reminders(is_enabled);
CREATE INDEX IF NOT EXISTS idx_reminders_type ON public.reminders(reminder_type);
CREATE INDEX IF NOT EXISTS idx_reminders_maintenance_id ON public.reminders(maintenance_id);

-- Enable Row Level Security
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reminders table

-- Policy: Users can view their own reminders
CREATE POLICY "Users can view own reminders"
  ON public.reminders
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own reminders
CREATE POLICY "Users can insert own reminders"
  ON public.reminders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reminders
CREATE POLICY "Users can update own reminders"
  ON public.reminders
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own reminders
CREATE POLICY "Users can delete own reminders"
  ON public.reminders
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_reminders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
DROP TRIGGER IF EXISTS reminders_updated_at_trigger ON public.reminders;
CREATE TRIGGER reminders_updated_at_trigger
  BEFORE UPDATE ON public.reminders
  FOR EACH ROW
  EXECUTE FUNCTION update_reminders_updated_at();

-- Create view for upcoming reminders with calculated due status
CREATE OR REPLACE VIEW public.reminder_overview AS
SELECT 
  r.*,
  b.name AS bike_name,
  b.total_mileage AS bike_mileage,
  CASE 
    WHEN r.reminder_type = 'time_based' THEN 
      CASE
        WHEN r.due_date < NOW() THEN 'overdue'
        WHEN r.due_date < NOW() + INTERVAL '7 days' THEN 'due_soon'
        ELSE 'upcoming'
      END
    WHEN r.reminder_type = 'usage_based' THEN
      CASE
        WHEN (b.total_mileage - COALESCE(r.last_completed_mileage, 0)) >= r.interval_distance THEN 'overdue'
        WHEN (b.total_mileage - COALESCE(r.last_completed_mileage, 0)) >= (r.interval_distance * 0.9) THEN 'due_soon'
        ELSE 'upcoming'
      END
    ELSE 'unknown'
  END AS status,
  CASE 
    WHEN r.reminder_type = 'time_based' THEN 
      EXTRACT(DAY FROM (r.due_date - NOW()))::INTEGER
    WHEN r.reminder_type = 'usage_based' THEN
      (r.interval_distance - (b.total_mileage - COALESCE(r.last_completed_mileage, 0)))::INTEGER
    ELSE NULL
  END AS remaining_value
FROM public.reminders r
JOIN public.bikes b ON r.bike_id = b.id
WHERE r.is_enabled = true
ORDER BY 
  CASE 
    WHEN r.reminder_type = 'time_based' THEN r.due_date
    ELSE NULL
  END ASC NULLS LAST;

-- Insert sample reminders (optional - remove in production)
-- Note: Replace the user_id and bike_id with actual values from your database

/*
INSERT INTO public.reminders (user_id, bike_id, title, description, reminder_type, interval_days, due_date, category, priority) VALUES
  ((SELECT id FROM auth.users LIMIT 1), 
   (SELECT id FROM public.bikes LIMIT 1), 
   'Chain Lubrication', 
   'Clean and lubricate chain',
   'time_based',
   14,
   NOW() + INTERVAL '3 days',
   'chain',
   'normal'),
  
  ((SELECT id FROM auth.users LIMIT 1), 
   (SELECT id FROM public.bikes LIMIT 1), 
   'Tire Inspection', 
   'Check tire pressure and wear',
   'time_based',
   7,
   NOW() + INTERVAL '5 days',
   'tires',
   'high'),
  
  ((SELECT id FROM auth.users LIMIT 1), 
   (SELECT id FROM public.bikes LIMIT 1), 
   'Chain Replacement', 
   'Replace chain after 3000 km',
   'usage_based',
   NULL,
   NULL,
   'chain',
   'normal')
  WHERE EXISTS (SELECT 1 FROM public.bikes);
*/

-- Grant necessary permissions (adjust as needed)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reminders TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
