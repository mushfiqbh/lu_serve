-- Create the bus_schedules table
CREATE TABLE IF NOT EXISTS bus_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_number TEXT NOT NULL,
  route TEXT NOT NULL,
  departure_time TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE bus_schedules ENABLE ROW LEVEL SECURITY;

-- RLS policies
-- Anyone authenticated can view bus schedules
CREATE POLICY "Bus schedules are viewable by all authenticated users"
  ON bus_schedules FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can insert bus schedules
CREATE POLICY "Admins can insert bus schedules"
  ON bus_schedules FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can update bus schedules
CREATE POLICY "Admins can update bus schedules"
  ON bus_schedules FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can delete bus schedules
CREATE POLICY "Admins can delete bus schedules"
  ON bus_schedules FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Trigger to automatically update updated_at
CREATE TRIGGER set_bus_schedules_updated_at
  BEFORE UPDATE ON bus_schedules
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
