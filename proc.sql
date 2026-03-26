CREATE OR REPLACE PROCEDURE add_park(
    p_name TEXT,
    p_description TEXT,
    p_wkt TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    geom geometry;
BEGIN
    geom := ST_GeomFromText(p_wkt, 4326);

    IF NOT ST_IsValid(geom) THEN
        RAISE EXCEPTION 'Nieprawidłowa geometria.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM parks
        WHERE name = p_name AND ST_Equals(area, geom)
    ) THEN
        RAISE NOTICE 'Park "%" już istnieje.', p_name;
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM parks
        WHERE ST_Intersects(area, geom)
    ) THEN
        RAISE EXCEPTION 'Nowy park przecina się z istniejącym parkiem.';
    END IF;

    INSERT INTO parks (name, description, area)
    VALUES (p_name, p_description, geom);

    RAISE NOTICE 'Dodano park: %', p_name;
END;
$$;


CREATE OR REPLACE PROCEDURE add_path(
    p_park_id INT,
    p_name TEXT,
    p_wkt TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    geom geometry;
    park_geom geometry;
BEGIN
    geom := ST_GeomFromText(p_wkt, 4326);

    IF NOT ST_IsValid(geom) THEN
        RAISE EXCEPTION 'Nieprawidłowa geometria.';
    END IF;

    SELECT area INTO park_geom FROM parks WHERE id = p_park_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono parku o ID %', p_park_id;
    END IF;

    IF NOT ST_Contains(park_geom, geom) THEN
        RAISE EXCEPTION 'Ścieżka nie znajduje się w całości w granicach parku ID %', p_park_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM paths
        WHERE park_id = p_park_id AND name = p_name AND ST_Equals(trail, geom)
    ) THEN
        RAISE NOTICE 'Ścieżka "%" w parku ID: % już istnieje.', p_name, p_park_id;
    ELSE
        INSERT INTO paths (park_id, name, trail)
        VALUES (p_park_id, p_name, geom);
        RAISE NOTICE 'Dodano ścieżkę "%" do parku ID: %', p_name, p_park_id;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE add_facility(
    p_park_id INT,
    p_type TEXT,
    p_lon DOUBLE PRECISION,
    p_lat DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    geom geometry;
    park_geom geometry;
BEGIN
    geom := ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326);

    IF NOT ST_IsValid(geom) THEN
        RAISE EXCEPTION 'Nieprawidłowa geometria punktowa.';
    END IF;

    SELECT area INTO park_geom FROM parks WHERE id = p_park_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono parku o ID %', p_park_id;
    END IF;

    IF NOT ST_Contains(park_geom, geom) THEN
        RAISE EXCEPTION 'Obiekt nie znajduje się w granicach parku ID %', p_park_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM facilities
        WHERE park_id = p_park_id AND type = p_type AND ST_Equals(location, geom)
    ) THEN
        RAISE NOTICE 'Obiekt typu "%" w parku ID: % już istnieje w tej lokalizacji (%,%)', p_type, p_park_id, p_lon, p_lat;
    ELSE
        INSERT INTO facilities (park_id, type, location)
        VALUES (p_park_id, p_type, geom);
        RAISE NOTICE 'Dodano obiekt typu "%" do parku ID: %, współrzędne: (%,%)', p_type, p_park_id, p_lon, p_lat;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE show_parks_with_info()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Lista parków:';
    FOR r IN
        SELECT 
            id, 
            name, 
            description,
            ROUND(CAST(ST_Area(ST_Transform(area, 3857)) / 1000000 AS NUMERIC), 2) AS area_km2,
            ST_X(ST_Centroid(area)) AS center_x,
            ST_Y(ST_Centroid(area)) AS center_y
        FROM parks
    LOOP
        RAISE NOTICE 'ID: %, Nazwa: %, Opis: %, Powierzchnia: % km², Punkt centralny: (%,%)',
                     r.id, r.name, r.description, r.area_km2, r.center_x, r.center_y;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE show_paths_in_park(p_park_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Ścieżki w parku ID: %', p_park_id;
    FOR r IN
        SELECT 
            id,
            name,
            ROUND(CAST(ST_Length(ST_Transform(trail, 3857)) AS NUMERIC), 2) AS length_m,
            ST_X(ST_StartPoint(trail)) AS start_x,
            ST_Y(ST_StartPoint(trail)) AS start_y,
            ST_X(ST_EndPoint(trail)) AS end_x,
            ST_Y(ST_EndPoint(trail)) AS end_y
        FROM paths
        WHERE park_id = p_park_id
    LOOP
        RAISE NOTICE 'ID: %, Nazwa: %, Długość: % m, Początek: (%,%), Koniec: (%,%)',
                     r.id, r.name, r.length_m, r.start_x, r.start_y, r.end_x, r.end_y;
    END LOOP;
END;
$$;



CREATE OR REPLACE PROCEDURE show_facilities_in_park(p_park_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Obiekty w parku ID: %', p_park_id;
    FOR r IN
        SELECT id, type, ST_X(location) AS lon, ST_Y(location) AS lat
        FROM facilities
        WHERE park_id = p_park_id
    LOOP
        RAISE NOTICE 'ID: %, Typ: %, Pozycja: (%,%)', r.id, r.type, r.lon, r.lat;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE show_paths_in_park(p_park_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Ścieżki w parku ID: %', p_park_id;
    FOR r IN
        SELECT id, name,
               ROUND(CAST(ST_Length(ST_Transform(trail, 3857)) AS NUMERIC), 2) AS length_m
        FROM paths
        WHERE park_id = p_park_id
    LOOP
        RAISE NOTICE 'ID: %, Nazwa: %, Długość: % m', r.id, r.name, r.length_m;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE show_facilities_nearby(
    p_lon DOUBLE PRECISION,
    p_lat DOUBLE PRECISION,
    p_radius_m DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Obiekty w promieniu %m od punktu (%,%)', p_radius_m, p_lon, p_lat;

    FOR r IN
        SELECT id, type,
               ROUND(CAST(ST_Distance(
                   ST_Transform(location, 3857),
                   ST_Transform(ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326), 3857)
               ) AS NUMERIC), 2) AS distance_m
        FROM facilities
        WHERE ST_DWithin(
            ST_Transform(location, 3857),
            ST_Transform(ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326), 3857),
            p_radius_m
        )
    LOOP
        RAISE NOTICE 'ID: %, Typ: %, Odległość: % m', r.id, r.type, r.distance_m;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE show_parks_containing_point(
    p_lon DOUBLE PRECISION,
    p_lat DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'Sprawdzam punkt (%,%)...', p_lon, p_lat;
    FOR r IN
        SELECT id, name, description
        FROM parks
        WHERE ST_Contains(
            area,
            ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326)
        )
    LOOP
        RAISE NOTICE 'Park ID: %, Nazwa: %, Opis: %', r.id, r.name, r.description;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE sum_paths_length_in_park(p_park_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_length NUMERIC;
BEGIN
    SELECT ROUND(SUM(CAST(ST_Length(ST_Transform(trail, 3857)) AS NUMERIC)), 2)
    INTO total_length
    FROM paths
    WHERE park_id = p_park_id;

    IF total_length IS NULL THEN
        RAISE NOTICE 'Brak ścieżek w parku ID: %', p_park_id;
    ELSE
        RAISE NOTICE 'Łączna długość ścieżek w parku ID %: % metrów', p_park_id, total_length;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE calculate_distance_between_facilities(
    p_facility_id_1 INT,
    p_facility_id_2 INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    geom1 geometry;
    geom2 geometry;
    dist_m NUMERIC;
BEGIN
    SELECT location INTO geom1 FROM facilities WHERE id = p_facility_id_1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono obiektu o ID %', p_facility_id_1;
    END IF;

    SELECT location INTO geom2 FROM facilities WHERE id = p_facility_id_2;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono obiektu o ID %', p_facility_id_2;
    END IF;

    dist_m := ROUND(
        CAST(
            ST_Distance(
                ST_Transform(geom1, 3857),
                ST_Transform(geom2, 3857)
            ) AS NUMERIC
        ), 2
    );

    RAISE NOTICE 'Odległość między obiektem ID % a obiektem ID % wynosi % metrów.',
                 p_facility_id_1, p_facility_id_2, dist_m;
END;
$$;


CREATE OR REPLACE PROCEDURE create_park_from_points(
    p_name TEXT,
    p_description TEXT,
    p_point_list TEXT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    coords TEXT := '';
    i INT;
BEGIN
    FOR i IN 1 .. array_length(p_point_list, 1) LOOP
        coords := coords || p_point_list[i] || ', ';
    END LOOP;
    coords := coords || p_point_list[1];
    coords := 'POLYGON((' || coords || '))';

    CALL add_park(p_name, p_description, coords);
END;
$$;

CREATE OR REPLACE PROCEDURE create_facility_from_point(
    p_park_id INT,
    p_type TEXT,
    p_point TEXT 
)
LANGUAGE plpgsql
AS $$
DECLARE
    lon DOUBLE PRECISION;
    lat DOUBLE PRECISION;
BEGIN

    lon := split_part(p_point, ' ', 1)::DOUBLE PRECISION;
    lat := split_part(p_point, ' ', 2)::DOUBLE PRECISION;

    CALL add_facility(p_park_id, p_type, lon, lat);
END;
$$;


CREATE OR REPLACE PROCEDURE create_path_from_points(
    p_park_id INT,
    p_path_name TEXT,
    p_points TEXT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    coords TEXT := '';
    i INT;
    geom geometry;
BEGIN
    FOR i IN 1 .. array_length(p_points, 1) LOOP
        coords := coords || p_points[i];
        IF i < array_length(p_points, 1) THEN
            coords := coords || ', ';
        END IF;
    END LOOP;

    geom := ST_GeomFromText('LINESTRING(' || coords || ')', 4326);

    CALL add_path(p_park_id, p_path_name, ST_AsText(geom));
END;
$$;

CREATE OR REPLACE PROCEDURE translate_facility(
    p_facility_id INT,
    p_move_x_m DOUBLE PRECISION,
    p_move_y_m DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    original geometry;
    translated geometry;
    v_park_id INT;
    park_geom geometry;
BEGIN
    SELECT location, park_id INTO original, v_park_id FROM facilities WHERE id = p_facility_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono obiektu o ID %', p_facility_id;
    END IF;

    translated := ST_Transform(
        ST_Translate(ST_Transform(original, 3857), p_move_x_m, p_move_y_m),
        4326
    );

    SELECT area INTO park_geom FROM parks WHERE id = v_park_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono przypisanego parku ID %', v_park_id;
    END IF;

    IF NOT ST_Contains(park_geom, translated) THEN
        RAISE EXCEPTION 'Nowa lokalizacja znajduje się poza granicami parku ID %', v_park_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM facilities
        WHERE id != p_facility_id AND park_id = v_park_id AND ST_Equals(location, translated)
    ) THEN
        RAISE EXCEPTION 'Nowa lokalizacja koliduje z innym obiektem w tym samym parku.';
    END IF;

    UPDATE facilities SET location = translated WHERE id = p_facility_id;

    RAISE NOTICE 'Obiekt ID % przesunięto o (X: % m, Y: % m)', p_facility_id, p_move_x_m, p_move_y_m;
END;
$$;


