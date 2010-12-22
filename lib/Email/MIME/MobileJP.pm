package Email::MIME::MobileJP;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';

use Email::MIME;
use Email::Address::JP::Mobile;
use Email::Address::Loose -override;
use Encode::MIME::Header::ISO_2022_JP;

sub new {
    my $class = shift;
    my $mail = Email::MIME->new(@_);
    bless { mail => $mail }, $class;
}

BEGIN {
    no strict 'refs';
    for my $meth (qw/walk_parts header_obj header_set header/) {
        *{__PACKAGE__ . "::$meth"} = sub {
            shift->mail->$meth(@_)
        }
    }
}

sub mail { shift->{mail} }

sub subject {
    my $self = shift;
    my $carrier = $self->carrier;
    return $carrier && $carrier->is_mobile ? $carrier->mime_encoding->decode($self->mail->header_obj->header_raw('Subject')) : $self->mail->header('Subject');
}

sub header_raw {
    my $self = shift;
    $self->mail->header_obj->header_raw(@_);
}

sub from {
    my $self = shift;

    my @addr;
    for my $from ($self->mail->header('From')) {
        push @addr, Email::Address::Loose->new($from);
    }
    return @addr;
}

sub to {
    my $self = shift;

    my @addr;
    for my $to ($self->mail->header('To')) {
        push @addr, Email::Address::Loose->new($to);
    }
    return @addr;
}

sub carrier {
    my ($self, ) = @_;
    my $from = $self->header('From');
    Carp::croak("Missing 'From' field in headers") unless $from;
    return $self->{__jpmobile_from} ||= Email::Address::JP::Mobile->new($from);
}

sub get_texts {
    my ($self, $content_type) = @_;
    $content_type ||= qr{^text/plain};

    if ($self->carrier->is_mobile) {
        my $encoding = $self->carrier->parse_encoding;
        return map { $encoding->decode($_->body) } $self->get_parts($content_type);
    } else {
        return map { $_->body_str } $self->get_parts($content_type);
    }
}

sub get_parts {
    my ($self, $content_type) = @_;
    Carp::croak("missing content-type") unless defined $content_type;

    my @parts;
    $self->mail->walk_parts(sub {
        my $part = shift;
        return if $part->parts > 1; # multipart

        if ($part->content_type =~ $content_type) {
            push @parts, $part;
        }
    });
    return @parts;
}


1;
__END__

=encoding utf8

=head1 NAME

Email::MIME::MobileJP - E-mail toolkit for Japanese Mobile Phones

=head1 SYNOPSIS

  use Email::MIME::MobileJP;

=head1 DESCRIPTION

Email::MIME::MobileJP is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
