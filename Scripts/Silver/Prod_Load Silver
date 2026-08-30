CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time       TIMESTAMP;
    end_time         TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
    row_count        INTEGER;
BEGIN

    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '================================================';


    -----------------------------------------------------------------------
    -- CRM TABLES
    -----------------------------------------------------------------------

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';


    -----------------------------------------------------------------------
    -- 1. CRM CUSTOMER
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';

    TRUNCATE TABLE silver.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),

        CASE
            WHEN cst_marital_status = 'M'
                THEN 'Married'
            WHEN cst_marital_status = 'S'
                THEN 'Single'
            ELSE 'N/A'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F'
                THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M'
                THEN 'Male'
            ELSE 'N/A'
        END,

        cst_create_date

    FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last

        FROM bronze.crm_cust_info

        WHERE cst_id IS NOT NULL
    ) t

    WHERE flag_last = 1;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- 2. CRM PRODUCT
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';

    TRUNCATE TABLE silver.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';

    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        REPLACE(
            SUBSTRING(prd_key, 1, 5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTRING(
            prd_key,
            7,
            LENGTH(prd_key)
        ) AS prd_key,

        prd_nm,

        COALESCE(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M'
                THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R'
                THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S'
                THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T'
                THEN 'Touring'
            ELSE 'N/A'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        CAST(
            LEAD(prd_start_dt) OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            )
            - INTERVAL '1 day'
            AS DATE
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- 3. CRM SALES
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';

    TRUNCATE TABLE silver.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';

    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt IS NULL
                 OR sls_order_dt = 0
                 OR sls_order_dt::TEXT !~ '^[0-9]{8}$'
            THEN NULL
            ELSE TO_DATE(
                sls_order_dt::TEXT,
                'YYYYMMDD'
            )
        END,

        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt::TEXT) != 8
            THEN NULL
            ELSE TO_DATE(
                sls_ship_dt::TEXT,
                'YYYYMMDD'
            )
        END,

        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt::TEXT) != 8
            THEN NULL
            ELSE TO_DATE(
                sls_due_dt::TEXT,
                'YYYYMMDD'
            )
        END,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END

    FROM bronze.crm_sales_details;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- ERP TABLES
    -----------------------------------------------------------------------

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';


    -----------------------------------------------------------------------
    -- 4. ERP CUSTOMER
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';

    TRUNCATE TABLE silver.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT

        CASE
            WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END,

        CASE
            WHEN bdate > CURRENT_DATE
                THEN NULL
            ELSE bdate
        END,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'
            ELSE 'N/A'
        END

    FROM bronze.erp_cust_az12;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- 5. ERP LOCATION
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';

    TRUNCATE TABLE silver.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '_'),

        CASE
            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'

            WHEN TRIM(cntry) IN ('US', 'USA')
                THEN 'United States'

            WHEN cntry IS NULL
                 OR TRIM(cntry) = ''
                THEN 'N/A'

            ELSE TRIM(cntry)
        END

    FROM bronze.erp_loc_a101;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- 6. ERP PRODUCT CATEGORY
    -----------------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table:silver.erp_px_cat_glv2';

    TRUNCATE TABLE silver.erp_px_cat_glv2;

    RAISE NOTICE '>> Inserting Data Into:silver.erp_px_cat_glv2';

    INSERT INTO silver.erp_px_cat_glv2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance

    FROM  bronze.erp_px_cat_glv2;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Rows Loaded: %', row_count;

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (end_time - start_time))::NUMERIC,
            2
        );


    -----------------------------------------------------------------------
    -- COMPLETE
    -----------------------------------------------------------------------

    batch_end_time := clock_timestamp();

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer is Completed';
    RAISE NOTICE 'Total Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::NUMERIC,
            2
        );
    RAISE NOTICE '==========================================';


EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING SILVER LOAD';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQL State: %', SQLSTATE;
        RAISE NOTICE '==========================================';

        RAISE;

END;
$$;

call silver.load_silver()

 SELECT * FROM bronze.erp_px_cat_glv2



