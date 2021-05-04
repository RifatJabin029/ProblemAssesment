--------------------------------------------------------
--  File created - Tuesday-May-04-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View CALL_CAL_VIEW
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "CALL_CAL_VIEW" ("MSISDN", "DOMAIN", "duration_in_sec", "fdr_count", "call_rate_kbps", "is_audio", "is_video") AS with a AS (
select msisdn Msisdn, starttime ST,endtime ET,
CASE WHEN endtime - INTERVAL '10' MINUTE > starttime THEN endtime - INTERVAL '10' MINUTE  
     ELSE endtime  
     END "ET*(ET-10)",
     domain domain, ROUND(ulvolume+dlvolume/1024,2) "fdr_count"
from call_cal_IPDR 
order by domain, MSISDN asc)

select Msisdn,domain, ROUND(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400,2) AS "duration_in_sec",  "fdr_count",
CASE WHEN to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400) = 0 THEN 0
     ELSE ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2) END "call_rate_kbps",
CASE WHEN to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400) = 0  THEN -1
     WHEN ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2) < 10 THEN -1
     WHEN ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2) > 10 AND 
     ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2)<= 200 THEN 1 
     END "is_audio",
CASE WHEN to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400)= 0 THEN -1
     WHEN ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2)<10 THEN -1
     WHEN ROUND("fdr_count"/to_number(( CAST( "ET*(ET-10)" AS DATE ) - CAST( ST AS DATE ) ) * 86400),2)> 200 THEN 1
     END "is_video"
from a
order by domain, MSISDN asc
