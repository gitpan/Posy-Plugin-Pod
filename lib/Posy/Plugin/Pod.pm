package Posy::Plugin::Pod;
use strict;

=head1 NAME

Posy::Plugin::Pod - Posy plugin to convert POD files to HTML.

=head1 VERSION

This describes version B<0.42> of Posy::Plugin::Pod.

=cut

our $VERSION = '0.42';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	...
	Posy::Plugin::EntryTitles
	Posy::Plugin::Pod
	...);
    %file_extensions = (
	txt=>'text',
	html=>'html',
	...
	pm=>'pod',
	pod=>'pod',
    );

=head1 DESCRIPTION

This uses the Pod::Simple::HTML module to convert the the POD (Plain Old
Documentation) in a .pm or .pod file into HTML.  This expects the
file_extensions to have been set so that files with appropriate extensions
(such as .pm or .pod) will have been set with a file-type of 'pod'.  This
then converts entries of the 'pod' type.

This replaces the 'parse_entry' method, and calls the parent
method for anything other than POD.

This also replaces the 'get_title' method used by
Posy::Plugin::EntryTitles, so if one is using that module, one needs to put
this after that in the plugin list.

=cut

=head1 Entry Action Methods

Methods implementing per-entry actions.

=head2 parse_entry

$self->parse_entry($flow_state, $current_entry, $entry_state)

Parses $current_entry->{raw} into $current_entry->{title}
and $current_entry->{body}

=cut
sub parse_entry {
    my $self = shift;
    my $flow_state = shift;
    my $current_entry = shift;
    my $entry_state = shift;

    my $id = $current_entry->{id};
    my $file_type = $self->{file_extensions}->{$self->{files}->{$id}->{ext}};
    if ($file_type eq 'pod')
    {
	$self->debug(2, "$id is pod");
	my $html;
	$self->_init_pod_obj();
	$self->{Pod}->{obj}->output_string(\$html);
	$self->{Pod}->{obj}->set_source(\$current_entry->{raw});
	$self->{Pod}->{obj}->run;
	$html =~ m#<title>(.*)</title>#is;
	$current_entry->{title} = $1;
	$html =~ m#<body([^>]*)>(.*)</body>#is;
	$current_entry->{body_attrib} = $1;
	$current_entry->{body} = $2;
	# this doesn't work properly on multiple texts, so delete the object
	delete $self->{Pod}->{obj};
    }
    else # use parent
    {
	$self->SUPER::parse_entry($flow_state, $current_entry, $entry_state);
    }
    1;
} # parse_entry

=head1 Helper Methods

Methods which can be called from elsewhere.

=head2 get_title

    $title = $self->get_title($file_id);

Get the title of the given entry file (by reading the file).

=cut
sub get_title {
    my $self = shift;
    my $file_id = shift;

    my $fullname = $self->{files}->{$file_id}->{fullname};
    my $ext = $self->{files}->{$file_id}->{ext};
    my $file_type = $self->{file_extensions}->{$ext};
    my $title = '';
    my $fh;
    if ($file_type eq 'pod')
    {
	my $html;
	$self->_init_pod_obj();
	$self->{Pod}->{obj}->output_string(\$html);
	$self->{Pod}->{obj}->set_source($fullname);
	$title = $self->{Pod}->{obj}->get_short_title;
	$title = $self->{files}->{$file_id}->{basename} if (!$title);
	$self->debug(2, "$file_id title=$title");
	# This needs to be reset without actually parsing the file
	# so just delete the object
	delete $self->{Pod}->{obj};
    }
    else # use parent
    {
	$title = $self->SUPER::get_title($file_id);
    }
    return $title;
} # get_title

=head1 Private Methods

=head2 _init_pod_obj

Make the Pod::Simple::HTML object.

=cut
sub _init_pod_obj {
    my $self = shift;

    # make only one Pod::Simple::HTML object
    if (!defined $self->{Pod}->{obj})
    {
	require Pod::Simple::HTML;

	$self->{Pod}->{obj} = Pod::Simple::HTML->new;
	$self->{Pod}->{obj}->no_errata_section(1);
	$self->{Pod}->{obj}->index(1);
	# set some of the Pod::Simple::HTML globals
	$Pod::Simple::HTML::Computerese = '';
    }
} # _init_pod_obj

=head1 INSTALLATION

Installation needs will vary depending on the particular setup a person
has.

=head2 Administrator, Automatic

If you are the administrator of the system, then the dead simple method of
installing the modules is to use the CPAN or CPANPLUS system.

    cpanp -i Posy::Plugin::Pod

This will install this plugin in the usual places where modules get
installed when one is using CPAN(PLUS).

=head2 Administrator, By Hand

If you are the administrator of the system, but don't wish to use the
CPAN(PLUS) method, then this is for you.  Take the *.tar.gz file
and untar it in a suitable directory.

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you're on a platform (like DOS or Windows) that doesn't like the
"./" notation, you can do this:

   perl Build.PL
   perl Build
   perl Build test
   perl Build install

=head2 User With Shell Access

If you are a user on a system, and don't have root/administrator access,
you need to install Posy somewhere other than the default place (since you
don't have access to it).  However, if you have shell access to the system,
then you can install it in your home directory.

Say your home directory is "/home/fred", and you want to install the
modules into a subdirectory called "perl".

Download the *.tar.gz file and untar it in a suitable directory.

    perl Build.PL --install_base /home/fred/perl
    ./Build
    ./Build test
    ./Build install

This will install the files underneath /home/fred/perl.

You will then need to make sure that you alter the PERL5LIB variable to
find the modules, and the PATH variable to find the scripts (posy_one,
posy_static).

Therefore you will need to change:
your path, to include /home/fred/perl/script (where the script will be)

	PATH=/home/fred/perl/script:${PATH}

the PERL5LIB variable to add /home/fred/perl/lib

	PERL5LIB=/home/fred/perl/lib:${PERL5LIB}

=head1 REQUIRES

    Posy
    Posy::Core
    Pod::Simple::HTML

    Test::More

=head1 SEE ALSO

perl(1).
Posy
Pod::Simple::HTML

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2004-2005 by Kathryn Andersen

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Posy::Plugin::Pod
__END__
