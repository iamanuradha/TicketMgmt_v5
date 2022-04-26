// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

/// @author GreatLearningGroup3
/// @title Flight contract holding flight details
contract Flight {

    enum FlightState {ON_TIME, CANCELLED, DELAYED}
    enum SeatCategory {ECONOMY, BUSINESS, PREMIUM}

    struct FlightData {
        string flightNumber;
        string flightTime;
        string from;
        string to;
        FlightState state;
		uint ethAmount;
    }

    mapping(string => FlightData) private flightsMap;

    FlightData flightData;

	/// Populates flights for the airlines
	/// @dev store flight data to flightsMap
    function populateFlights() public {
        flightsMap['EA007'] = FlightData("EA007", "15-05-2022 10:30", "LON", "HYD", FlightState.ON_TIME, 10);
        flightsMap['EA001'] = FlightData("EA001", "17-05-2022 10:30", "DXB", "HYD", FlightState.CANCELLED, 10);
        flightsMap['EA002'] = FlightData("EA002", "24-05-2022 10:30", "HYD", "LON", FlightState.DELAYED, 10);
    }

	/// Get flight data for given airlines and flightNumber
	/// @param _flightNumber Flight whose data is to be lookedup for
	/// @dev Method does not perform parameter validation and caller of this method needs to validate the same
    function getFlightData(string memory _flightNumber) public view returns(FlightData memory){
        return flightsMap[_flightNumber];
    }

	/// Sets the flight state
	/// @param _flightNumber Flight whose state is to be set
	/// @param _state Flight state to set
	/// @dev Method does not perform parameter validation and caller of this method needs to validate the same
    function setFlightState(string memory _flightNumber, Flight.FlightState _state) public{
       flightsMap[_flightNumber].state = _state;
    }
}
