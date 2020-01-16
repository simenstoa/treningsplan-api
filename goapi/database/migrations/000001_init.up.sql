BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS profile (
    profile_uid UUID NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    vdot INT
);

CREATE TABLE IF NOT EXISTS intensity (
   intensity_uid UUID NOT NULL PRIMARY KEY,
   profile_uid UUID NOT NULL REFERENCES profile(profile_uid),
   name VARCHAR(50) NOT NULL,
   description TEXT,
   coefficient FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS workout (
    workout_uid UUID NOT NULL PRIMARY KEY,
    profile_uid UUID NOT NULL REFERENCES profile(profile_uid),
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TYPE  metric  AS ENUM  ('second', 'meter') ;

CREATE TABLE IF NOT EXISTS workout_parts (
    workout_uid UUID NOT NULL REFERENCES workout(workout_uid) ON DELETE CASCADE,
    intensity_uid UUID NOT NULL REFERENCES intensity(intensity_uid),
    profile_uid UUID NOT NULL REFERENCES profile(profile_uid),
    "order" INT NOT NULL,
    distance INT NOT NULL,
    metric metric,
    PRIMARY KEY (workout_uid, "order")
);

CREATE TABLE IF NOT EXISTS record (
    record_uid UUID NOT NULL PRIMARY KEY,
    profile_uid UUID NOT NULL REFERENCES profile(profile_uid) ON DELETE CASCADE,
    race VARCHAR(50) NOT NULL,
    duration INT
);

INSERT INTO profile (profile_uid, first_name, last_name, vdot) VALUES ('e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Simen', 'Støa', 57);

INSERT INTO record (record_uid, profile_uid, race, duration) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', '10k', 2216);
INSERT INTO record (record_uid, profile_uid, race, duration) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', '5k', 1070);
INSERT INTO record (record_uid, profile_uid, race, duration) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Half-marathon', 4970);
INSERT INTO record (record_uid, profile_uid, race, duration) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Marathon', 11855);

INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES ('cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Easy', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 0.2);
INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Marathon', '80%-89% of max hearth rate, or 75%-84% of VDOT.', 0.4);
INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Threshold', 'Lactate threshold. 88%-92% of max hearth rate, or 83%-88% of VDOT.', 0.6);
INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', '10k', '10k race pace. Between threshold and interval speed.', 0.8);
INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES ('d1fba4bf-44bc-4e30-bddb-cffed83fec39', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Interval', '97.5-100% of max heart rate, or 95%-100% of VDOT.', 1.0);
INSERT INTO intensity (intensity_uid, profile_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 'Repetition', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 1.5);

INSERT INTO workout (workout_uid, profile_uid, name, description) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', '4x4 minute intervals', '10 min WU/CD. 4 min intervals with 3 minutes pauses between.');

INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 0, 600, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 8, 600, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 2, 180, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 4, 180, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'cf5f1258-b3b1-47c8-bbc0-47e83b9fc408', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 6, 180, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'd1fba4bf-44bc-4e30-bddb-cffed83fec39', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 1, 240, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'd1fba4bf-44bc-4e30-bddb-cffed83fec39', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 3, 240, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'd1fba4bf-44bc-4e30-bddb-cffed83fec39', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 5, 240, 'second');
INSERT INTO workout_parts (workout_uid, intensity_uid, profile_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'd1fba4bf-44bc-4e30-bddb-cffed83fec39', 'e64eb995-5238-4ca0-8abb-f392bef00e1a', 7, 240, 'second');

COMMIT;
