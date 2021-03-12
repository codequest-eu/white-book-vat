# White Book VAT

🇵🇱 Sprawdź konta bankowe na podstawie NIP w API [Biała Księga](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat) Ministerstwa Finansów.

Check VAT bank accounts using [MF API](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat) and Google Sheets.

<img src="https://white-book-vat.s3-eu-west-1.amazonaws.com/wb_2.gif" height="250" alt="White Book preview" />

## Setup

Using Google Sheets as an interface:

- Create new Spreadhseet in Google Suite
- As a sheet owner: `Tools` > `Script editor`
- Paste script content from `sheet.gs` with provided API URL
- To launch script use newly created option in Sheets top menu: `Accounts check` > `Check data`. Before first run you will have to provide required accesses for the script (read and update sheet).

Using Google Sheets as a data source:

- Create new project in [Google API Console](https://console.developers.google.com/)
- Enable Google Drive and Sheets API for the project (Library > _Selected API_ > Enable)
- Go to Credentials section:
  - Create Credentials > Service account > Create
  - Role: "Browser" > Continue
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

| Scope  | Description                 | Value type        |
| ------ | --------------------------- | ----------------- |
| A6:A36 | NIPs (optional)             | Text              |
| B6:B36 | Account numbers (required)  | Text              |
| C6:C36 | Found state value           | 0 &#124; 1        |
| D6:D36 | Valid state value           | 0 &#124; 1        |
| E6:E36 | Virtual account state value | 0 &#124; 1        |
| F6:F36 | NIP                         | Number            |
| G6:G36 | Company                     | Text              |
| H6:H36 | Request ID                  | Text              |
| B1     | Request date                | Date (YYYY-MM-DD) |
| B2     | Confirmation file URL       | Text              |

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

## Licence

[CC BY-NC 3.0](https://creativecommons.org/licenses/by-nc/3.0/)
