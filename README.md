# URL Shortener

    Provide a simple web front which will take the URL as an input and give back a shortened URL. When user access the 
    short URL it will take user to to the full URL which was sanitised and converted using the service. The service also
    contains an API endpoint where user can query stats around a particular shortened URL. Please note that the stats 
    includes the user's information along with URL information who has visited the url. Such users are recorded as visitors, 
    and the user who is converting the URL in short url will be recorded as creator to the URL. The result of the stats query 
    is returned in 2 different format i.e. XML and JSON and both of these are serialized using XML serializer and JSON serializer.

Working demo: [URL Shortener](https://strip-url.herokuapp.com/) 


## Getting Started

Before cloning the repository make sure you have Prerequisites installed on the machine. To successful build the service
   
   * cd <Project_directory>
   * run `rvm use .`
       * this will create the gemset and bind the ruby version specified in .ruby-gemset and .ruby-version 
   * run `bundle install`
   * run `rake setup_app:setup` 

### Prerequisites

* `rvm` [installation instructions](https://rvm.io/rvm/install)
* `ruby-2.2.5`
    * rvm install ruby 2.2.5
* `bundler`
    * gem install bundler
* `rails 4.2.3`
* `mysql` [installation instructions](https://gist.github.com/nrollr/3f57fc15ded7dddddcc4e82fe137b58e)


### Installing
   * git clone [repo url](git@github.com:aashishsaini/url_shortner.git)
   * cd <cloned_directory>
   * run `rvm use .`
       * this will create the gemset and bind the ruby version specified in .ruby-gemset and .ruby-version 
   * run `gem install bundler`
   * run `bundle install`
   * modify `database.yml` 
     * modify `MySql username and password`  
   * run `rake setup_app:setup` 

The rake task will perform the following

```
* install newly added gems
* drop the database if exists
* create the database
* migrate the database tables
* start the server on port 3000 local use

```

## Running the tests

To run the automated test suit execute command
`rake test`


## Deployment

For deployment all development environment instruction remain as is except the database
The development environment is using MySql, whereas production environment Postgresql is used.
 
#### Heroku deployment

Install the Heroku CLI

Download and install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-command-line).

If you haven't already, log in to your Heroku account and follow the prompts to create a new SSH public key.

`$ heroku login`

Clone the repository

Use Git to clone strip-url's source code to your local machine.

```
$ heroku git:clone -a strip-url
$ cd strip-url
```
Deploy your changes
Make some changes to the code you just cloned and deploy them to Heroku using Git.

```
$ git add .
$ git commit -am "make it better"
$ git push heroku master
```
## Versioning

We use [Git](https://github.com) for versioning. and all code is maintained on [Github](https://github.com/aashishsaini/url_shortner)

### Design Specification
   
* Designed a UI interface where user has an option to enter the URL
* If format of the URL is valid then system will generate the short url of the Original Url else throws an error which needs to be corrected by user
* A short url is a url which once clicked from UI or copied and pasted in browser, will take the User to the original Url.
    * Example: If original url is [http://google.com](http://google.com)
	* The short url is  [https://strip-url.herokuapp.com/f8rap5](https://strip-url.herokuapp.com/f8rap5)
    * Once user clicks on this url it will open up [google.com](http://google.com)

### Assumption

* Instead of ID user IP should be used as identifier of user in the system
* Whenever user visits the shortend URL the count of the URL incremented by 1  and user will recorded as accessor
    * if user doesn't exist in the system then system will create a new user using his/her ip and location constraints
* At the time of creation of shortend url the url hits count should be kept as 0 and user will recorded as creator.
* At the time of creation of Shortend URL the external service visits the URL and fetch the title of web page, the URL is pointing 
to and stored in the object data as page title which can be used to query the record-set.
* A link to the short url is displayed on converted url page which will open a new tab and open a original url in it.
* If user tries to convert the same url again then system will take it on previously created shortend url show page along with warning notification,
 states that URl for this original url is already present in the system. Please try to use the same. Once user clicks on this short url he will recorded
 as accessor instead of creator though he tried to create the URL.
* All the responses of the query is returned in 2 different format
   * use show url path to show the result of the search query
   * the method will return the web page if the request is not an api request 
     * api_request is used to differentiate between api request and template request
* search_url method will accepts 3 extra parameters which will add the logical operators between the table attributes
    * for example: 
        * if user wants to search for a string which is present in any of the shortend_url object attributes OR User attributes then he can pass logical operator as 'OR' else 'AND'
        * by use of these operators we can build a 'XOR' extractions among users and shortend_urls table
           * [All OR](https://strip-url.herokuapp.com/f8rap5.json?q=google)
           * [ShortendURl(OR) AND User(OR)](https://strip-url.herokuapp.com/f8rap5.json?q[shortend_url][original_url]=google&q[users][name]=guest_&q[shortend_url_operator]=OR&q[user_operator]=OR&q[global_operator]=AND)
           * [ShortendURl(AND) AND User(AND)](https://strip-url.herokuapp.com/f8rap5.json?q[shortend_url][original_url]=google&q[users][name]=guest_&q[shortend_url_operator]=AND&q[user_operator]=AND&q[global_operator]=AND)
           * [ShortendURl(OR) OR User(AND)](https://strip-url.herokuapp.com/f8rap5.json?q[shortend_url][original_url]=google&q[users][name]=guest_&q[shortend_url_operator]=OR&q[user_operator]=AND&q[global_operator]=OR)
           * [ShortendURl(OR) OR User(AND)](https://strip-url.herokuapp.com/f8rap5.json?q[shortend_url][original_url]=google&q[users][name]=guest_&q[user_operator]=AND&q[global_operator]=OR)
        * no hits count is recorded while extracting the stats using query endpoint interface.
* A cleanup rake task is created to clean up those record which are created 1 year ago and still not used even once. To clean up the records.
    * run `rake cleanup:urls`

### Ruby version

* The ruby version for development is specified in .ruby-version file
* The ruby version for production is specified in Gemfile
* Apart from above two a seperate gemset is created for this app using rvm which is specified in .ruby-gemset

### System dependencies
```
Good if have RVM with ruby 2.2.5 available
```

### Configuration
* Mysql for Development
* PG for Production    

### RDOC coverage
```
rake doc:app coverage is 57.69% documented.
```

## Things needs to be improved

* Implement redis-cache to store the query and its result so as to reduce the response time.
* Pull up the page category and other relevant information so that wide-en the query parameters.
* Built up a UI query interface where user can build specific query among different attributes of both the tables.
* Show Graphical representation of queried results.
* Autocomplete the Original url form where user entered the url needs to be converted.
* Autosuggest the similar web url's to user based on his previous converted web url's category or title.
* Add link to post the short url on social web application like FB or twitter. it should be similar to share with friend on Facebook.
* Add User's dashboard to list all of his converted urls
* Add URL's dashoboard to list all of the user who has accessed this URL.   

