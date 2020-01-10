BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS intensity (
   intensity_uid UUID NOT NULL PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   description TEXT,
   coefficient FLOAT NOT NULL
);

COMMIT;
