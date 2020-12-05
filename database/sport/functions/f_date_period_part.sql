DROP FUNCTION IF EXISTS sport.f_date_period_part (TIMESTAMPTZ, TIMESTAMPTZ, TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION sport.f_date_period_part (var_from_input TIMESTAMPTZ, var_to_input TIMESTAMPTZ, var_from TIMESTAMPTZ, var_to TIMESTAMPTZ)
--var_from_input: Reference Time period, e.g. calendar year
--var_to_input: Reference Time period, e.g. calendar year
--var_from: Time period of research object, e.g. season
--var_to: Time period of research object, e.g. season
--RESULT: part of research object time period (e.g. season) in Reference time period (e.g. calendar year)
    RETURNS real
    LANGUAGE plpgsql
AS $Body$
DECLARE
    r real;
BEGIN
    IF DATE_PART('day', var_from_input - var_from) <= 0
        /* var_from_input vor var_from */
        THEN
        IF DATE_PART('day', var_to_input - var_to) <= 0
            /* var_to_input vor var_to */
            THEN
            r:= DATE_PART('day', var_to_input - var_from);
        ELSE
            r:= DATE_PART('day', var_to - var_from);
        END IF;
    ELSE
        IF DATE_PART('day', var_to_input - var_to) <= 0
            /* var_to_input vor var_to */
            THEN
            r:= DATE_PART('day', var_to_input - var_from_input);
        ELSE
            r:= DATE_PART('day', var_to - var_from_input);
        END IF;
    END IF;
    r:= r / DATE_PART('day', var_to - var_from);
    RETURN r;
END;
$Body$
