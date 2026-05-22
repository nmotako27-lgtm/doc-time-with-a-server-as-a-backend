-- COPY ALL OF THIS CODE
-- INSTRUCTIONS:
-- 1. Go to your Supabase Dashboard
-- 2. Click on "SQL Editor" (icon with terminal symbol on the left)
-- 3. Click "New Query"
-- 4. Paste this code and click "Run"

-- ===================================================
-- 1. Create Buckets (Safe to run if they already exist)
-- ===================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('doctor_images', 'doctor_images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

INSERT INTO storage.buckets (id, name, public)
VALUES ('patient_images', 'patient_images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- ===================================================
-- 2. Set Permissions (Security Policies)
-- ===================================================

-- Drop old policies to avoid errors if they exist
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;

-- A) Allow ANYONE to SEE images (Required for them to show in the app)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id IN ('doctor_images', 'patient_images') );

-- B) Allow LOGGED IN users to UPLOAD images
CREATE POLICY "Authenticated Insert"
ON storage.objects FOR INSERT
WITH CHECK ( auth.role() = 'authenticated' AND bucket_id IN ('doctor_images', 'patient_images') );

-- C) Allow LOGGED IN users to UPDATE images
CREATE POLICY "Authenticated Update"
ON storage.objects FOR UPDATE
USING ( auth.role() = 'authenticated' AND bucket_id IN ('doctor_images', 'patient_images') );

-- Done!
