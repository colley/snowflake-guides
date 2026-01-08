CREATE DATABASE KAFKA_DB;
CREATE OR REPLACE ROLE KAFKA_ROLE;



GRANT CREATE SCHEMA ON DATABASE KAFKA_DB TO ROLE KAFKA_ROLE;


GRANT OWNERSHIP ON DATABASE KAFKA_DB TO ROLE KAFKA_ROLE COPY CURRENT GRANTS;

GRANT USAGE ON SCHEMA KAFKA_DB.PUBLIC TO ROLE KAFKA_ROLE;
GRANT CREATE TABLE ON SCHEMA KAFKA_DB.PUBLIC TO ROLE KAFKA_ROLE;
GRANT CREATE STAGE ON SCHEMA KAFKA_DB.PUBLIC TO ROLE KAFKA_ROLE;
GRANT CREATE PIPE ON SCHEMA KAFKA_DB.PUBLIC TO ROLE KAFKA_ROLE;
GRANT ROLE KAFKA_ROLE TO USER SWAK;

USE DATABASE KAFKA_DB;
USE ROLE KAFKA_ROLE;

CREATE SCHEMA KAFKA_DB.analyst_schema;

CREATE OR REPLACE TABLE KAFKA_DB.PUBLIC.historical_sales_data (
  store_id NUMBER, item VARCHAR, date TIMESTAMP_NTZ, sales FLOAT, label BOOLEAN,
  temperature NUMBER, humidity FLOAT, holiday VARCHAR);

INSERT INTO historical_sales_data VALUES
  (1, 'jacket', to_timestamp_ntz('2020-01-01'), 2.0, false, 50, 0.3, 'new year'),
  (1, 'jacket', to_timestamp_ntz('2020-01-02'), 3.0, false, 52, 0.3, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-03'), 5.0, false, 54, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-04'), 30.0, true, 54, 0.3, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-05'), 8.0, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-06'), 6.0, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-07'), 4.6, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-08'), 2.7, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-09'), 8.6, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-10'), 9.2, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-11'), 4.6, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-12'), 7.0, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-13'), 3.6, false, 55, 0.2, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-14'), 8.0, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-01'), 3.4, false, 50, 0.3, 'new year'),
  (2, 'umbrella', to_timestamp_ntz('2020-01-02'), 5.0, false, 52, 0.3, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-03'), 4.0, false, 54, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-04'), 5.4, false, 54, 0.3, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-05'), 3.7, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-06'), 3.2, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-07'), 3.2, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-08'), 5.6, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-09'), 7.3, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-10'), 8.2, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-11'), 3.7, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-12'), 5.7, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-13'), 6.3, false, 55, 0.2, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-14'), 2.9, false, 55, 0.2, null);


CREATE OR REPLACE TABLE new_sales_data (
  store_id NUMBER, item VARCHAR, date TIMESTAMP_NTZ, sales FLOAT,
  temperature NUMBER, humidity FLOAT, holiday VARCHAR);

INSERT INTO new_sales_data VALUES
  (1, 'jacket', to_timestamp_ntz('2020-01-16'), 6.0, 52, 0.3, null),
  (1, 'jacket', to_timestamp_ntz('2020-01-17'), 20.0, 53, 0.3, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-16'), 3.0, 52, 0.3, null),
  (2, 'umbrella', to_timestamp_ntz('2020-01-17'), 70.0, 53, 0.3, null);

-- Create an anomaly detection object, and train its model on the data in that view.
CREATE OR REPLACE VIEW view_with_training_data
  AS SELECT date, sales FROM historical_sales_data
    WHERE store_id=1 AND item='jacket';

-- Create an anomaly detection object, and train its model on the data in that view.
CREATE OR REPLACE SNOWFLAKE.ML.ANOMALY_DETECTION basic_model(
  INPUT_DATA => TABLE(view_with_training_data),
  TIMESTAMP_COLNAME => 'date',
  TARGET_COLNAME => 'sales',
  LABEL_COLNAME => '');

-- Create a view or design a query that returns the data for analysis.
CREATE OR REPLACE VIEW view_with_data_to_analyze
  AS SELECT date, sales FROM new_sales_data
    WHERE store_id=1 and item='jacket';

-- Using the object for the anomaly detection model
CALL basic_model!DETECT_ANOMALIES(
  INPUT_DATA => TABLE(view_with_data_to_analyze),
  TIMESTAMP_COLNAME =>'date',
  TARGET_COLNAME => 'sales'
);
