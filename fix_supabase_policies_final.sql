-- CLEANED UP SUPABASE SETUP SCRIPT
-- Run this in Supabase SQL Editor to make sure everything is correct.

-- 1. Create Buckets (Safe to run if they already exist)
INSERT INTO storage.buckets (id, name, public) VALUES ('doctor_images', 'doctor_images', true) ON CONFLICT (id) DO UPDATE SET public = true;
INSERT INTO storage.buckets (id, name, public) VALUES ('patient_images', 'patient_images', true) ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Drop any old or conflicting policies
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Public Insert" ON storage.objects;
DROP POLICY IF EXISTS "Public Update" ON storage.objects;

-- 3. Policy: Allow ANYONE to SEE images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id IN ('doctor_images', 'patient_images') );

-- 4. Policy: Allow App to UPLOAD images (without Supabase Login)
CREATE POLICY "Public Insert"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id IN ('doctor_images', 'patient_images') );

-- 5. Policy: Allow App to UPDATE images
CREATE POLICY "Public Update"
ON storage.objects FOR UPDATE
USING ( bucket_id IN ('doctor_images', 'patient_images') );
