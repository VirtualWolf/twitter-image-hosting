# Twitter Image Hosting
A script for hosting your own Twitter image service (à la TwitPic, etc.). Based on [Ryan Petrich's PHP-based one](https://gist.github.com/rpetrich/627137) but rewritten in Perl using [Mojolicious](http://mojolicio.us).

### Installation
1. Install [Mojolicious](http://mojolicio.us) (you may need to have your own Perl installed using [Perlbrew](http://perlbrew.pl) first if you're on a shared hosting service like Dreamhost and the like, in which case change the shebang in the first line of this script to point to where you installed your Perl).
2. Copy this script and the included .htaccess to the root level of your web server.
3. Create a "public" directory, you may or may not need to chmod 777 depending on the server setup.
4. Add the following as a custom URL for image upload service in your favourite Twitter client: http://yourdomain.com/upload?p=password
