
--parks

CALL add_park(
    'Park Słoneczny',
    'Park z fontanną i placem zabaw',
    'POLYGON((19.90 50.05, 19.91 50.05, 19.91 50.06, 19.90 50.06, 19.90 50.05))'
);

CALL add_park(
    'Park Leśny',
    'Zadrzewiony park z trasami biegowymi',
    'POLYGON((19.92 50.07, 19.93 50.07, 19.93 50.08, 19.92 50.08, 19.92 50.07))'
);

CALL add_park(
    'Park Rzeczny',
    'Park wzdłuż rzeki z bulwarem',
    'POLYGON((19.915 50.045, 19.925 50.045, 19.925 50.055, 19.915 50.055, 19.915 50.045))'
);

--paths

CALL add_path(
    1,
    'Alejka główna',
    'LINESTRING(19.902 50.051, 19.908 50.058)'
);

CALL add_path(
    2,
    'Trasa leśna',
    'LINESTRING(19.922 50.071, 19.928 50.076)'
);

CALL add_path(
    3,
    'Bulwar nad rzeką',
    'LINESTRING(19.916 50.046, 19.924 50.054)'
);


--facility
CALL add_facility(1, 'Ławka', 19.905, 50.055);
CALL add_facility(1, 'Fontanna', 19.906, 50.056);
CALL add_facility(1, 'Plac zabaw', 19.907, 50.057);

CALL add_facility(2, 'Siłownia plenerowa', 19.923, 50.073);
CALL add_facility(2, 'Kosz na śmieci', 19.924, 50.074);

CALL add_facility(3, 'Pomost', 19.920, 50.050);
CALL add_facility(3, 'Stacja rowerowa', 19.918, 50.048);

--show
CALL show_parks_with_info();

CALL show_paths_in_park(1);
CALL show_paths_in_park(2);
CALL show_paths_in_park(3);

CALL show_facilities_in_park(1);
CALL show_facilities_in_park(2);
CALL show_facilities_in_park(3);

CALL show_facilities_nearby(19.906, 50.056, 300);
CALL show_facilities_nearby(19.923, 50.073, 200);

CALL show_parks_containing_point(19.905, 50.055);
CALL show_parks_containing_point(19.922, 50.074);
CALL show_parks_containing_point(19.920, 50.050);

CALL sum_paths_length_in_park(1);


CALL calculate_distance_between_facilities(1, 3);


--create
CALL create_park_from_points(
    'Park Graniczny',
    'Park zbudowany z punktów granicznych',
    ARRAY[
        '19.901 50.051',
        '19.906 50.051',
        '19.906 50.057',
        '19.901 50.057'
    ]
);

CALL create_path_from_points(1, 'Nowa Ścieżka', ARRAY[
    '19.901 50.051',
    '19.903 50.053',
    '19.905 50.055'
]);

CALL create_facility_from_point(1, 'Stojak rowerowy', '19.908 50.058');


--translate      
CALL translate_facility(1, 10, 0);        
     
