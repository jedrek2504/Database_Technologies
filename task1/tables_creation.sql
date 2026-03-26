CREATE EXTENSION IF NOT EXISTS postgis;


CREATE TABLE parks (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    area GEOMETRY(POLYGON, 4326) NOT NULL,
    description TEXT
);

CREATE TABLE paths (
    id SERIAL PRIMARY KEY,
    park_id INTEGER REFERENCES parks(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    trail GEOMETRY(LINESTRING, 4326) NOT NULL
);

CREATE TABLE facilities (
    id SERIAL PRIMARY KEY,
    park_id INTEGER REFERENCES parks(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    location GEOMETRY(POINT, 4326) NOT NULL
);

CREATE INDEX idx_parks_area ON parks USING GIST (area);
CREATE INDEX idx_paths_trail ON paths USING GIST (trail);
CREATE INDEX idx_facilities_location ON facilities USING GIST (location);
