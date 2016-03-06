# EVA API

## DEV

global dependencies
  - `npm install ngrok supervisor -g`

- Create DB : `mysql -u root -e 'CREATE DATABASE IF NOT EXISTS eva'`
- Setup DB : `node setup`
- Run Dev : `npm run dev`

- ngrock http `port`

## Setup Environment

export DB_HOST=localhost
export DB_USER=root
export DB_NAME=eva
export DB_PASS=

export TWILIO_ACCOUNT_SID=...
export TWILIO_AUTH_TOKEN=...

export EVA_API_TOKEN=...

### Documentation

Base URL : `eva-overwatch.herokuapp.com/api/v1`

Headers :

```
x-api-token : ... ( required to access any api endpoint )
x-authentication-token : ...
```

Users :

```
POST : { Base URL }/authenticate
PARAMS : application/json

{
	phone : '+15555555555'
}

RESPONSE : application/json

200 : {
	token : ... ( one time identification token )
}

400 : {
	code : ... ( 1000 = invalid number )
}

```

```
POST : { Base URL }/authenticate
PARAMS : application/json

{
	token : ... ( one time identification token )
	code : ... ( code sent to user )
}

RESPONSE : application/json

200 : {
	token : ... ( used in auth x-authentication-token )
}

```


```
POST : { Base URL }/report
PARAMS : application/json
{
    "lat": 31.454671,
    "lng" : -100.486226,
    "type": "open-app"
}

RESPONSE : application/json
{
  "lat": 31.454671,
  "lng": -100.486226,
  "status": null,
  "type": "open-app",
  "path": [
    {
      "lat": 31.454671,
      "lng": -100.486226
    }
  ],
  "created_at": "2016-03-06T02:08:47.081Z",
  "modified_at": "2016-03-06T02:08:47.088Z",
  "id": 2
}

```

```
PUT : { Base URL }/report/:id
PARAMS : application/json
{
    "lat": 49.282729, ( update lat )
    "lng" : -123.120738 ( update lng )
}

RESPONSE : 200

```