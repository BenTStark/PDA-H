# Postgres Data Administration Helper (PDA-H; PHONETIK:pi dage)
Helps you to keep track of your data.

# Orchestrating Tables and Views
Tables: With prefix tv_ when tables is versionised.
Views: Prefix v_ before Table name: We will work 99% the time with these views
    Make DDL statements on this view in order to get time series and versionig stuff done.

Versionised Views: vv_ and vd_ as prefix. When Table is versionised.  

## Changelog
Changelog is simple. It watches a table on new Inserts or Updates and saves all changes in the changelog table.

## Timeseries
Here the view is important since new entries are inserted or updated over the view. Depending whether the table is versionised, the
INSERT, UPDATE or DELETE statements are sent directly to the table or to the versionised view. 

## Versioning
Versioning happens on the vv_ View. 

# Examples
