# White Book VAT

Check VAT bank accounts using [MF API](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat) and Google Sheets.

## Setup

Using Google Sheets as an interface:

- Create new Spreadhseet in Google Suite
- As a sheet owner: `Tools` > `Script editor`
- Paste script content from `sheet.gs` with provided API URL
- To launch script use newly created option in Sheets top menu: `Accounts check` > `Check data`

Using Google Sheets as a data source:

- Create new project in [Google API Console](https://console.developers.google.com/)
- Enable Google Drive and Sheets API for the project (Library > _Selected API_ > Enable)
- Go to Credentials section:
  - Create Credentials > Service account > Create
  - Role: "Borwser" > Continue
  - Create kye > Key type: JSON > Create
  - Save file in project's root.
- In Google Sheets App: share selected sheet with user from `client_email` key in service account json file

Create `.env` file based on .env.template (`cp .env.template .env`) and add shared Sheet's file id (can be found in its URL) and json service account file name

```Bash
# Project requires Ruby >= 2.4

$ bundle install # --path vendor/bundle
$ ruby app.rb
```

## Tests

```
rspec src/white_book.spec.rb
```

## Spreadsheet structure

Sheet script reserves specific columns and cells:

| Scope  | Description           | Value type |
| ------ | --------------------- | ---------- |
| A2:A31 | NIP numbers           | Text       |
| B2:B31 | Account numbers       | Text       |
| C2:C31 | Found state value     | 0 &#124; 1 |
| D2:D31 | Valid state value     | 0 &#124; 1 |
| G1     | Request date time     | Date time  |
| G2     | Request ID            | Text       |
| G3     | Confirmation file URL | Text       |

## AWS Lambda deployment

- Please read [Lambda ruby tutorial](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/) using [AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- Add `S3_BUCKET`, `S3_REGION` (and `AWS_PROFILE` name if need) in `.env` file.
- Add S3 write permissions to your Lambda.

```
sh aws_lambda.sh
```

## Docker

```Bash
# Create image and tag it as white-book-vat
docker build -t white-book-vat .

# Run container and start session using bash shell
docker run -it -v $PWD:/home/app white-book-vat bash

ruby app.rb
```

## TODO

- ~~Read data from Google Sheets via API~~
- ~~Request data from [MF API](https://wl-api.mf.gov.pl/)~~
- ~~Return results~~
- ~~Tests~~
- ~~Deploy to AWS Lambda~~
- ~~Store confirmation files in S3 bucket~~
- ~~Create UI~~ (created using Google Sheets environemnt)

## Licence

[CC BY-NC 3.0](https://creativecommons.org/licenses/by-nc/3.0/)
