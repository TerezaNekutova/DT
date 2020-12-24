--- Point to parts that could be optimized
--- Feel free to comment any row that you think could be optimize/adjusted in some way!
--- The following query is from SAP HANA but applies to any DB
--- Do not worry if the tables/columns are not familiar to you 
----   -> you do not need to interpret the result (in fact the query does not reflect actual DB content)
SELECT 
	RSEG.EBELN,
	RSEG.EBELP,
    RSEG.BELNR,
    RSEG.AUGBL AS AUGBL_W,
    LPAD(EKPO.BSART,6,0) as BSART,
	BKPF.GJAHR,
	BSEG.BUKRS,
	BSEG.BUZEI,
	BSEG.BSCHL,
	BSEG.SHKZG,
    CASE WHEN BSEG.SHKZG = 'H' THEN (-1) * BSEG.DMBTR ELSE BSEG.DMBTR END AS DMBTR,
    COALESCE(BSEG.AUFNR, 'Kein SM-A Zuordnung') AS AUFNR,
    COALESCE(LFA1.LAND1, 'Andere') AS LAND1, --no replacement needed - filtered on DE and SK values only (in inner join)
    LFA1.LIFNR, -- column can be taken from BSEG table
    LFA1.ZSYSNAME, -- column can be taken from RSEG table
    BKPF.BLART as BLART, --no need for alias - the column will have this name anyway
    BKPF.BUDAT as BUDAT, --no need for alias - the column will have this name anyway
    BKPF.CPUDT as CPUDT --no need for alias - the column will have this name anyway
FROM "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_RSEG" AS RSEG
-- join on 1=1 is to spare when we use another contiditions
LEFT JOIN "DTAG_DEV_CSBI_CELONIS_WORK"."dtag.dev.csbi.celonis.app.p2p_elog::__P2P_REF_CASES" AS EKPO ON 1=1
    AND RSEG.ZSYSNAME = EKPO.SOURCE_SYSTEM
    AND RSEG.MANDT = EKPO.MANDT
    AND RSEG.EBELN || RSEG.EBELP = EKPO.EBELN || EKPO.EBELP -- it could be as two condition for better readability (RSEG.EBELN = EKPO.EBELN and RSEG.EBELP = EKPO.EBELP)
-- join on 1=1 is to spare when we use another contiditions
INNER JOIN "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_BKPF" AS BKPF ON 1=1
    AND BKPF.AWKEY = RSEG.AWKEY -- RSEG.AWKEY = BKPF.AWKEY for better readability
    AND RSEG.ZSYSNAME = BKPF.ZSYSNAME
    AND RSEG.MANDT in ('200') -- there is no need for using IN if we have only one value
-- join on 1=1 is to spare when we use another contidition
INNER JOIN "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_BSEG" AS BSEG ON 1=1
    AND DATS_IS_VALID(BSEG.ZFBDT) = 1
    AND BSEG.KOART = 'K'
    AND CAST(BSEG.GJAHR AS INT) = 2020
    AND BKPF.ZSYSNAME = BSEG.ZSYSNAME
    AND BKPF.MANDT = BSEG.MANDT
    AND BKPF.BUKRS = BSEG.BUKRS
    AND BKPF.GJAHR = BSEG.GJAHR
    AND BKPF.BELNR = BSEG.BELNR
    AND BSEG.DMBTR*-1 >= 0 -- add space between sign and values
    
-- join on 1=1 is to spare when we use another contidition
-- there's no need to create another select, just condition AND LFA1.LIFNR > '020000000' would be enough
-- and join can be performed in the same way as previous one
-- also this filter can be performed already on BSEG table
INNER JOIN (SELECT * FROM "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_LFA1" AS TEMP
            WHERE TEMP.LIFNR > '020000000') AS LFA1 ON 1=1 
    AND BSEG.ZSYSNAME = LFA1.ZSYSNAME
    AND BSEG.LIFNR=LFA1.LIFNR
    AND BSEG.MANDT=LFA1.MANDT
    AND LFA1.LAND1 in ('DE','SK')
;