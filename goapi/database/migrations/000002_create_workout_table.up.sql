BEGIN;

CREATE TABLE IF NOT EXISTS workout (
    workout_uid UUID NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TYPE metric AS ENUM ('minute', 'meter');

CREATE TABLE IF NOT EXISTS workout_parts (
   workout_uid UUID NOT NULL REFERENCES workout(workout_uid),
   intensity_uid UUID NOT NULL REFERENCES intensity(intensity_uid),
   "order" INT NOT NULL,
   distance INT NOT NULL,
   metric metric,
   PRIMARY KEY (workout_uid, intensity_uid, "order") -- change to only workout_uid and "order"
);

COMMIT;
