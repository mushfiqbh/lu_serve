-- Create storage buckets for notes (PDFs) and notices (images)
-- Run this in the Supabase SQL Editor

-- Bucket for notes (PDF files)
INSERT INTO storage.buckets (id, name, public)
VALUES ('notes', 'notes', true)
ON CONFLICT (id) DO NOTHING;

-- Bucket for notices (images)
INSERT INTO storage.buckets (id, name, public)
VALUES ('notices', 'notices', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for notes bucket
-- Allow authenticated users to view (download) files
CREATE POLICY "Anyone can view notes files"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'notes');

-- Allow authenticated users to upload files to notes bucket
CREATE POLICY "Authenticated users can upload notes files"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'notes');

-- Allow admins to delete notes files
CREATE POLICY "Admins can delete notes files"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'notes'
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS policies for notices bucket
-- Allow authenticated users to view notice images
CREATE POLICY "Anyone can view notice images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'notices');

-- Allow authenticated users to upload notice images
CREATE POLICY "Authenticated users can upload notice images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'notices');

-- Allow admins to delete notice images
CREATE POLICY "Admins can delete notice images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'notices'
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
