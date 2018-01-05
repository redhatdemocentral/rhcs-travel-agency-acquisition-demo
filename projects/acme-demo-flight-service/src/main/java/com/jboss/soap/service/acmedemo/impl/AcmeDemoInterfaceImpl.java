package com.jboss.soap.service.acmedemo.impl;


import java.math.BigDecimal;
import java.sql.Connection;
import java.util.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
//added for Teiid
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Random;

import javax.jws.WebService;

import com.jboss.soap.service.acmedemo.AcmeDemoInterface;
import com.jboss.soap.service.acmedemo.Flight;
import com.jboss.soap.service.acmedemo.FlightRequest;


@WebService(serviceName = "AcmeDemoService", endpointInterface = "com.jboss.soap.service.acmedemo.AcmeDemoInterface", targetNamespace = "http://service.soap.jboss.com/AcmeDemo/")
public class AcmeDemoInterfaceImpl implements AcmeDemoInterface {
	private static SimpleDateFormat FORMAT=new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

	static Connection CONNECTION = null;
	
	private static Flight lastSearched = null;
	
	static {
		createConnection();
	}
	public Flight listAvailablePlanes(FlightRequest in) {
		
		System.out.println("===== listAvailablePlanes:" + in.toString());
		
		createConnection();
		
		String sql = "Select distinct flight_no, airline, origin, destination, price, departs, arrives from Flight_info where ";
		
		int posStartCity = 0;
		int posEndCity = 0;
		int posStartDate = 0;
		int posEndDate = 0;
		int pos = 0;
		String andCond = "";
		if (in.getStartCity() != null) {
			posStartCity = ++pos;
			sql += " Origin = ? "; 
			andCond = " and ";
		}
		
		if (in.getEndCity() != null) {
			posEndCity = ++pos;
			sql += andCond + " Destination = ? "; 
//			andCond = " and ";
		}		
	
		if (in.getStartDate() != null && in.getStartDate().trim().length() > 0) {
			posStartDate = ++pos;
		}		
		
		if (in.getEndDate() != null && in.getEndDate().trim().length() > 0) {
			posEndDate = ++pos;
		}	
					
		PreparedStatement statement = null;
		try {
			statement = CONNECTION.prepareStatement(sql);
			
			if (posStartCity > 0) {
				statement.setString(posStartCity, in.getStartCity());
			}
			
			if (posEndCity > 0) {
				statement.setString(posEndCity, in.getEndCity());
			}
			/*
			if (posStartDate > 0) {
				statement.setTimestamp(posStartDate, convert(in.getStartDate() + " 00:00:00") );
			}
			
			if (posEndDate > 0) {
				statement.setTimestamp(posEndDate,  convert(in.getEndDate() + " 00:00:00") );	
			}	
			*/		
					
			ResultSet results=statement.executeQuery();
			
			Flight outbound = null;
			int i=0;
			if (results.next()) {
				outbound = new Flight();
	
				outbound.setCompany(results.getString(2));
				outbound.setPlaneId(Integer.valueOf(results.getString(1)) );
				outbound.setRatePerPerson(new BigDecimal(  results.getString(5) ));
				outbound.setStartCity(results.getString(3));
				outbound.setTargetCity(results.getString(4));
				if (posStartDate > 0) {
					outbound.setTravelDate(in.getStartDate());
				} else {
					outbound.setTravelDate(results.getString(6));
				}
				if (posEndDate > 0) {
					outbound.setArrivalDate(in.getEndDate());
				} else {
					outbound.setArrivalDate(results.getString(7));
				}
				
				System.out.println("Available Plane: - " + outbound.toString());
				
			}
			results.close();
		
			if (outbound == null) {
				System.out.println("No OUTBOUND for " + in.toString());
			} 
	
			System.out.println("=========================================================================");
			lastSearched = outbound;
			return outbound; 
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
		return new Flight();
	
//		Flight outbound = new Flight();
//		outbound.setCompany("EasyJet");
//		outbound.setPlaneId(12345);
//		outbound.setRatePerPerson(outboundBD);
//		outbound.setStartCity(startCity);
//		outbound.setTargetCity(endCity);
//		outbound.setTravelDate(in.getStartDate());
		
//		Flight inbound = new Flight();
//		inbound.setCompany("EasyJet");
//		inbound.setPlaneId(12345);
//		inbound.setRatePerPerson(inboundBD);
//		inbound.setStartCity(endCity);
//		inbound.setTargetCity(startCity);
//		inbound.setTravelDate(in.getEndDate());
//		
//		System.out.println("INBOUND FLIGHT variables set");
//		
//		
//		List<Flight> itinery = new ArrayList<Flight>();
//		itinery.add(outbound);
		

	}

	public String bookFlights(String in) {
		SimpleDateFormat format=new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		
		SessionIdentifierGenerator bookingRef = new SessionIdentifierGenerator();
		String refNum = bookingRef.nextSessionId();

		System.out.println("Booking Flight: " + refNum + "(" + in + ")");
		System.out.println();

		createConnection();
		
		String sql = "INSERT INTO flight_bookings(booking_id, flight_no, departs, arrives ) VALUES(?, ?, ?, ?)";
		PreparedStatement statement =  null;
		try {
			statement = CONNECTION.prepareStatement(sql);
			
			statement.setString(1, refNum);
			if (lastSearched != null ){
				statement.setInt(2, lastSearched.getPlaneId());
				statement.setTimestamp(3, (lastSearched.getTravelDate() != null ? convert(lastSearched.getTravelDate() + " 00:00:00") : convert("2015-12-20" + " 00:00:00")) );
				statement.setTimestamp(4, (lastSearched.getArrivalDate() != null ? convert(lastSearched.getArrivalDate() + " 00:00:00") : convert("2015-12-29" + " 00:00:00")) );
			} else {
				statement.setInt(2, 880);
				statement.setTimestamp(3,  convert("2015-12-20" + " 00:00:00") );
				statement.setTimestamp(4, convert("2015-12-29" + " 00:00:00") );
			}
				
			int results=statement.executeUpdate();
			
			statement.close();
		
			if (results == 0) {
				System.out.println("Insert issue, Flight: " + refNum + " was not inserted");
			} else {
				System.out.println("Your RESERVATION NUMBER is: "+ refNum);
				System.out.println("SUCCESS: Your flight is now reserved.");
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
		
		System.out.println("===== cancelBooking:" + in);

		
		if (in == null)
			throw new IllegalArgumentException("No booking found");
		
		createConnection();
		
		String sql = "DELETE from flight_bookings WHERE booking_id = ?";
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