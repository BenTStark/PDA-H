1. [ Introduction ](#begin)
1.1. [ Setup ](#setup)
1.2. [ Usage ](#usage)
2. [ Orchestrating ](#orchestrating)
2.1. [ Changelog ](#changelog)
2.2. [ Timeseries ](#timeseries)
2.3. [ Versioning ](#versioning)
2.4. [ Best Practices ](#bestpractices)
2.4.1. [ Combination ](#combination)
2.4.2. [ Folder and File structure ](#folderstructure)
2.4.3. [ ID Handling ](#idhandling)
1. [ Examples ](#examples)
1. [ To Do ](#todo)

# Postgres Data Administration Helper (PDA-H; PHONETIK:pi dage)
<a name="begin"></a>
Helps you to keep track of your data - **With timeseries, versioning of tables and changelog implementation**

## Setup Postgres (Debian example)
<a name="setup"></a>
Coming...

## Usage
<a name="usage"></a>
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
<a name="orchestrating"></a>
Tables: With prefix tv_ when tables is versionised.
Views: Prefix v_ before Table name: We will work 99% the time with these views
    Make DDL statements on this view in order to get time series and versionig stuff done.

Versionised Views: vv_ and vd_ as prefix. When Table is versionised.  

## Changelog
<a name="changelog"></a>
Changelog is simple. It watches a table on new INSERT, UPDATE or DELETE and saves all changes in the changelog table. Changelog works in every combination with other features.

## Timeseries
<a name="timeseries"></a>
Here the view is important since new entries are INSERT or UPDATE over the view. The View name ist the tablename with a prefiv "vt_". The View always shows the current status, i.e. all rows where Now() is between "valid_from" and "valid_to".
For new entries, the Private key is necessary. Private key must contain "valid_to" Column

## Versioning
<a name="versioning"></a>
Versioning is used to maintain the data status of all past dates. That means, with a versionised table, you can reconstruct the data of any date in the past. To used a versionised table, always INSERT, UPDATE or DELETE into View (vv-prefix).
- The table name must start with "tv_"
- The View "vv_" displays the current valid data
- The View "vd_" displays the current valid data inclusive with deleted data.

## Best practices
<a name="bestpractices"></a>

### Combination
<a name="combination"></a>
Changelog can be used for every table type. However, it is not recommended to use Timeseries and Versioning for the same table. This does not work currently and is also not useful.

### Folder and File structure
<a name="folderstructure"></a>
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

### ID (SERIAL) Handling
<a name="idhandling"></a>
In order to have a unique identifier per table. The usage of the datatypye [SERIAL](https://www.postgresqltutorial.com/postgresql-serial/) is useful. However in an application the ID should be avoided since AUTOINCREMENT in databases can change due to some reasons. For example when you have TEST and PRODUCTION environments you can easily fall into the trap of using IDs which can differ between the envs. Also database rollbacks, backup revocery, etc. can change IDs. There for an additional professional numbercode in the table can help to solve this.
In that case you must handle your INSERT correct. That means your query have to take the professional number first an get the correlated ID when you create INSERT statements. You have to check individually whether this could be a performance issue however in terms of data consistency you are on a safer side.

However, PDA-H always wants every column when you have INSERT statements. In your application you have to design things at your own best practice.

# Examples
<a name="examples"></a>
In the examples folder the different tables can be found, inhaling all features of the repo. i.e.
- Standalone Changelog
- Timeseries + Changelog
- Versioning + Changelog

# To Do
<a name="todo"></a>
- Testing: Create Testtabels with input and check table content against expected outcome.
- Combine Versioning and Timeseries (even when is not so useful most of the time)
- Code cleaning: Beautify Dynamic Code and make current code more readable and nice.
- Refactor DML Handling. i.e. INSERT must be done on the table, the vt view or the vv view... thats not nice.
- Changelog logs every column, even if no change has happend. Is this useful. May this user could choose.
- UPDATE in Timeseries still not working
- modified_at in Timeseries should be set automatic (not sure if this is really the case atm)
