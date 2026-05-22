-- FIX SUPABASE STORAGE POLICIES
-- Run this in your Supabase SQL Editor to allow image uploads with Firebase Auth.

-- 1. Drop the old strict policies that required Supabase Auth
DROP POLICY IF EXISTS "Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;

-- 2. Create new "Public" policies (Allow uploads from your App without Supabase Login)

-- Allow ANYONE to UPLOAD images to 'doctor_images' and 'patient_images' buckets
CREATE POLICY "Public Insert"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id IN ('doctor_images', 'patient_images') );

-- Allow ANYONE to UPDATE images in these buckets
CREATE POLICY "Public Update"
ON storage.objects FOR UPDATE
USING ( bucket_id IN ('doctor_images', 'patient_images') );

-- Note: "Public Access" (Read) policy should already exist from the previous script.
-- If not, run this:
-- CREATE POLICY "Public Access"
-- ON storage.objects FOR SELECT
-- USING ( bucket_id IN ('doctor_images', 'patient_images') );
