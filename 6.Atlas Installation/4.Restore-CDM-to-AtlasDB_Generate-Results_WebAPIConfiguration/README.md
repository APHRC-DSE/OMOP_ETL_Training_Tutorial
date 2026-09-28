# Installation and Configuration Guide: Restore CDM/Results From Local host, Generating extra result schema tables, and WebAPI configuration.

---

## **1. Database Backup and Restoration in Docker**

- Open the Command Promt. To open the Command Prompt in Windows, search for "cmd" in the Start Menu and press Enter, or press the `Windows key + R`, type "cmd," and press Enter.

- Navigate to the PostgreSQL bin Directory by typing `cd C:\Program Files\PostgreSQL\17\bin` **(Ensure the version number 17 matches your installed PostgreSQL version. i.e 15, 16, etc)**.

### Step 1: Dump local OMOP-CDM instance Database from the Host Machine

pg_dump is a utility for exporting a PostgreSQL database. It makes consistent exports even if the database is being used concurrently. pg_dump only dumps a single database

- -U username → Specifies the PostgreSQL user (e.g., postgres).
- -d database name → Specifies the name of the database to be dumped.
- -n pattern →Dump only schemas matching pattern
- -N pattern →Do not dump any schemas matching pattern.
- -F format → Specifies the format of the output i.e 
  - default plain-text SQL script file(p)
  - custom format archive suitable for input into pg_restore(c)
- -f dump_file → Specifies the .sql, .dump, .backup file to be restored.

To export the whole database, run the below:

```bash
pg_dump -U postgres -d mydatabase -F p -f "/path/on/host/machine/name_cdm_results.sql"
```

If you want to export schemas one by one, add the `-n schemaname` as below:

```bash
pg_dump -U postgres -d mydatabase -n schemaname -F p -f "/path/on/host/machine/name_cdm.sql"
```

```bash
pg_dump -U postgres -d mydatabase -n schemaname -F p -f "/path/on/host/machine/name_results.sql"
```

If your vocabulary is in a separate schema, it is advisable to Output a custom-format archive suitable for input into pg_restore. Together with the directory output format, this is the most flexible output format in that it allows manual selection and reordering of archived items during restore. This format is also compressed by default.

```bash
pg_dump -U postgres -d mydatabase -n vocabulary -F c -f "/path/on/host/machine/vocabulary.dump"
```

- Remember to replace 
  - `/path/on/host/machine/` with the path where you want to save your dump
  - `name_cdm_results`, `name_cdm` , `name_results` and `vocabulary` with the name you want your file to appear with.

After successful back up, type `Exit` in the command line and press Enter. This will close the command-line interface.

### Step 2: Copy Backup File from Local Directory to Docker Container

#### Open Command Prompt

- Open the Command Promt. To open the Command Prompt in Windows, search for "cmd" in the Start Menu and press Enter, or press the `Windows key + R`, type "cmd," and press Enter.

- Type `wsl ~` and press Enter. WSL will launch to the home directory of your Ubuntu distribution.

#### Verify Running Containers
```bash
docker ps -a
```

#### Copy File to Broadsea Atlas DB Container (Ubuntu/WSL)

```bash
docker cp /mnt/c/path/on/host/machine/name_cdm.sql broadsea-atlasdb:/var/lib/postgresql/data/
```

```bash
docker cp /mnt/c/path/on/host/machine/name_results.sql broadsea-atlasdb:/var/lib/postgresql/data/
```

```bash
docker cp /mnt/c/path/on/host/machine/vocabulary.dump broadsea-atlasdb:/var/lib/postgresql/data/
```

- Remember to replace 
  - `c/path/on/host/machine/` with the path where you saved your dump in **Step 1**
  - `name_cdm` , `name_results` and `vocabulary` with your named file.

### Step 3: Verify dumps Was Copied Successfully

```bash
docker exec -it broadsea-atlasdb ls -l /var/lib/postgresql/data/
```

> [!NOTE]
> copying directly into `/var/lib/postgresql/data/` is not recommended. That directory is where Postgres stores its internal database files (WAL logs, indexes, relation files, etc.). Instead, you should copy to `/tmp/` (non-data dir).

### Step 4: Restore Database in Docker

There are two ways to restore the database in a atlasdb docker container:

#### A.Directly

```bash
docker exec -it broadsea-atlasdb psql -U postgres -d postgres -f /var/lib/postgresql/data/name_cdm.sql
```

```bash
docker exec -it broadsea-atlasdb psql -U postgres -d postgres -f /var/lib/postgresql/data/name_results.sql
```

```bash
docker exec -it broadsea-atlasdb pg_restore -U postgres -d postgres -v /var/lib/postgresql/data/vocabulary.dump
```

#### B.The Container Shell

- Open an interactive shell session by typing `docker exec -it broadsea-atlasdb bash` then press Enter.
- Navigate to the File Location by typing `cd /var/lib/postgresql/data/` then press Enter.
- Type the Restore Commands `psql -U postgres -d postgres -f name_cdm.sql`, `psql -U postgres -d postgres -f name_results.sql` and `pg_restore -U postgres -d postgres -v vocabulary.dump` one at a time then press Enter
- Remember to replace 
  - `/var/lib/postgresql/data/` with `/temp/` if you changed.
  - `name_cdm` , `name_results` and `vocabulary` with your named file.
  
