package acme.service.soap.hotelws.impl;


import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.util.Random;
import java.util.Date;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.jws.WebService;

import acme.service.soap.hotelws.HotelRequest;
import acme.service.soap.hotelws.HotelWS;
import acme.service.soap.hotelws.Resort;

@WebService(serviceName = "HotelWS", endpointInterface = "acme.service.soap.hotelws.HotelWS", targetNamespace = "http://soap.service.acme/HotelWS/")
public class HotelWSImpl implements HotelWS {
	private static SimpleDateFormat FORMAT =new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

	static Connection CONNECTION = null;
	
	private static Resort lastSearched = null;
	
	static {
		
		lastSearched = new Resort();
		lastSearched.setHotelId(new Integer(10));
		lastSearched.setAvailableFrom("2015-12-20");
		lastSearched.setAvailableTo("2015-12-29");
		
		createConnection();
	}
	public String bookHotel(String in) {
		
		SessionIdentifierGenerator bookingRef = new SessionIdentifierGenerator();
		String refNum = bookingRef.nextSessionId();
		
		System.out.println("Booking Hotel: " + refNum + "(" + in + ")");
		System.out.println();
		
		createConnection();
		
		String sql = "INSERT INTO hotel_bookings(booking_id, hotel_id, arrive, depart ) VALUES(?, ?, ?, ?)";
		PreparedStatement statement =  null;
		try {
			statement = CONNECTION.prepareStatement(sql);
			
			statement.setString(1, refNum);
			if (lastSearched != null) {
				statement.setInt(2, (lastSearched.getHotelId() != null ? lastSearched.getHotelId() : 10) );
				statement.setTimestamp(3, (lastSearched.getAvailableFrom() != null ? convert(lastSearched.getAvailableFrom() + " 00:00:00") : convert("2015-12-20" + " 00:00:00"))  );
				statement.setTimestamp(4, (lastSearched.getAvailableTo() != null ? convert(lastSearched.getAvailableTo() + " 00:00:00") : convert("2015-12-29" + " 00:00:00"))  ); 
			} else {
				statement.setInt(2, 10);
				statement.setTimestamp(3,  convert("2015-12-20" + " 00:00:00") );
				statement.setTimestamp(4,  convert("2015-12-29" + " 00:00:00") );
			}

			int results=statement.executeUpdate();
			
			statement.close();
		
			if (results == 0) {
				System.out.println("Insert issue, Hotel Request: " + refNum + " was not inserted");
			} else {
				System.out.println("Your Hotel RESERVATION NUMBER is: "+ refNum);
				System.out.println("SUCCESS: Your Hotel is now reserved.");
			}
	
			System.out.println("=========================================================================");

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (statement != null)
				try {
					statement.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		}
		
		return refNum;
	}

	
	public int cancelBooking(String in) {
		int cancelCharge = 0;
		final Random random = new Random();
		
		System.out.println("===== Hotel cancelBooking:" + in);

		
		if (in == null)
			throw new IllegalArgumentException("No hotel booking specified");
		
		createConnection();
		
		String sql = "DELETE from hotel_bookings WHERE booking_id = ?";
		PreparedStatement statement =  null;
		try {
			statement = CONNECTION.prepareStatement(sql);
			
			statement.setString(1, in);

			int results=statement.executeUpdate();
			
			statement.close();
		
			if (results == 0) {
				System.out.println("Booking for Ref " + in + " was not deleted");
			} else {
				System.out.println("Cancelled Booking for Ref: " + in);
			}
	
			System.out.println("=========================================================================");

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (statement != null)
				try {
					statement.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		}
			
		cancelCharge = random.nextInt((10-5)+1) + 5;		
		
		return cancelCharge;
	}
		

	public Resort getAvailableHotel(HotelRequest in) {
		System.out.println("===== getAvailableHotel:" + in.toString());

		Resort hotel = new Resort();
		
		String hotelCity = in.getTargetCity();	
		
			createConnection();
			
			
			String sql = "Select distinct hotel_id, hotel_name, rate, city from hotel_info where city = ? ";
		
			PreparedStatement statement = null;
			try {
				statement = CONNECTION.prepareStatement(sql);
				
				statement.setString(1, in.getTargetCity());
						
				ResultSet results=statement.executeQuery();
				
				int i=0;
				if (results.next()) {
					
					hotel.setHotelId(results.getInt(1));
					hotel.setHotelName(results.getString(2));
					hotel.setRatePerPerson(results.getDouble(3));
					hotel.setHotelCity(results.getString(4));
					hotel.setAvailableFrom(in.getStartDate());
					hotel.setAvailableTo(in.getEndDate());

					
					System.out.println("Available Hotel: - " + hotel.toString());
					
				}
				results.close();

				System.out.println("=========================================================================");
 
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} finally {
				
				if (statement != null)
					try {
						statement.close();
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
			}
		
			lastSearched = hotel;
			return hotel;
		
	}
	
	public static void createConnection() {
		if (CONNECTION != null) {
			if (isAlive()) return;
		}
		System.out.println("== Connecting to DV to pull federated data  ==============");
		String url = "jdbc:teiid:TravelVDB@mm://localhost:31100";
		try {
			Class.forName("org.teiid.jdbc.TeiidDriver");
			CONNECTION=DriverManager.getConnection(url,"teiidUser","admin_24");
		} catch (SQLException sqe) {
			sqe.printStackTrace();
			return;
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return;
		}
	}
	
	private static boolean isAlive() {
		Statement s = null;
		try {
			s = CONNECTION.createStatement();
			s.execute("Select 1");
			return true;
		} catch (SQLException e) {
			CONNECTION = null;
			return false;
		} finally {
			try {
				if (s!=null) s.close();
			} catch (Exception e) {
				// do nothing
			}
		}
	}
	
	private Timestamp convert(String indate) {
		 Date date;
		try {
			date = FORMAT.parse(indate);
			return new Timestamp(date.getTime());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return new Timestamp((new Date()).getTime());

	}
}