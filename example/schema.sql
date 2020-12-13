DROP SCHEMA IF EXISTS example CASCADE;

CREATE SCHEMA example;
ALTER DATABASE dev SET search_path TO root,example,public;