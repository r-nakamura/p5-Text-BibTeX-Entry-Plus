#!/usr/bin/env perl

package Text::BibTeX::Entry::Plus;

our $VERSION = "0.01";

use strict;
use warnings;

use Carp;
use Text::BibTeX;

use parent 'Text::BibTeX::Entry';

# This code is taken from Text::BibTeX::Entry and modified.
sub print_s {
    my $self = shift;
    my ($field, $output);

    sub value_to_string
    {
        my $value = shift;

        if (! ref $value)                 # just a string
        {
            return "{$value}";
        }
        else                              # a Text::BibTeX::Value object
        {
            confess "value is a reference, but not to Text::BibTeX::Value object"
                unless $value->isa ('Text::BibTeX::Value');
            my @values = $value->values;
            foreach (@values)
            {
                $_ = $_->type == &BTAST_STRING ? '{' . $_->text . '}' : $_->text;
            }
            return join (' # ', @values);
        }
    }

    carp "entry type undefined" unless defined $self->{'type'};
    carp "entry metatype undefined" unless defined $self->{'metatype'};

    # Regular and macro-def entries have to be treated differently when
    # printing the first line, because the former have keys and the latter
    # do not.
    if ($self->{'metatype'} == &BTE_REGULAR)
    {
        carp "entry key undefined" unless defined $self->{'key'};
        $output = sprintf ("@%s{%s,\n",
                           $self->{'type'} || '',
                           $self->{'key'}  || '');
    }
    elsif ($self->{'metatype'} == &BTE_MACRODEF)
    {
        $output = sprintf ("@%s{\n",
                           $self->{'type'} || '');
    }

    # Comment and preamble entries are treated the same -- we print out
    # the entire entry, on one line, right here.
    else                                 # comment or preamble
    {
        return sprintf ("@%s{%s}\n\n",
                        $self->{'type'},
                        value_to_string ($self->{'value'}));
    }

    # Here we print out all the fields/values of a regular or macro-def entry
    my @fields = @{$self->{'fields'}};
    while ($field = shift @fields)
    {
        my $value = $self->{'values'}{$field};
        if (! defined $value)
        {
            carp "field \"$field\" has undefined value\n";
            $value = '';
        }

        $output .= "  $field = ";
        if ($value =~ /^\d+$/) {
            $output .= $value;
        }
        elsif ($field eq 'month') {
            $output .= lc( substr $value, 0, 3 );
        }
        else {
            $output .= value_to_string ($value);
        }

        $output .= ",\n";
    }

    # Tack on the last line, and we're done!
    $output .= "}\n\n";
    
    Text::BibTeX->_process_result($output, $self->{binmode}, $self->{normalization});
}

sub export_as_string {
    my $self = shift;
    my %opts = @_;
    my @fields;

    push @fields, $self->export_author();
    push @fields, $self->export_title();

    if ( $self->type() =~ /article/ ) {
        push @fields, $self->export_journal();
        push @fields, $self->export_volume();
        push @fields, $self->export_issue();
        push @fields, $self->export_number();
    }
    elsif ( $self->type() =~ /inproceedings/ ) {
        push @fields, $self->export_booktitle();
    }
    elsif ( $self->type() =~ /misc/ ) {
        push @fields, $self->export_journal();
    }

    push @fields, $self->export_page();
    if (exists $opts{'japanese'}) {
        push @fields, $self->export_japanese_date();
    }
    else {
        push @fields, $self->export_date();
    }

    @fields = map {
        $_ =~ s/\{\\rm\s+(.+)\}/$1/g; $_;
    } grep { defined $_ } @fields;
    
    return join ', ', @fields;
}

sub export_author {
    my $self = shift;
    my $author = $self->get( 'author' );
    if ( $author =~ /^[a-zA-Z,\s]+$/ ) {
        my @authors = $self->split( 'author' );
        @authors = map {
            my ($first, $last) = split /\s+/, $_;
            $first = substr $first, 0, 1;
            "$first. $last";
        } @authors;
        if (scalar(@authors) >= 2) {
            $author = join(', ', @authors[0 .. $#authors - 1]) . ' and ' . $authors[$#authors];
        }
        else {
            $author = $authors[0];
        }
    }
    else {
        # for japanese kanji
        $author =~ s/^{//; $author =~ s/}$//;
    }
    return $author;
}

sub export_title {
    my $self = shift;
    my $title = $self->get( 'title' );
    $title =~ s/\{([^\}]+)\}/$1/g;
    return '"' . $title . '"';
}

sub export_journal {
    return $_[0]->get( 'journal' );
}

sub export_volume {
    my $self = shift;
    my $vol = $self->get( 'volume' );
    return $vol ? "vol. $vol" : undef;
}

sub export_issue {
    my $self = shift;
    my $issue = $self->get( 'issue' );
    return $issue ? "issue. $issue" : undef;
}

sub export_number {
    my $self = shift;
    my $number = $self->get( 'number' );
    return $number ? "no. $number" : undef;
}

sub export_booktitle {
    return $_[0]->get( 'booktitle' );
}

sub export_page {
    my $self = shift;
    my $page = $self->get( 'page' ) || $self->get( 'pages' );
    $page =~ s/--/-/ if $page;
    return $page ? "pp. $page" : undef;
}

sub export_date {
    my $self = shift;
    my $month = $self->get( 'month' );
       $month = substr( $month, 0, 3 ) if $month;
    my $year = $self->get( 'year' );
    return ($month and $year) ? "$month. $year." : "$year.";
}

sub export_japanese_date {
    my %JAPANESE_MONTH = (
        'Jan' => 1, 'Feb' => 2,  'Mar' => 3,  'Apr' => 4,
        'May' => 5, 'Jun' => 6,  'Jul' => 7,  'Aug' => 8,
        'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12,
    );
    my $self = shift;
    my $month = $self->get( 'month' );
       $month = $JAPANESE_MONTH{substr( $month, 0, 3 )} if $month;
    my $year = $self->get( 'year' );
    return ($month and $year) ? "$year 年 $month 月" : "$year 年";
}

1;

__END__

=encoding utf-8

=head1 NAME

Text::BibTeX::Entry::Plus - helper for exporting bibliography in an arbitrary format from BibTeX files

=head1 SYNOPSIS

    use Text::BibTeX::Entry::Plus;

    $bibfile = Text::BibTeX::File->new('PATH_TO_BIBFILE');
    $entry = Text::BibTeX::Entry::Plus->new($bibfile);

    $entry->export_as_string();

=head1 DESCRIPTION

Text::BibTeX::Entry::Plus provides helper functions for exporting
bibliography in an arbitrary format from BibTeX files, which is an
extension of a Perl module, Text::BibTeX::Entry.

Using Text::BibTeX::Entry::Plus, you can export your bibliography in
arbitrary format (e.g., Text, HTML, and CSV) if you are familiar with
Perl language.

=head1 SEE ALSO

Text::BibTeX(3pm)

=head1 LICENSE

Copyright (C) Ryo Nakamura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ryo Nakamura <nakamura[atmark]zebulun.net>

=cut

