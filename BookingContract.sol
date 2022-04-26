// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./Flights.sol";

/// @author GreatLearningGroup3
/// @title BookingContract holding customer booking details
contract BookingContract {

    enum BookingState {INITIATED, PENDING, CONFIRMED, CANCELLED}
    
    struct BookingData {
        address customer;
        string confirmationId;
	    address airlines;
        BookingState state;
        string comment;
        Flight.SeatCategory seatCategory;
        string flightNumber;
    }

    BookingData bookingData;

    constructor(address _customer, address _airlines) {
        bookingData = BookingData({
                customer: _customer,
                confirmationId: '',
                airlines: _airlines,
                state: BookingState.INITIATED,
                comment: '',
                seatCategory: Flight.SeatCategory.ECONOMY,
                flightNumber: ''
        });
    }

	/// Confirms ticket booking and sets rest of the booking details
	/// @param _customer Customer for which booking is to be confirmed
	/// @param _seatCategory Seat category requested by the customer
	/// @param _flightNumber Flight for which booking is to be done
	/// @dev Method does not perform parameter validation and caller of this method needs to validate the same
    function bookTicket(address _customer, Flight.SeatCategory _seatCategory, string memory _flightNumber) public returns (string memory) {
        bookingData.confirmationId = "CONF1233455";
        bookingData.customer = _customer;
        bookingData.seatCategory = _seatCategory;
        bookingData.flightNumber = _flightNumber;
        bookingData.state = BookingState.CONFIRMED;
        bookingData.comment = string(abi.encodePacked("Booking confirmed with confirmation id ", bookingData.confirmationId, " for the flight ", _flightNumber));
        return bookingData.comment;
    }
	
	/// Get booking details for given customer
	/// @dev Method does not perform parameter validation and caller of this method needs to validate the same
	function getBookingData() public view returns (address, string memory, BookingState){
        return (bookingData.customer, bookingData.comment, bookingData.state);
    }

	/// Cancel booking for the confirmationId provided
	/// @dev Method does not perform parameter validation and caller of this method needs to validate the same
    function cancelBooking() public {
        //Requires current time is 2 hours before the flight time
        //Retrieve the booking based on either customer address or confirmationId
        //Calculate Refund and Penalty
        //Transfer funds to both the parties
        //Change the BookingState to Cancelled
       bookingData.state = BookingState.CANCELLED;
       bookingData.comment = string(abi.encodePacked("Booking cancelled for the customer ", msg.sender, "with confirmation id ", bookingData.confirmationId));

        //Remove the booking from the bookings List?
    }

    function flightCancelled() public {
        bookingData.state = BookingState.CANCELLED;
        bookingData.comment = string(abi.encodePacked("Booking cancelled for the customer ", msg.sender, 
        "with confirmation id ", bookingData.confirmationId));
    }
}

