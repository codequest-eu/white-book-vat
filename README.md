# White Book

Check VAT bank accounts using [MF API](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat) and Google Sheets.

## Setup

* Create new project in [Google API Console](https://console.developers.google.com/)
* Elable *Google Drive* and *Sheets* API for the project (Library > *Selected API* > Enable)
* Go to Credentials ("Dane logowania"):
  * "Utwórz dane logowania" > "Konto usługi" > "Dalej"
  * Rola: "Przeglądający > "Dalej"
  * "Utwórz klucz" > "Typ: JSON" > "Utwórz" (save file in project's root as `service_account.json`).
  * Save
* In Google Sheets App: share selected sheet with user from `client_email` key in `service_account.json`.
* Create .env file based on .env.template (`cp .env.template .env`) and add shared Sheet's files title.

```
bundle install
bundle exec ruby app.rb
```

## Spreadsheet structure

|NIP|Account|
|-|-|
`/[0-9]/`|`/[0-9]/`

## Docker

```
docker build -t white-book .
docker run -it white-book bash
bundle exec ruby app.rb
```

## TODO

* ~~Read data from Google Sheets via API~~
* ~~Request data from [MF API](https://wl-api.mf.gov.pl/)~~
* Store results and confirmation in AWS S3
* ~~Return results~~
* Create UI
