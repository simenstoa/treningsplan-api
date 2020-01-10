INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Rest', 'Rest.', 0.0);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Easy', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 0.2);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Marathon', '80%-89% of max hearth rate, or 75%-84% of VDOT.', 0.4);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Threshold', 'Lactate threshold. 88%-92% of max hearth rate, or 83%-88% of VDOT.', 0.6);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), '10k', '10k race pace. Between threshold and interval speed.', 0.8);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Interval', '97.5-100% of max heart rate, or 95%-100% of VDOT.', 1.0);
INSERT INTO intensity (intensity_uid, name, description, coefficient) VALUES (uuid_generate_v4(), 'Repetition', '65%-79% of max hearth rate, or 59%-74% of VDOT.', 1.5);

INSERT INTO workout (workout_uid, name, description) VALUES (uuid_generate_v4(), '4x4 minute intervals', '10 min WU/CD. 4 min intervals with 3 minutes pauses between.');

INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'f19cbc3e-879e-41d2-87a2-b7b71796bb9d', 0, 10, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'f19cbc3e-879e-41d2-87a2-b7b71796bb9d', 8, 10, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'f19cbc3e-879e-41d2-87a2-b7b71796bb9d', 2, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'f19cbc3e-879e-41d2-87a2-b7b71796bb9d', 4, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', 'f19cbc3e-879e-41d2-87a2-b7b71796bb9d', 6, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', '441fc59a-4c1f-45d5-a763-ca634713867b', 1, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', '441fc59a-4c1f-45d5-a763-ca634713867b', 3, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', '441fc59a-4c1f-45d5-a763-ca634713867b', 5, 4, 'minute');
INSERT INTO workout_parts (workout_uid, intensity_uid, "order", distance, metric) VALUES ('a838d2b8-92d2-4ef0-95e0-b59d8a7c39dc', '441fc59a-4c1f-45d5-a763-ca634713867b', 7, 4, 'minute');