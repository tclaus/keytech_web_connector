# Keytech web app
## About
This is a web connector for accessing the Keytech WEB-API.


## Requisites

- Install memcached:
 OSX: 		brew install memcached
 Ubuntu: 	apt-get install memcached


Install Bundler to get all the gems for development
$: gem install bundler
$: bundler install --without-production

Fur ruby, use 'rvm'

gem install rack

Start local with 'rackup' and open a browser at http://localhost:9292

## How to use
Start with 'rackup' and register the first account. Registering means to get access to this service.
User does not need to give keytech credentials on signup!

In the 'account' page a user can enter the URL to the keytech WEB-API along with keytech credentials.
Credentials and Web-API URL will be stored crypted in a local database. Password are secured by hashing and salting.

This a a proof-of-concept at time of writing this.
Feel free to fork it and improve it.

## License
Copyright (c) 2014-2017 Thorsten Claus

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
