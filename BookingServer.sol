// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./Flights.sol";
import "./BookingContract.sol";

/**
 *	@author GreatLearningGroup3
 * @title BookingServer
 * @dev This contract serves as an abtraction for two entities namely airlines and its passengers 
 * for performing various flight and its booking activities.
 *
 * For an Airline, flight activities comprises of updating flight status, view flight booking list
 * For a Passenger, flight activities comprises of booking flight ticket, cancel booking
 *
 * NOTE: This contract assumes that ETH to be used for tranfer of funds between entities. Also
 * exact value of the ticket in ethers is expected.
 */

contract BookingServer {

    address public customer;
    Flight flight;
    BookingContract booking;
	
	event AmountTransferred(address from, address to, uint amountInEther, string transferReason);
    event BookingComplete(address customer, string flightId);
    event FlightCancelled(address airlines, string flightId);

	modifier onlyCustomer(){
        require(msg.sender == customer, "Only customer initiates the flight booking");
        _;
    }

    modifier onlyAirlines() {
        require(msg.sender != customer, "Only airlines can do this action");
        _;
    }

    modifier onlyValidAddress(address addr) {
        require(addr != address(0));
        _;
    }

    modifier onlyValidFlightNumber(string memory _flightNumber) {
        Flight.FlightData memory flightData = flight.getFlightData(_flightNumber);
        require(bytes(flightData.flightNumber).length > 0, "Invalid flight number");
        _;
    }

    modifier onlyValidFlightNumberAndState(string memory _flightNumber) {
        Flight.FlightData memory flightData = flight.getFlightData(_flightNumber);
         require(bytes(flightData.flightNumber).length > 0, "Invalid flight number");
        require(flightData.state != Flight.FlightState.CANCELLED, "Flight is Cancelled");
        _;
    }

    modifier onlyExactTicketAmount(string memory _flightNumber) {
        Flight.FlightData memory flightData = flight.getFlightData(_flightNumber);
        require(msg.value == flightData.ethAmount *10**18, "Exact booking ethers needed");
        _;
    }
	
	modifier onlySufficientFunds() {
		require(msg.sender.balance > msg.value, "Insufficient funds to book the ticket");
		_;
	}
	
	constructor(address _customer) onlyValidAddress(_customer) onlyAirlines {
        customer = _customer;
        flight = new Flight();
        flight.populateFlights();
    }

    function initiateBooking(address payable _airlines, string memory _flightNumber, Flight.SeatCategory _seatCategory) 
        public 
        payable 
        onlyCustomer
		onlyValidFlightNumberAndState(_flightNumber)
		onlySufficientFunds
        onlyExactTicketAmount(_flightNumber) returns(string memory){
		
        _airlines.transfer(msg.value);
		emit AmountTransferred(msg.sender, _airlines, msg.value, "Booking amount");
        booking = new BookingContract(msg.sender, _airlines);
        string memory booking_comment = booking.bookTicket(msg.sender, _seatCategory, _flightNumber);
		emit BookingComplete(msg.sender, _flightNumber);
        return booking_comment;
    }
	
	function getBookingData() 
        public view
        onlyAirlines returns (address, string memory, BookingContract.BookingState) {
        return booking.getBookingData();
    }

    function cancelBooking() 
        public 
        onlyCustomer {
        booking.cancelBooking();
    }

	function cancelFlight(string memory _flightNumber) 
        public 
        payable
		onlyAirlines
        onlyValidFlightNumberAndState(_flightNumber) 
        onlyValidFlightNumber(_flightNumber) {
        
        flight.setFlightState(_flightNumber, Flight.FlightState.CANCELLED);
        emit FlightCancelled(msg.sender, _flightNumber);
		
		payable(customer).transfer(msg.value);
		booking.flightCancelled();
        emit AmountTransferred(msg.sender, customer, msg.value, "Flight Cancel Refund");   
    }

    function updateFlightStatus(string memory _flightNumber, Flight.FlightState _state) 
		public 
		onlyAirlines 
		onlyValidFlightNumber(_flightNumber){
		
        flight.setFlightState(_flightNumber, _state);
    }

	function getFlightData(string memory _flightNumber) 
        public view 
        onlyValidFlightNumber(_flightNumber) returns (Flight.FlightData memory) {
        return flight.getFlightData(_flightNumber);
    }

}