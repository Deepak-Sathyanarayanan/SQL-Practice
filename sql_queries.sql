/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
FROM country_club.Facilities
WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(facid)
FROM country_club.Facilities
WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance
FROM  country_club.Facilities
WHERE membercost < (monthlymaintenance * .2)



/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid in (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, case when (monthlymaintenance > 100) then 'expensive' else 'cheap' end as cost
FROM country_club.Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT concat(firstname, ' ', surname, ' ', name) 
FROM country_club.Facilities a 
JOIN country_club.Bookings b 
ON a.facid = b.facid 
JOIN country_club.Members c 
ON b.memid=c.memid 
WHERE name IN ("Tennis Court 1", "Tennis Court 2")
GROUP BY 1
ORDER BY 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT a.surname AS member, c.name AS facility, CASE WHEN a.memid = 0 THEN b.slots * c.guestcost ELSE b.slots * c.membercost END AS cost
FROM  Members a
JOIN  Bookings b
ON a.memid = b.memid
JOIN  Facilities c 
ON b.facid = c.facid
WHERE b.starttime >=  '2012-09-14'
AND b.starttime <  '2012-09-15'
AND ((a.memid = 0 AND b.slots * c.guestcost >30) OR (a.memid != 0 AND b.slots * c.membercost >30))
ORDER BY cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT member, facility, cost
FROM (

SELECT a.surname AS member, c.name AS facility, CASE WHEN a.memid =0 THEN b.slots * c.guestcost ELSE b.slots * c.membercost END AS cost
FROM  Members a
JOIN  Bookings b 
ON a.memid = b.memid
INNER JOIN  Facilities c 
ON b.facid = c.facid
WHERE b.starttime >=  '2012-09-14'
AND b.starttime <  '2012-09-15'
) AS bookings
WHERE cost >30
ORDER BY cost DESC



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, totalrevenue
FROM (
SELECT c.name, SUM(CASE WHEN memid =0 THEN slots * c.guestcost ELSE slots * membercost END ) AS totalrevenue
FROM  Bookings b
INNER JOIN  Facilities c 
ON b.facid = c.facid
GROUP BY c.name
)
AS selected_facilities
WHERE totalrevenue <=1000
ORDER BY totalrevenue
