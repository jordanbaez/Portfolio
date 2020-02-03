# analyse des retards des vols de la compagnie aérienne Virgin America début 2015
# la requete suivante permet de voir le nombre de retards cumulés par la compagnie chaque
# mois selon l'éaroport de décollage (DEPARTURES)
# et l'aéroport d'aterrissage (arrivals)

use virgin;

create temporary table late_dep
select vx.ORIGIN_AIRPORT, vx.MONTH, COUNT(*) AS LATE_DEP
from truck.vxflights vx
WHERE ARRIVAL_DELAY >=15
group by MONTH,ORIGIN_AIRPORT;

create temporary table late_arr
select vx.DESTINATION_AIRPORT, vx.MONTH, COUNT(*) AS LATE_ARR
from truck.vxflights vx
WHERE ARRIVAL_DELAY >=15
group by MONTH,DESTINATION_AIRPORT;

CREATE TABLE DEPARTURES
SELECT
  d.ORIGIN_AIRPORT, 
  SUM(CASE WHEN MONTH = '1' THEN LATE_DEP END) AS January,
  SUM(CASE WHEN MONTH = '2' THEN LATE_DEP END) AS February,
  SUM(CASE WHEN MONTH = '3' THEN LATE_DEP END) AS March
FROM truck.late_dep d
#WHERE ARRIVAL_DELAY >=15
GROUP BY ORIGIN_AIRPORT
order by ORIGIN_AIRPORT;

create table arrivals
select a.DESTINATION_AIRPORT,SUM(CASE WHEN MONTH = '1' THEN LATE_ARR END) AS January,
  SUM(CASE WHEN MONTH = '2' THEN LATE_ARR END) AS February,
  SUM(CASE WHEN MONTH = '3' THEN LATE_ARR END) AS March
from truck.late_arr a
group by DESTINATION_AIRPORT
order by DESTINATION_AIRPORT;

UPDATE DEPARTURES SET January=0 where ORIGIN_AIRPORT = 'PDX';
UPDATE DEPARTURES SET March=0   where ORIGIN_AIRPORT = 'PDX';
SELECT * FROM DEPARTURES;
#retards mensuels aux aéroports de départ
UPDATE arrivals SET march=0 where destination_airport = 'MCO';
select * from arrivals;
#retards mensuels aux aéroports d'arrivée


# création d'une nouvelle colonne dans le dataset de base où la valeur est 
# 1 si le retard rapporté n'est pas le 1er de la journée
# 0 si c'est le 1er retard de la journée pour l'aéroport en question

#drop temporary table nested;
create temporary table nested
select year, month, day, origin_airport, FLIGHT_NUMBER,arrival_time, (case when cnt=1 then 0 else 1 end) previous_delay 
from
(select v1.year, v1.month, v1.day, v1.ORIGIN_AIRPORT, v1.ARRIVAL_TIME, v1.FLIGHT_NUMBER, count(v2.ARRIVAL_TIME) as cnt
from vxflights v1, vxflights v2
where v1.year=v2.year and v1.month=v2.month and v1.day=v2.day
and v1.ARRIVAL_DELAY >=15 and v2.ARRIVAL_DELAY >=15
and v1.ARRIVAL_TIME>=v2.ARRIVAL_TIME
and v1.ORIGIN_AIRPORT=v2.ORIGIN_AIRPORT
group by v1.year, v1.month, v1.day, v1.ORIGIN_AIRPORT, v1.ARRIVAL_TIME, v1.FLIGHT_NUMBER
order by v1.year, v1.month, v1.day, cnt, v1.ORIGIN_AIRPORT, v1.ARRIVAL_TIME) nested;

create temporary table results
select vx.year, vx.month, vx.day, vx.ORIGIN_AIRPORt, vx.FLIGHT_NUMBER, vx.ARRIVAL_TIME, previous_delay 
from vxflights vx inner join nested n on 
vx.year=n.year and vx.month =n.month and vx.day=n.day 
and vx.origin_airport=n.origin_airport and vx.FLIGHT_NUMBER=n.FLIGHT_NUMBER;

select * from results r
order by r.year,r.month, r.day, r.origin_airport,r.previous_delay;

