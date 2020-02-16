## no critic: Modules::ProhibitAutomaticExportation
package Perinci::Package::CopyFrom;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;
use Log::ger;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(copy_from);

use Package::CopyFrom ();

sub copy_from {
    my $opts = ref $_[0] eq 'HASH' ? shift : {};
    my $src_pkg = shift;

    $opts->{to} = caller unless defined $opts->{to};

    $opts->{_before_copy} = sub {
        my ($name, $src_pkg, $target_pkg, $opts, $overwrite) = @_;
        return 1 if $name eq '%SPEC';
        0;
    };
    $opts->{_after_copy} = sub {
        my ($name, $src_pkg, $target_pkg, $opts, $overwrite) = @_;
        ${"$target_pkg\::SPEC"}{$name} = ${"$src_pkg\::SPEC"}{$name}
            if defined ${"$src_pkg\::SPEC"}{$name};
    };
    Package::CopyFrom::copy_from($opts, $src_pkg);
}

1;
# ABSTRACT: Copy (some) contents from another package (with Rinci metadata awareness)

=head1 SYNOPSIS

 package My::Source;
 our %SPEC;
 $SPEC{func1} = {...}
 sub func1 { ... }
 $SPEC{func2} = {...}
 sub func2 { ... }
 $SPEC{func3} = {...}
 sub func3 { ... }
 1;

 package My::Modified;
 use Package::CopyFrom; # exports copy_from()
 BEGIN { copy_from 'My::Source' } # copies 'func1', 'func2', 'func3' as well as their Rinci metadata
 our %SPEC;

 # provide our own modification to 'func2'
 $SPEC{func2} = { ... }
 sub func2 { ... }

 # provide our own modification to 'func3', using some helper from
 # Perinci::Sub::Util
 use Perinci::Sub::Util qw(gen_modified_sub);
 gen_modified_sub(...);

 # add a new function 'func4'
 $SPEC{func4} = { ... }
 sub func4 { ... }
 1;


=head1 DESCRIPTION

This is a variant of L<Package::CopyFrom> that can also copy Rinci metadata for
you.


=head1 FUNCTIONS

=head2 copy_from

See L<Package::CopyFrom/copy_from>.


=head1 SEE ALSO

L<Rinci>, L<Perinci>, L<Package::CopyFrom>.

=cut
