## How to connect to Cloud SQL locally
1. Install [proxy](https://cloud.google.com/sql/docs/postgres/quickstart-proxy-test)
    1. Run command `./cloud_sql_proxy -instances=static-gravity-236812:europe-west1:strides=tcp:5432`

## Migration
- Uses [golang-migrate](https://github.com/golang-migrate/migrate/blob/master/database/postgres/TUTORIAL.md)
- Install [CLI](https://github.com/golang-migrate/migrate/tree/master/cmd/migrate) to run migrations manually.
- To create migration run `migrate create -ext sql -dir database/migrations -seq <migration_name>`