CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    row_count  BIGINT;
BEGIN

    ---------------------------------------------------------------------------
    -- START
    ---------------------------------------------------------------------------

    RAISE NOTICE '================================================';
    RAISE NOTICE '          STARTING BRONZE LOAD';
    RAISE NOTICE '================================================';


    ---------------------------------------------------------------------------
    -- CRM TABLES
    ---------------------------------------------------------------------------

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';


    ---------------------------------------------------------------------------
    -- 1. CRM CUSTOMER
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating: bronze.crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Loading: bronze.crm_cust_info';

    COPY bronze.crm_cust_info
    FROM '/tmp/postgres_import/cust_info.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- 2. CRM PRODUCT
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE '>> Truncating: bronze.crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Loading: bronze.crm_prd_info';

    COPY bronze.crm_prd_info
    FROM '/tmp/postgres_import/prd_info.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- 3. CRM SALES
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE '>> Truncating: bronze.crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Loading: bronze.crm_sales_details';

    COPY bronze.crm_sales_details
    FROM '/tmp/postgres_import/sales_details.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- ERP TABLES
    ---------------------------------------------------------------------------

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '================================================';


    ---------------------------------------------------------------------------
    -- 4. ERP LOCATION
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE '>> Truncating: bronze.erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Loading: bronze.erp_loc_a101';

    COPY bronze.erp_loc_a101
    FROM '/tmp/postgres_import/loc_a101.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- 5. ERP CUSTOMER
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE '>> Truncating: bronze.erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Loading: bronze.erp_cust_az12';

    COPY bronze.erp_cust_az12
    FROM '/tmp/postgres_import/cust_az12.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- 6. ERP PRODUCT CATEGORY
    ---------------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE '>> Truncating: bronze.erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_glv2;

    RAISE NOTICE '>> Loading: bronze.erp_px_cat_g1v2';

    COPY bronze.erp_px_cat_glv2
    FROM '/tmp/postgres_import/px_cat_g1v2.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;
    RAISE NOTICE '>> Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);


    ---------------------------------------------------------------------------
    -- COMPLETE
    ---------------------------------------------------------------------------

    RAISE NOTICE '================================================';
    RAISE NOTICE '       BRONZE LOAD COMPLETED SUCCESSFULLY';
    RAISE NOTICE '================================================';

END;
$$;

 CALL bronze.load_bronze();



 SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count
FROM bronze.crm_cust_info

UNION ALL

SELECT 'crm_prd_info', COUNT(*)
FROM bronze.crm_prd_info

UNION ALL

SELECT 'crm_sales_details', COUNT(*)
FROM bronze.crm_sales_details

UNION ALL

SELECT 'erp_loc_a101', COUNT(*)
FROM bronze.erp_loc_a101

UNION ALL

SELECT 'erp_cust_az12', COUNT(*)
FROM bronze.erp_cust_az12

UNION ALL

SELECT 'erp_px_cat_glv2', COUNT(*)
FROM bronze.erp_px_cat_glv2;