> [!NOTE]
> Instead of using the container name `broadsea-atlasdb`, you can also run the commands by replacing it with container ID. The container ID is gotten by running `docker ps a` in the terminal and checking the Container ID associated with `broadsea-atlasdb`

After successful restoration, type `Exit` and press Enter. This will log you out of the current shell session and return back to the terminal.

You’ve now restored your CDM into the Broadsea atlas DB Docker container. Repeat this for multiple backups. 

### Step 5: Start the PgAdmin container and check if container is running

```bash
docker start pgadmin-atlasdb
```

```bash
docker ps -a
```
- Once the container is successfully running, you can access pgAdmin by navigating to `localhost:5050` in a web browser of your choice.

- You will then see a login prompt, you will be able to log in with the `e-mail address` and `password` that you specified when configuring.

### Step 6: Get the IP Address of the Atlas Database Container

After starting the necessary containers, retrieve the IP address of the ATLAS Database container. In your terminal, run

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' broadsea-atlasdb

```

- This will return an the IP address i.e `172.18.0.1` (this may or may not be true for you)

### Step 7: Login to the Server

After confirming successful login to pgAdmin 4,

- In pgAdmin, from the menu on the left side click the **server** you set up  e.g., "MyDB", "Test"...etc
- You will get a popup window with a "connection failed" message at the bottom.
- Cancel the popup window, and navigate to the **properties tab**
- Click the "Edit object" (pencil like icon).
- Under the "Connection" tab, in the **Host name/address** box, Paste the IP address from **Step 6** then click Save
- Double click on the server you created previously, enter your password then click OK.
- You are now connected to the broadsea-atlasdb PostgreSQL database and you will be able to select your database server from the menu on the left side.
- You can now be able to view your restored CDM and restults intances in the schemas.

---

## **2. Generating Extra Result Schema Tables**

### Step 8: Generate sql script to run

- Remember to replace in the below link 
  - `cdm_results` with the name of your results schema.
  - If your vocabulary is in the same schema as your OMOP-CDM replace `cdm_vocab` with the name of your OMOP-CDM schema.
  - If your vocabulary is a separate schema from your OMOP-CDM replace `cdm_vocab` with the name of your vocabulary schema.

```r
http://127.0.0.1/WebAPI/ddl/results?dialect=postgresql&schema=cdm_results&vocabSchema=cdm_vocab&tempSchema=tmp&initConceptHierarchy=true

```

- Navigate to your browser, paste the link then hit Enter. This will generate an sql script.
- Open query tool on the **Schema** tab then Copy generated script and run. This will take min 10 min depending on the specification of your machine and storage on Disk C.
- After the query has completed running, Confirm if extra tables have been added to results cdm schema.

---

## **3. WebAPI configuration**

### Step 9: Insert Source Information into webapi.source

- Remember to replace in the below link 
  - `Data source name` with the name you want for your data source.
  - `Data_01` with the source key name you want for your data source.
  - `postgres` with the username you set for your database.
  - `mypass` with the password you set for your database.

```sql
INSERT INTO webapi.source (source_id, source_name, source_key, source_connection, source_dialect,is_cache_enabled) 
SELECT nextval('webapi.source_sequence'), 'Data source name', 'Data_01', 'jdbc:postgresql://broadsea-atlasdb:5432/postgres?user=postgres&password=mypass', 'postgresql',
true;

```

Open query tool on **Schema** tab then run the code. (No need to run this again for subsequent revision of cdm and results cdm)

### Step 10: Link Source Information to Schemas via webapi.source_daimon

- Remember to replace in the below link 
  - `Data_01` with the source key name you want provided for you data source in **Step 9**.
  - `cdm_schema` with the name of your OMOP-CDM schema in your database.
  - `results_schema` with the name of your results schema associated with your OMOP-CDM schema in your database.
  - If your vocabulary is in the same schema as your OMOP-CDM, replace `vocabulary_schema` with the name of your OMOP-CDM schema in your database.
  - If your vocabulary is in a separate schema from your OMOP-CDM replace `vocabulary_schema` with the name of your vocabulary schema.

#### A.Add CDM schema mapping

```sql
INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 0, 'cdm_schema', 0
FROM webapi.source
WHERE source_key = 'Data_01';

```

#### B.Add Vocabulary schema mapping

```sql
INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 1, 'vocabulary_schema', 10
FROM webapi.source
WHERE source_key = 'Data_01';

```

#### C.Add Results schema mapping

```sql
INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 2, 'results_schema', 1
FROM webapi.source
WHERE source_key = 'Data_01';

```

Open query tool on **Schema** tab then run the codes. (No need to run this again for subsequent revision of cdm and results cdm)

#### D.Refresh WEBAPI

> [!NOTE]
> Navigate to your browser and paste `http://127.0.0.1/WebAPI/source/refresh`. This will give a json with datasources you have in you ATLAS.

---

> [!NOTE]
> Navigate to your browser and paste `http://127.0.0.1/atlas/`. This will open ATLAS. Go to view Data sources then select data sources. You will see your data source


---

## **Troubleshooting**

For common troubleshooting steps, consult the [Docker Troubleshooting Guide](https://docs.docker.com/get-docker/) and the [OHDSI Broadsea GitHub Issues page](https://github.com/OHDSI/Broadsea/issues).

---

