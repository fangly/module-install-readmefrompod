use strict;
use warnings;
use Test::More; #tests => 1;
use File::Temp      qw[tempdir];
use File::Path      qw[rmtree];
use Capture::Tiny   qw[capture_merged];
use Config;

unless ( -e 'have_make' ) {
  plan skip_all => 'No network tests';
}

plan tests => 3;

{
my $make = $Config{make};
mkdir 'dist';
my $tmpdir = tempdir( DIR => 'dist', CLEANUP => 1 );
chdir $tmpdir or die "$!\n";
open READMEPM , '>README.pm' or die "$!\n";
print READMEPM <<README;
package README;
use 5.006002;
our \$VERSION = '0.01';

=head1 NAME

Foo::Bar - Putting the Foo into Bar

=head1 DESCRIPTION

It is like chocolate, but not.

=head1 AUTHOR

Foo Bar

=head1 COPYRIGHT

Copyright (c) 2010. Foo Bar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
README
close READMEPM;
open MFPL, '>Makefile.PL' or die "$!\n";
print MFPL <<EOF;
use inc::Module::Install;
name 'Foo-Bar';
all_from 'README.pm';
readme_from;
WriteAll;
EOF
close MFPL;
my $merged = capture_merged { system "$^X Makefile.PL" };
diag("$merged");
# Copied /usr/lib/perl5/site_perl/5.8.8/Devel/CheckOS.pm to
#        inc/Devel/CheckOS.pm
# Copied /usr/lib/perl5/site_perl/5.8.8/Devel/AssertOS.pm to
#        inc/Devel/AssertOS.pm
# Copied /usr/lib/perl5/site_perl/5.8.8/Devel/AssertOS/NetBSD.pm to
#        inc/Devel/AssertOS/NetBSD.pm
my @tests = (
'inc/Module/Install/ReadmeFromPod.pm',
);
ok( -e $_, "Exists: '$_'" ) for @tests;
ok( -e 'README', 'There is a README file' );

my $distclean = capture_merged { system "$make distclean" };
diag("$distclean");

ok( -e 'README', 'There is a README file' );

}
exit 0;
