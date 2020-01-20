BEGIN;

ALTER TABLE workout RENAME COLUMN created_by_uid TO  profile_uid;
ALTER TABLE workout_parts RENAME COLUMN created_by_uid TO  profile_uid;
ALTER TABLE intensity RENAME COLUMN created_by_uid TO  profile_uid;

ALTER TABLE profile DROP COLUMN created_at;
ALTER TABLE workout DROP COLUMN created_at;
ALTER TABLE workout_parts DROP COLUMN created_at;
ALTER TABLE intensity DROP COLUMN created_at;
ALTER TABLE record DROP COLUMN created_at;

COMMIT;