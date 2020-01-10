DROP TABLE intensity;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE intensity (
    intensity_uid UUID NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    coefficient FLOAT NOT NULL
);

INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Rest', 'Rest.', 0.0);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Easy', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 0.2);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Marathon', '80%-89% of max hearth rate, or 75%-84% of VDOT.', 0.4);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Threshold', 'Lactate threshold. 88%-92% of max hearth rate, or 83%-88% of VDOT.', 0.6);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), '10k', '10k race pace. Between threshold and interval speed.', 0.8);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Interval', '97.5-100% of max heart rate, or 95%-100% of VDOT.', 1.0);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Repetition', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 1.5);
