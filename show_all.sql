SELECT area AS geom, name, 'park' AS type FROM parks
UNION ALL
SELECT trail AS geom, name, 'path' FROM paths
UNION ALL
SELECT location AS geom, type, 'facility' FROM facilities;
