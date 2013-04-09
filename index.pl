#!/usr/bin/env perl

# Twitter self-hosted image service by VirtualWolf
# Based on Ryan Petrich's PHP-based one but rewritten in Perl using Mojolicious:
# https://gist.github.com/rpetrich/627137
#
# Installation:
# 0. Install Mojolicious (http://mojolicio.us - you may need to have your own Perl 
#    installed using Perlbrew first (http://perlbrew.pl) if you're on a shared
#    hosting service like Dreamhost and the like, in which case change the shebang
#    in the first line of this script to point to where you installed your Perl).
# 1. Copy this script and the included .htaccess to the root level of your web server.
# 2. Create a "public" directory, you may or may not need to chmod 777 depending on the
#    server setup.
# 3. Add the following as a custom URL for image upload service in Tweetbot/etc.:
#     http://yourdomain.com/upload?p=password

use Mojolicious::Lite;
use File::stat;
my $password = 'password';



get '/' => sub {
    my $self = shift;

    $self->render(text => '');
};



post '/upload' => sub {
    my $self = shift;

    if ( $self->param( 'p' ) && $self->param( 'p' ) eq $password && $self->param( 'media' ) ) {
        return $self->render( text => 'File is too large.', status => 200) if $self->req->is_limit_exceeded;
        my $upload = $self->param( 'media' );

        my $file_extension;
        my $content_type = $upload->headers->content_type;
        given ( $content_type ) {
            when ( 'image/jpeg' ) {
                $file_extension = 'jpg';
            };
            when ( 'image/png' ) {
                $file_extension = 'png';
            };
            when ( 'image/gif' ) {
                $file_extension = 'gif';
            };
        };

        my $filename = &get_random_filename;

        $upload = $upload->move_to( "public/$filename.$file_extension" );

        $self->render( text => "<mediaurl>http://$ENV{ 'SERVER_NAME' }/$filename</mediaurl>" );
    }
    else {
        $self->render( text => 'Not authorised.', status => 401 );
    };
};



get '/:short_url' => sub {
    my $self = shift;

    my $url = $self->param( 'short_url' );
    my $matching_file = glob "public/$url.*";

    if ( $matching_file ) {
        my $content_length = stat( $matching_file )->size;
        $matching_file =~ s/public\/(.*?)/$1/;
        $self->res->headers->content_length( $content_length );
        $self->render_static( $matching_file );
    }
    else {
        $self->render( text => 'Not found.', status => 404 );
    };
};



sub generate_random_string {
    my ($length) = @_;
    my $string;
    my @characters = ('0'..'9','a'..'z');

    while ( length( $string ) < $length ) {
        $string .= $characters[ rand @characters ]
    };

    return $string;
};

sub get_random_filename {
    my $filename = &generate_random_string( 4 );
    my $existing_file = glob "public/$filename.*";
    if ( $existing_file ) {
        $filename = &generate_random_string( 5 );
    };

    return $filename;
};

app->start;
