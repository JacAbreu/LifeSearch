package LiveSearchDancer;
use Dancer ':syntax';

use JSON qw( decode_json );
use Data::Dumper;
use utf8;
use HTML::Entities;
use Encode;
use Text::Unaccent;
use List::MoreUtils qw(uniq);

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/livesearch' => sub {
    content_type 'application/json';
    my $searched = param('q');
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
    my $suggestions = $decoded_json->{suggestions} ;
    my $n_highlights = scalar ( @$highlights );
    my $count_search = 0;
    my @urls;
    my @suggestions;

    while ( $count_search < $n_highlights ){
        my $n_queries = scalar( @{ $highlights->[$count_search]->{queries}} );
        my $count_search_queries = 0;
        while ( $count_search_queries < $n_queries ){
               if ( index ( lc $highlights->[$count_search]->{queries}[$count_search_queries], lc $unaccented_searched ) != -1 ){
                    if( length( $unaccented_searched) > 2 ){
                        push @urls, $highlights->[$count_search]->{url};
                    }
                my $title =  Encode::encode( 'UTF-8', decode_entities ( $highlights->[$count_search]->{title}) );
                my $unaccented_title = unac_string('UTF-8', $title);
                my $count_suggestions = 0;
                
                while ( $count_suggestions < scalar ( @$suggestions ) ){
                    if ( index( lc $suggestions->[$count_suggestions], lc $unaccented_searched ) != -1  ||
                         index ( lc $suggestions->[$count_suggestions], lc $unaccented_title ) != -1 ){
                            push @suggestions, $suggestions->[$count_suggestions];
                    }
                    $count_suggestions += 1;
                }
            }
            $count_search_queries += 1;
        }
        $count_search+=1;
    }
    
    my @indications;
    push (@indications, @urls);
    push (@indications, @suggestions);
    my @uniq_indications = uniq @indications;
    return to_json { suggestions => \@uniq_indications } ;

};

true;


