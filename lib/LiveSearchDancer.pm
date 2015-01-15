package LiveSearchDancer;
use Dancer ':syntax';

use JSON qw( decode_json );
use Data::Dumper;
use utf8;
use HTML::Entities;
use Encode;
use Text::Unaccent;


our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/livesearch' => sub {
    
    my $params = shift;
    if (defined $params ){ print $params; }
    my $searched ='Dilm';
    my $vars = {};
    my $unaccented_searched = unac_string('UTF-8', $searched);
    open ( my $json_file_source, '<', "gistfile1.json" ) or die "nao abriu o arquivo corretamente ";
    my $json_source = '';
    while ( <$json_file_source> ){
        $json_source .= $_ ;
    }
    my $decoded_json = '';
    $decoded_json = decode_json( $json_source );

    my $highlights = $decoded_json->{hightlights};
    my $sugestions = $decoded_json->{suggestions} ;
    my $n_highlights = scalar ( @$highlights );
    my $count_search = 0;

    while ( $count_search < $n_highlights ){
        my $n_queries = scalar( @{ $highlights->[$count_search]->{queries}} );
        my $count_search_queries = 0;
        while ( $count_search_queries < $n_queries ){
            if ( index ( lc $highlights->[$count_search]->{queries}[$count_search_queries], lc $unaccented_searched ) != -1 ){
                $vars->{url_search} = $highlights->[$count_search]->{url};
                my $title =  Encode::encode( 'UTF-8', decode_entities ( $highlights->[$count_search]->{title}) );
                my $unaccented_title = unac_string('UTF-8', $title);
                my $count_sugestions = 0;
                while ( $count_sugestions < scalar ( @$sugestions ) ){
                    if ( index( lc $sugestions->[$count_sugestions], lc $unaccented_searched ) != -1 ||
                         index ( lc $sugestions->[$count_sugestions], lc $unaccented_title ) != -1 ){
                          $vars->{sugestions} = $sugestions->[$count_sugestions];
                    }
                    $count_sugestions += 1;
                }
            }
            $count_search_queries += 1;
        }
        
        $count_search+=1;
    }
    my $encoded_json = to_json( $vars->{sugestions} );
    $encoded_json = $encoded_json . to_json( $vars->{url_searched} );
    template 'index' => { url_search => $vars->{url_search}, sugestions => $vars->{sugestions} } ;

};

true;


