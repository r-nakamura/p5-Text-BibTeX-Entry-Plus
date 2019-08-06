#!perl

use strict;
use FindBin;

use Test::More;

use Text::BibTeX;
use Text::BibTeX::Entry::Plus;

sub load_bibentry {
    my $bibfile = Text::BibTeX::File->new($FindBin::Bin . '/' . $_[0]);
    return Text::BibTeX::Entry::Plus->new($bibfile);
}

subtest 'for a bib entry with conference paper' => sub {
    my $entry = load_bibentry('conference.bib');
    ok $entry->parse_ok();
    is $entry->export_as_string(), 'H. Hoge and F. Foo, "Studies on Bar and Baz", Proceedings of XXX, pp. 1-6, Apr. 2019.';
    is $entry->export_author(), 'H. Hoge and F. Foo';
    is $entry->export_title(), '"Studies on Bar and Baz"';
    is $entry->export_booktitle(), 'Proceedings of XXX';
    is $entry->export_page(), 'pp. 1-6';
    is $entry->export_date(), 'Apr. 2019.';
    is $entry->export_japanese_date(), '2019 年 4 月';
};

subtest 'for a bib entry with journal paper' => sub {
    my $entry = load_bibentry('article.bib');
    ok $entry->parse_ok();
    is $entry->export_as_string(), 'H. Hoge and F. Foo, "Studies on Bar and Baz", Journal of XXX, vol. 1, pp. 1-10, Apr. 2019.';
    is $entry->export_author(), 'H. Hoge and F. Foo';
    is $entry->export_title(), '"Studies on Bar and Baz"';
    is $entry->export_page(), 'pp. 1-10';
    is $entry->export_date(), 'Apr. 2019.';
    is $entry->export_japanese_date(), '2019 年 4 月';
};

done_testing;
