# Data source and local setup

## Source

- Dataset: [DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)
- Original source acknowledged on the Kaggle page: [Mendeley Data, DataCo Supply Chain](https://data.mendeley.com/datasets/8gx2fvg2k6/5)
- The Kaggle dataset page lists the dataset license as CC0 / Public Domain. Check the source page again before redistribution because dataset terms can change.

## Local import

Download `DataCoSupplyChainDataset.csv` from Kaggle and keep it outside the Git repository. The source CSV contains a `Customer Segment` column that this project does not use; the staging table intentionally omits it. In MySQL Workbench, create the staging table from `sql/00_create_staging_table.sql`, then use **Table Data Import Wizard** to map the remaining columns into `supply_chain_db.staging_supply_chain`. The source is commonly distributed in Latin-1 encoding; select the matching encoding if accented names do not import correctly.

Do not commit the raw CSV or local database credentials. The dashboard uses a local MySQL connection; each user should configure their own connection locally.
