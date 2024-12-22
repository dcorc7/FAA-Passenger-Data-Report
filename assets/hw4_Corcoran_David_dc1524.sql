/* PROBLEM 1:
Find maximal departure delay in minutes for each airline. 

Sort results from smallest to largest maximumdelay. 

Output airline names and values of the delay. */

Select L_AIRLINE_ID.name, max(al_perf.DepDelayMinutes) as "MaxDepartureDelay"
From al_perf
Join L_AIRLINE_ID
On al_perf.DOT_ID_Reporting_Airline = L_AIRLINE_ID.ID
Group By L_AIRLINE_ID.name
Order By MaxDepartureDelay Asc;

/* Rows Returned: 17 */





/* PROBLEM 2:
Find maximal early departures in minutes for each airline. 

Sort results from largest to smallest. 

Output airline names.  */

Select L_AIRLINE_ID.name, (min(al_perf.DepDelay) * -1) as "MaxEarlyDeparture"
From al_perf
Join L_AIRLINE_ID
On al_perf.DOT_ID_Reporting_Airline = L_AIRLINE_ID.ID
Group By L_AIRLINE_ID.name
Order By MaxEarlyDeparture Desc;

/* Rows Returned: 17 */





/* PROBLEM 3:
Rank days of the week by the number of flights performed by all airlines 
on that day (1 is the busiest).

Output the day of the week names, number of flights and ranks in the rank 
increasing order.  */

SELECT L_WEEKDAYS.Day As DayOfWeek, count(al_perf.year) As FlightCount, Rank() Over (Order By count(al_perf.year) Desc) AS "Rank"
From al_perf
Join L_WEEKDAYS
On al_perf.DayOfWeek = L_WEEKDAYS.Code
Group By DayOfWeek;

/* Rows Returned: 7 */





/* PROBLEM 4:
Find the airport that has the highest average departure delay among all airports.
 
Consider 0 minutes delay for flights that departed early. 

Output one line of results: the airport name, code, and average delay.  */

With DelayAverageTable As (
    Select L_AIRPORT_ID.Name as AirportName, L_AIRPORT.Code as AirportCode, Avg(al_perf.DepDelay) as AverageDelay
    From al_perf
    Join L_AIRPORT_ID
    On al_perf.OriginAirportID = L_AIRPORT_ID.ID
    Join L_AIRPORT
    On L_AIRPORT_ID.Name = L_AIRPORT.Name
    Where al_perf.DepDelay > 0
    Group By AirportName, AirportCode
    Order By AverageDelay Desc
)
Select AirportName, AirportCode, max(AverageDelay)
From DelayAverageTable;

/* Rows Returned: 1 */





/* PROBLEM 5:
For each airline find an airport where it has the highest average departure delay.
 
Output an airline name, a name of the airport that has the highest average delay, 
and the value of that average delay.  */

With AvgAirlineDepartureDelays As (
	Select L_AIRLINE_ID.Name as AirlineName, L_AIRPORT_ID.Name As AirportName, Avg(al_perf.DepDelay) As AverageDelay
    From al_perf
    Join L_AIRLINE_ID
    On al_perf.DOT_ID_Reporting_Airline = L_AIRLINE_ID.ID
    Join L_AIRPORT_ID
    On al_perf.OriginAirportID = L_AIRPORT_ID.ID
    Where al_perf.DepDelay > 0
    Group By AirlineName, AirportName
    Order By AirlineName, AverageDelay Desc
)
Select AirlineName, AirportName, Max(AverageDelay)
From AvgAirlineDepartureDelays
Group By AirlineName;

/* Rows Returned: 17 */




/* PROBLEM 6a:
Check if your dataset has any canceled flights.  */

Select Cancelled, CancellationCode, count(CancellationCode) As CancelCodeCount
From al_perf
Where Cancelled > 0
Group By CancellationCode;

/* Rows Returned: 3 */





/* PROBLEM 6b:
If it does, what was the most frequent reason for each departure airport? 

Output airport name, the most frequent reason, and the number of 
cancelations for that reason.  */

With CancelledFlights As (
	Select L_AIRPORT_ID.Name As AirportName, L_CANCELATION.Reason As CancelReason, count(CancellationCode) As CancelCount 
    From al_perf
    Join L_AIRPORT_ID
    On al_perf.OriginAirportID = L_AIRPORT_ID.ID
    Join L_CANCELATION
    On al_perf.CancellationCode = L_CANCELATION.Code
    Where al_perf.Cancelled > 0
    Group By AirportName, CancelReason
    Order By AirportName, CancelCount Desc
)
Select AirportName, CancelReason, max(CancelCount)
From CancelledFlights
Group By AirportName;

/* Rows Returned: 300 */





/* PROBLEM 7:
Build a report that for each day output average number of flights over the 
preceding 3 days. */

With DailyFlightCounts As (
    Select al_perf.FlightDate As FlightDate, count(*) As FlightCount
    From al_perf
    Where FlightDate != "FlightDate"
    Group By al_perf.FlightDate
),
AvgFlightCountWindow As (
    Select FlightDate, FlightCount, Avg(FlightCount) Over (Order By FlightDate Rows 3 Preceding) As AvgFlightCountPrevious3Days
    From DailyFlightCounts
)
Select FlightDate, AvgFlightCountPrevious3Days
From AvgFlightCountWindow
Order By FlightDate;

/* Rows Returned: 30 */