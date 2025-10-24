/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
*/

	-- crm_cust_info
	COPY bronze.crm_cust_info
    FROM 'C:/path/to/your/file.csv'
    WITH (
       FORMAT csv,
   		 HEADER TRUE,
    	DELIMITER ','
	 );


	-- crm_prd_info
	COPY bronze.crm_prd_info
F	ROM 'C:/path/to/your/file.csv'
	WITH (
    	FORMAT csv,
    	HEADER TRUE,
    	DELIMITER ','
	);

	-- crm_sales_details
	COPY bronze.crm_sales_details
	FROM 'C:/path/to/your/file.csv'
	WITH (
	   FORMAT csv,
   		 HEADER TRUE,
		DELIMITER ','
	 );
	
	-- erp_loc_a101
	COPY bronze.erp_loc_a101
	FROM 'C:/path/to/your/file.csv'
	WITH (
	   FORMAT csv,
   		 HEADER TRUE,
		DELIMITER ','
	 );
	
	-- erp_cust_az12
	COPY bronze.erp_loc_a101
	FROM 'C:/path/to/your/file.csv'
	WITH (
	   FORMAT csv,
   		 HEADER TRUE,
		DELIMITER ','
	 );

	-- erp_px_cat_g1v2
	COPY bronze.erp_loc_a101
	FROM 'C:/path/to/your/file.csv'
	WITH (
	   FORMAT csv,
   		 HEADER TRUE,
		DELIMITER ','
	 );
