-- Active: 1747594140908@@127.0.0.1@5432@conservation_db
-- Creating Database
CREATE DATABASE conservation_db;

-- creating rangers table
CREATE TABLE rangers (
    ranger_id     SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    region        VARCHAR(100) NOT NULL
);

-- creating species table
CREATE TABLE species (
    species_id          SERIAL PRIMARY KEY,
    common_name         VARCHAR(100) NOT NULL,
    scientific_name     VARCHAR(150) NOT NULL,
    discovery_date      DATE         NOT NULL,
    conservation_status VARCHAR(50)  NOT NULL
);

-- creating sightings table
CREATE TABLE sightings (
    sighting_id   SERIAL PRIMARY KEY,
    species_id    INT NOT NULL REFERENCES species  (species_id) ON DELETE CASCADE,
    ranger_id     INT NOT NULL REFERENCES rangers  (ranger_id) ON DELETE CASCADE,
    location      VARCHAR(150) NOT NULL,
    sighting_time TIMESTAMP    NOT NULL,
    notes         TEXT
);

-- inserting data into rangers table
INSERT INTO rangers (ranger_id, name, region) VALUES
  (1, 'Alice Green', 'Northern Hills'),
  (2, 'Bob White',   'River Delta'),
  (3, 'Carol King',  'Mountain Range');

-- inserting data into species table
INSERT INTO species (species_id, common_name, scientific_name, discovery_date, conservation_status) VALUES
  (1, 'Snow Leopard',     'Panthera uncia',          '1775-01-01', 'Endangered'),
  (2, 'Bengal Tiger',     'Panthera tigris tigris',  '1758-01-01', 'Endangered'),
  (3, 'Red Panda',        'Ailurus fulgens',         '1825-01-01', 'Vulnerable'),
  (4, 'Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

-- inserting data into sightings table
INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
  (1, 1, 1, 'Peak Ridge',        '2024-05-10 07:45:00', 'Camera trap image captured'),
  (2, 2, 2, 'Bankwood Area',     '2024-05-12 16:20:00', 'Juvenile seen'),
  (3, 3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
  (4, 1, 2, 'Snowfall Pass',     '2024-05-18 18:30:00', NULL);

-- displaying data for each table
SELECT * from rangers;

SELECT * from species;

SELECT * from sightings;

-- Problem 1
INSERT INTO rangers (ranger_id,name, region) VALUES (4,'Derek Fox', 'Coastal Plains') 

-- Problem 2
SELECT count(DISTINCT species_id) AS "unique_species_count" FROM sightings;

-- Problem 3
SELECT * FROM sightings
    WHERE location ILIKE '%Pass%'

-- Problem 4
SELECT r.name, COUNT(s.sighting_id) AS "total_sightings" FROM rangers AS r
    INNER JOIN sightings AS s ON r.ranger_id = s.ranger_id
        GROUP BY r.name
            ORDER BY r.name ASC;

-- Problem 5
SELECT common_name FROM species AS sp
    WHERE NOT EXISTS(
        SELECT * FROM sightings AS si
            WHERE si.species_id = sp.species_id
    )
        
-- Problem 6
SELECT common_name, sighting_time, name FROM species AS sp
    INNER JOIN sightings AS si ON si.species_id= sp.species_id
        INNER JOIN rangers AS ra ON si.ranger_id= ra.ranger_id
        ORDER BY si.sighting_time DESC
            LIMIT 2;

-- Problem 7
UPDATE species SET conservation_status = 'Historic'
    WHERE EXTRACT(YEAR FROM discovery_date) < 1800;

-- Problem 8
CREATE OR REPLACE FUNCTION get_time_of_day(sighting_time TIMESTAMP)
RETURNS TEXT AS $$
BEGIN
  IF EXTRACT(HOUR FROM sighting_time) < 12 THEN
    RETURN 'Morning';
  ELSIF EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 16 THEN
    RETURN 'Afternoon';
  ELSE
    RETURN 'Evening';
  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT sighting_id, get_time_of_day(sighting_time) AS time_of_day FROM sightings
    ORDER BY sighting_id;

-- Problem 9
DELETE FROM rangers AS ra WHERE NOT EXISTS(
    SELECT * FROM sightings AS si
        WHERE  si.ranger_id = ra.ranger_id
)