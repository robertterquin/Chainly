-- Create cycling_tips table in Supabase
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS cycling_tips (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    tip_text TEXT NOT NULL,
    source VARCHAR(255) NOT NULL,
    source_url TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_cycling_tips_category ON cycling_tips(category);
CREATE INDEX IF NOT EXISTS idx_cycling_tips_created_at ON cycling_tips(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE cycling_tips ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read cycling tips (no auth required)
CREATE POLICY "Anyone can view cycling tips"
    ON cycling_tips
    FOR SELECT
    USING (true);

-- Policy: Only authenticated users can insert tips (optional, for admin)
CREATE POLICY "Authenticated users can insert tips"
    ON cycling_tips
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_cycling_tips_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER trigger_update_cycling_tips_updated_at
    BEFORE UPDATE ON cycling_tips
    FOR EACH ROW
    EXECUTE FUNCTION update_cycling_tips_updated_at();

-- Insert cycling tips from reliable sources with citations
INSERT INTO cycling_tips (title, tip_text, source, source_url, category) VALUES
('Chain Maintenance', 'Clean your chain every 200-300km to extend its lifespan and maintain smooth shifting. Use a degreaser and chain cleaning tool for best results.', 'BikeRadar', 'https://www.bikeradar.com/advice/workshop/how-to-clean-a-bike-chain/', 'maintenance'),

('Tire Pressure Check', 'Check your tire pressure before every ride. Properly inflated tires (based on your weight and tire specs) reduce rolling resistance and prevent pinch flats.', 'CyclingTips', 'https://cyclingtips.com/2016/09/everything-you-need-to-know-about-tire-pressure/', 'maintenance'),

('Brake Inspection', 'Inspect brake pads monthly for wear. Replace them when the grooves are less than 1mm deep to maintain safe stopping power in all conditions.', 'Park Tool', 'https://www.parktool.com/en-us/blog/repair-help/rim-brake-pad-replacement', 'safety'),

('Hydration Strategy', 'Drink 500-750ml of water per hour during rides. Start hydrating 2 hours before your ride and continue drinking even if you don''t feel thirsty.', 'British Cycling', 'https://www.britishcycling.org.uk/knowledge/article/izn20140808-Sportive-Advice-Nutrition-and-hydration-0', 'performance'),

('Proper Saddle Height', 'Set your saddle height so your leg has a slight bend (25-30 degrees) at the knee when the pedal is at the bottom position. This maximizes power and prevents injury.', 'Cycling Weekly', 'https://www.cyclingweekly.com/fitness/bike-fit/saddle-height', 'bike-fit'),

('Cadence Training', 'Maintain a cadence of 80-100 RPM for optimal efficiency. Use lower gears and spin faster rather than grinding in harder gears to reduce joint stress.', 'TrainingPeaks', 'https://www.trainingpeaks.com/blog/cadence-what-is-it-and-why-does-it-matter/', 'performance'),

('Pre-Ride Warm-Up', 'Warm up for 10-15 minutes at easy intensity before hard efforts. This prepares your muscles, increases blood flow, and reduces injury risk.', 'USA Cycling', 'https://usacycling.org/article/warm-up-cool-down', 'training'),

('Bike Storage', 'Store your bike in a dry place away from direct sunlight. Hang it by the frame (not wheels) to prevent tire flat spots and maintain wheel true.', 'REI Expert Advice', 'https://www.rei.com/learn/expert-advice/bike-storage.html', 'maintenance'),

('Gear Shifting Tips', 'Shift gears before you need them, not during climbs or sprints. Anticipate terrain changes and shift to an easier gear before the hill starts.', 'Bicycling Magazine', 'https://www.bicycling.com/skills-tips/a20028283/how-to-shift-gears/', 'technique'),

('Post-Ride Recovery', 'Consume protein and carbohydrates within 30 minutes after rides longer than 90 minutes. This glycogen window is crucial for muscle recovery.', 'Cycling Science', 'https://cyclingscience.net/recovery-nutrition/', 'nutrition'),

('Winter Bike Care', 'Clean your bike after every wet ride to prevent rust and corrosion. Lubricate the chain more frequently in wet conditions (every 100km vs 300km).', 'BikeRadar', 'https://www.bikeradar.com/advice/fitness-and-training/cycling-in-winter/', 'seasonal'),

('Helmet Safety', 'Replace your helmet every 3-5 years or immediately after any crash. Foam degrades over time and invisible damage can compromise protection.', 'Bicycle Helmet Safety Institute', 'https://helmets.org/replace.htm', 'safety'),

('Pedaling Technique', 'Focus on pulling up on the pedal stroke, not just pushing down. Think of scraping mud off your shoe at the bottom of each stroke for 360-degree power.', 'Training Peaks', 'https://www.trainingpeaks.com/blog/pedaling-technique/', 'technique'),

('Group Riding Etiquette', 'When riding in a group, call out hazards, maintain steady pace, and avoid sudden braking. Point to road hazards and signal your intentions clearly.', 'League of American Bicyclists', 'https://bikeleague.org/content/rules-road-0', 'safety'),

('Tubeless Tire Benefits', 'Consider tubeless tires for fewer flats and lower rolling resistance. Check sealant every 3-4 months and top up as needed for optimal performance.', 'Road.cc', 'https://road.cc/content/feature/tubeless-tyres-everything-you-need-know-276379', 'upgrades'),

('Core Strength Training', 'Perform core exercises 2-3 times per week to improve bike handling and prevent lower back pain. Planks and bridges are particularly effective for cyclists.', 'Cycling Weekly', 'https://www.cyclingweekly.com/fitness/training/core-strength-exercises-cyclists', 'training'),

('Night Riding Safety', 'Use front lights (minimum 500 lumens) and rear lights when riding at night. Wear reflective clothing and consider using reflective tape on your bike.', 'CTC Cycling UK', 'https://www.cyclinguk.org/article/cycling-at-night', 'safety'),

('Bike Fit Importance', 'Get a professional bike fit if you experience persistent pain or discomfort. Proper fit prevents injuries and can improve power output by 5-10%.', 'CyclingTips', 'https://cyclingtips.com/2019/02/bike-fit-basics/', 'bike-fit'),

('Cassette Cleaning', 'Clean your cassette every month with a brush and degreaser. A clean drivetrain is 10-15% more efficient than a dirty one.', 'GCN (Global Cycling Network)', 'https://www.globalcyclingnetwork.com/video/how-to-clean-your-cassette', 'maintenance'),

('Recovery Rides', 'Include easy recovery rides (60% max heart rate) the day after hard training. Active recovery promotes blood flow and speeds muscle repair.', 'British Cycling', 'https://www.britishcycling.org.uk/knowledge/article/izn20140117-sportive-advice-recovery-0', 'training'),

('Wheel Truing', 'Check wheel true monthly by spinning the wheel and watching for wobbles. Minor adjustments can prevent spoke breakage and extend wheel life.', 'Sheldon Brown', 'https://www.sheldonbrown.com/wheelbuild.html', 'maintenance'),

('Climbing Technique', 'Stay seated on long climbs to conserve energy. Stand only on steep sections or when you need a position change to use different muscles.', 'VeloNews', 'https://www.velonews.com/gear/technical-faq/technical-faq-climbing-seated-vs-standing/', 'technique'),

('Handlebar Tape Care', 'Replace handlebar tape every 6-12 months or when it shows wear. Fresh tape improves grip and comfort while preventing handlebar corrosion.', 'BikeRadar', 'https://www.bikeradar.com/advice/workshop/how-to-wrap-bar-tape/', 'maintenance'),

('Weather Preparation', 'Layer clothing in cold weather: base layer, insulating layer, and windproof outer. Remove layers before you feel too hot to avoid excessive sweating.', 'Cycling Weekly', 'https://www.cyclingweekly.com/fitness/what-to-wear-cycling-in-cold-weather', 'seasonal'),

('Descending Skills', 'Keep your weight back and low on descents. Look ahead, not down at your front wheel, and feather your brakes rather than grabbing them suddenly.', 'USA Cycling', 'https://usacycling.org/article/descending-basics', 'technique'),

('Chain Wear Check', 'Check chain wear every 500km using a chain checker tool. Replace at 0.5% wear (0.75% for 11-speed) to prevent expensive cassette and chainring damage.', 'Park Tool', 'https://www.parktool.com/en-us/blog/repair-help/when-to-replace-a-chain', 'maintenance'),

('Saddle Sore Prevention', 'Use chamois cream before long rides to reduce friction. Wash cycling shorts after every ride and replace them when the padding compresses.', 'CyclingTips', 'https://cyclingtips.com/2017/07/prevent-treat-saddle-sores/', 'comfort'),

('Interval Training', 'Include high-intensity intervals once or twice per week to improve VO2 max. Try 4-6 repeats of 4 minutes hard with 4 minutes easy recovery.', 'TrainingPeaks', 'https://www.trainingpeaks.com/blog/cycling-interval-training/', 'training'),

('Bearing Maintenance', 'Service wheel and bottom bracket bearings annually or every 5,000km. Regular maintenance prevents expensive replacements and maintains smooth operation.', 'Park Tool', 'https://www.parktool.com/en-us/blog/repair-help/hub-overhaul-and-adjustment', 'maintenance'),

('Nutrition Timing', 'Eat 30-60g of carbohydrates per hour on rides over 90 minutes. Use a mix of gels, bars, and real food to prevent flavor fatigue and stomach issues.', 'British Cycling', 'https://www.britishcycling.org.uk/knowledge/article/izn20140117-Sportive-Advice-Nutrition-and-hydration-0', 'nutrition');

-- Grant permissions
GRANT SELECT ON cycling_tips TO anon;
GRANT SELECT ON cycling_tips TO authenticated;
