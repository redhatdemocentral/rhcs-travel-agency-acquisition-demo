

CREATE TABLE IF NOT EXISTS flight_info
(
   flight_no      VARCHAR(24) NOT NULL,
   airline        VARCHAR(24),
   origin         VARCHAR(36),
   destination    VARCHAR(36),
   price          decimal(20,4),
   departs        timestamp,
   arrives        timestamp
);

DELETE FROM flight_info;

CREATE TABLE IF NOT EXISTS flight_bookings
(
   booking_id    VARCHAR(30) NOT NULL,
   flight_no       VARCHAR(24),
   departs       timestamp,
   arrives       timestamp
);

DELETE from flight_bookings;

INSERT INTO flight_info VALUES(880, 'United', 'Denver', 'NYC', 199.00, '2015-06-23 08:00:00', '2015-06-23 10:00:00');
INSERT INTO flight_info VALUES(881, 'United', 'NYC', 'Denver', 199.00, '2015-06-23 08:00:00', '2015-06-23 10:00:00');
INSERT INTO flight_info VALUES(1621, 'American', 'London', 'Edinburgh', 199.00, '2015-06-20 08:00:00', '2015-06-20 10:00:00');
INSERT INTO flight_info VALUES(1622, 'American', 'Edinburgh', 'London', 199.00, '2015-06-20 08:00:00', '2015-06-20 10:00:00');
INSERT INTO flight_info VALUES(1800, 'Delta', 'London', 'NYC', 1199.00, '2015-06-23 14:00:00', '2015-06-23 16:00:00');
INSERT INTO flight_info VALUES(1801, 'Delta', 'NYC', 'London', 1199.00, '2015-06-23 19:00:00', '2015-06-24 07:00:00');
INSERT INTO flight_info VALUES(1900, 'Virgin', 'Edinburgh', 'NYC', 1099.00, '2015-06-21 15:00:00', '2015-06-21 17:00:00');
INSERT INTO flight_info VALUES(1901, 'Virgin', 'NYC', 'Edinburgh', 1099.00, '2015-06-21 20:00:00', '2015-06-22 08:00:00');
INSERT INTO flight_info VALUES(600, 'BA', 'Edinburgh', 'Denver', 1599.00, '2015-06-22 15:00:00', '2015-06-22 18:00:00');
INSERT INTO flight_info VALUES(601, 'BA', 'Denver', 'Edinburgh', 1599.00, '2015-06-22 22:00:00', '2015-06-23 10:00:00');
INSERT INTO flight_info VALUES(700, 'BA', 'London', 'Denver', 999.00, '2015-06-25 16:00:00', '2015-06-25 19:00:00');
INSERT INTO flight_info VALUES(701, 'BA', 'Denver', 'London', 999.00, '2015-06-25 23:00:00', '2015-06-26 11:00:00');




    
