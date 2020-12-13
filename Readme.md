# Postgres Data Administration Helper (PDA-H; PHONETIK:pi dage)
Helps you to keep track of your data - **With timeseries, versioning of tables and changelog implementation**

## Setup Postgres (Debian example)
Coming...

## Usage
In *.conf files, path and filename of sql files are listed. To comment out, use #.
The list will be excuted sequentially.

In the shell, type
```
bash install.sh <*.conf>
```

- P0001.conf installs all necessary Administration tables and functions. It creates a scheme "root".
- P0002.conf creats the example scheme. Note that search_path has to be SET in a manual way. That means, for every new scheme, keep in mind the previous installed schemes and take them for the search_path SET into account.
- P0003.conf creates three example tables. They demonstrate the Changelog (used in all three tables), a timeseries and versioning.

# Orchestrating Tables and Views
Tables: With prefix tv_ when tables is versionised.
Views: Prefix v_ before Table name: We will work 99% the time with these views
    Make DDL statements on this view in order to get time series and versionig stuff done.

Versionised Views: vv_ and vd_ as prefix. When Table is versionised.  

## Changelog
Changelog is simple. It watches a table on new INSERT, UPDATE or DELETE and saves all changes in the changelog table. Changelog works in every combination with other features.

## Timeseries
Here the view is important since new entries are INSERT or UPDATE over the view. The View name ist the tablename with a prefiv "vt_". The View always shows the current status, i.e. all rows where Now() is between "valid_from" and "valid_to".
For new entries, the Private key is necessary. Private key must contain "valid_to" Column

## Versioning
Versioning is used to maintain the data status of all past dates. That means, with a versionised table, you can reconstruct the data of any date in the past. To used a versionised table, always INSERT, UPDATE or DELETE into View (vv-prefix).
- The table name must start with "tv_"
- The View "vv_" displays the current valid data
- The View "vd_" displays the current valid data inclusive with deleted data.

## Best practices
### Combination
Changelog can be used for every table type. However, it is not recommended to use Timeseries and Versioning for the same table. This does not work currently and is also not useful.

### Folder and File structure
A good folder structe could be
```
.
├── ...
├── schema                              # Name of your new schema
│   ├── tables                          # Folder for Tables
│   │   ├──table_one                    # Example folder for a table named "table_one"
│   │   │  ├──table_one.sql             # CREATE Statement for "table_one"
│   │   │  ├──table_one-config.sql      # Calling config function, e.g. enabling timeseries
│   │   │  ├──table_one-001.sql         # Transaction SQL: Useful e.g when table gets a new row and is versionised.  
│   │   │  ├──table_one-init.sql        # File with Data INSERT
│   ├── functions                       # Folder for functions
│   └── scripts                         # folder for scripts
├──install.sh                           # install script
├──*.conf                               # files with install information              
└── ...
```

# Examples
In the examples folder the different tables can be found, inhaling all features of the repo. i.e.
- Standalone Changelog
- Timeseries + Changelog
- Versioning + Changelog

# To Do
- Testing: Create Testtabels with input and check table content against expected outcome.
- Combine Versioning and Timeseries (even when is not so useful most of the time)
- Code cleaning: Beautify Dynamic Code and make current code more readable and nice.
- Refactor DML Handling. i.e. INSERT must be done on the table, the vt view or the vv view... thats not nice.
- Changelog logs every column, even if no change has happend. Is this useful. May this user could choose.

