#TREC topics (tested on Robust04 topics) converted to Indri's file format.
#TODO: instead of manual XML parsing, use a library.

use strict;

#takes a string and cleans it up
sub clean { 
    my $s = shift; 
    $s =~s/[^a-zA-Z0-9]/ /g;  

    #trim whitespaces
    $s =~s/\s\s+/ /g;
    $s =~ s/^\s+//;
    $s =~ s/\s+$//;
    
    $s = lc($s);  
    return $s; 
}

my $numArgs = $#ARGV+ 1;
if($numArgs < 5 ){
    print "Four command line arguments expected: [input: TREC formatted topic file] [output: Indri formatted file] [part (title/desc/narr)] [retrieval rule] [sequential dependence (1 or anything else)]\n";
    exit;
}

my $infile = $ARGV[0]; #topic file in TREC format
my $outfile = $ARGV[1]; #topic file in Indri format
my $topicType = $ARGV[2]; #part of the topic file to consider (encompassing, i.e. choosing desc means title+desc)
my $retrievalRule = $ARGV[3]; #retrieval rule
my $seqDependence = $ARGV[4]; #sequential dependence

if($topicType=~m/title/ || $topicType=~m/desc/ || $topicType=~m/narr/){
    ;
}
else {
    print "The last argument (now: $topicType) is one of title|desc|narr or a combination of them, e.g. title+desc.\n";
    exit;
}


my %stopwords = ();
open(IN, "stoplist.dft")||die $!;
while(<IN>){
    if($_=~m/<.*parameters>/ || $_=~m/<.*stopper>/){;}
    else {
        $_ =~s/.*<word>//;
        $_ =~s/<\/word>.*\n//;
        $stopwords{lc($_)}=1;
    }
}
close(IN);

open(OUT,">>$outfile")||die $!;
print OUT "<parameters>\n";

my $inType = "";
my $currentQuery = "";

open(IN,$infile)||die $!;
while(<IN>){
    chomp;
    if($_ =~m/<num>/){
        print OUT "<query>\n";
        print OUT "<number>";
        my $qid = $_;
        $_ =~s/.*Number\s*:\s*//;  
        $_ =~s/\s+//g;
        print OUT "$_</number>\n";

        print OUT "<text>";
    }
    elsif($_=~m/<top>/){
        $currentQuery = "";
    }
    elsif($_=~m/<\/top>/){

        my @tokens =split(/\s+/,clean($currentQuery));

        my @stoppedTokens;
        #we need to remove stopwords to get valid sd elements 
        foreach my $t(@tokens){
            if(exists $stopwords{$t}){;}
            else {
                push(@stoppedTokens,$t);
            }
        }

        #process $currentQuery
        if($retrievalRule=~m/(okapi|tfidf)/){
            print OUT clean($currentQuery);
        }
        elsif($seqDependence ne "1" || (@stoppedTokens)<3){
            print OUT "#combine($currentQuery)";
        }
        #sequential dependence
        else {
            print OUT "#weight( ";
            print OUT "0.8 #combine(".clean($currentQuery).") ";
            print OUT "0.05 #combine(";

            for(my $i=0; $i<@stoppedTokens-1; $i++){
                print OUT "#1($stoppedTokens[$i] $stoppedTokens[$i+1]) ";
            }

            print OUT ") ";
            print OUT "0.15 #combine(";
            for(my $i=0; $i<@stoppedTokens-1; $i++){
                print OUT "#uw8($stoppedTokens[$i] $stoppedTokens[$i+1]) ";
            }
            print OUT "))";
        }
        print OUT "</text>\n</query>\n";
        $inType = "";
    }
    elsif($_=~m/<title>/ && $topicType=~m/title/){
        $_=~s/<title>\s*//;
        $currentQuery = $currentQuery." ".clean($_);
        $inType = "title";
    }
    elsif($_=~m/<desc>/){
        $_=~s/<desc>\s*//;
        $inType = "desc";
    }
    elsif($_=~m/<narr>/){
        $_=~s/<narr>\s*//;
        $inType = "narr";
    }
    elsif($topicType=~m/$inType/){
        $currentQuery = $currentQuery." ".clean($_);
    }
    else {
        ;
    }
}

print OUT "</parameters>\n";
close(OUT);
close(IN);
