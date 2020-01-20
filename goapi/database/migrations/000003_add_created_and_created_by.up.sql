BEGIN;

SET timezone = 'Europe/Oslo';

ALTER TABLE workout RENAME COLUMN profile_uid TO created_by_uid;
ALTER TABLE workout_parts RENAME COLUMN profile_uid TO created_by_uid;
ALTER TABLE intensity RENAME COLUMN profile_uid TO created_by_uid;

ALTER TABLE profile ADD COLUMN created_at timestamptz NOT NULL DEFAULT NOW();
ALTER TABLE workout ADD COLUMN created_at timestamptz NOT NULL DEFAULT NOW();
ALTER TABLE workout_parts ADD COLUMN created_at timestamptz NOT NULL DEFAULT NOW();
ALTER TABLE intensity ADD COLUMN created_at timestamptz NOT NULL DEFAULT NOW();
ALTER TABLE record ADD COLUMN created_at timestamptz NOT NULL DEFAULT NOW();

COMMIT;