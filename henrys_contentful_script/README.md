# contentful-urls

Tiny script to programmatically change contentful URLs for marketing pages

## Requirements

* Ruby 2.1.5
* Contentful credentials
* FIXME

## Installation

* Clone the repository
* Install dependencies (`bundle`)

## Usage

* FIXME

## Prupose

* Create Script.rb file where my API instructions will be placed
* Use the API to download the JSON data from Contentful
* Compare it with Adrien's lists to create a list of changes. These changes will be about:
* * Adding a dash to Cities (cities-berlin)
* * Adding a dash between words in English, for the following categories:
* * * Airporttransfer (airport-transfer)
* * * Limousineservice
* * * Chauffeurservice
* * Adding TWO dashes for the following words:
* * * Airporttransfer/city (airport-transfer-city)
* * * Limousineservice/city
* * * Chauffeurservice/city
* * Adding one dash for the German categories:
* * * Flughafentransfer/berlin (flughafentransfer-Berlin)
* Set up redirects for ALL urls that are getting changed
* Change the Aphrodite Routes to work for the new URLs
* Figure out a way to test the Aphrodite Routes and Redirects changes
* Pull-Request / Push the Aphrodite Route changes
* Upload via the API all the Contentful changes to Contentful
