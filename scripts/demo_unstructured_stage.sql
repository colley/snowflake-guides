
-- We'll begin by setting our Worksheet context. We will set our database, schema and role.

USE DATABASE tb_101;
USE ROLE accountadmin;
CREATE OR REPLACE STAGE demo_unstructured_stage;

ALTER STAGE demo_unstructured_stage SET DIRECTORY = (ENABLE = TRUE);
SELECT * FROM DIRECTORY(@demo_unstructured_stage);

SELECT
    RELATIVE_PATH,
    ROUND(SIZE/1024/1024, 3) || ' M' as SIZE,
    MD5
FROM DIRECTORY(@demo_unstructured_stage);


SELECT
    '| ' || RELATIVE_PATH || ' | ' || ROUND(SIZE/1024/1024, 3) || ' | ' || last_modified || ' |'
FROM DIRECTORY(@demo_unstructured_stage)
UNION ALL
SELECT '| Relative Path | Size (MB) | last_modified |'
UNION ALL
SELECT '|---|---|---|'
ORDER BY 1 DESC;  -- 粗略控制表头顺序


LIST @demo_unstructured_stage
