
CREATE TABLE IF NOT EXISTS  hotel_bookings 
(
   booking_id    VARCHAR(30) NOT NULL,
   hotel_id      integer,
   arrive        timestamp,
   depart        timestamp
);

delete from hotel_bookings;

CREATE TABLE IF NOT EXISTS  hotel_info 
(
   hotel_id      integer NOT NULL,
   hotel_name    VARCHAR(24),
   rate          decimal(20,4),
   city          VARCHAR(36)
);

delete from hotel_info;

INSERT INTO HOTEL_INFO VALUES(10, 'Ritz Carlton', 499.00, 'NYC'); 
INSERT INTO HOTEL_INFO VALUES(12, 'Savoy', 399.00, 'London');
INSERT INTO HOTEL_INFO VALUES(14, 'Glenwood Springs', 359.00, 'Denver');
INSERT INTO HOTEL_INFO VALUES(16, 'The Scotsman', 499.00, 'Edinburgh');
SELECT * FROM HOTEL_INFO ORDER BY HOTEL_ID;

SELECT * FROM HOTEL_BOOKINGS ORDER BY BOOKING_ID;
