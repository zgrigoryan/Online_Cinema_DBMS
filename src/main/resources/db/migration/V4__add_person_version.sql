-- Add optimistic locking column for person
ALTER TABLE person
ADD COLUMN IF NOT EXISTS version BIGINT NOT NULL DEFAULT 0;
