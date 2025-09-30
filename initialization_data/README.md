# Database Initialization

The TaxonWorks database can be initialized with 3 different modes which are set with the `database_init_mode` in the `group_vars/all` file:

1) "empty"

The database will be initialized empty with no populated records for geographic areas, geographic items, repositories, and serials. These data models are shared across TaxonWorks projects. If you plan on using these features, you may need to define your own shared data for your TaxonWorks instance.

2) "restore"

The database will be restored from a dump file. If you use restore mode, then you must provide the full file path to the dump file with the `database_restore_file` variable. The `tw_initialization_data-master.zip` data will not be used if it is provided because the geographic areas, geographic items, repositories, and serials will be restored from the dump file that you provide.

3) "initialized"

If you want to start a new TaxonWorks instance with no project data but with the geographic areas, geographic items, repositories, and serials populated with the data used on sfg.taxonworks.org then set the mode to "initialized". [Contact Species File Group](https://speciesfilegroup.org/about.html) to get a copy of the data. Place the `tw_initialization_data-master.zip` file inside this directory. Data initialization will only run if the database is empty.

