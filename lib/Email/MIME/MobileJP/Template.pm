package Email::MIME::MobileJP::Template;
use strict;
use warnings;
use utf8;

use Tiffany;
use Encode ();
use Email::MIME;
use Email::Date::Format;

sub new {
    my ( $class, $name, $args ) = @_;
    my $tiffany = Tiffany->load( $name, $args );
    return bless { tiffany => $tiffany }, $class;
}

sub render {
    my ( $self, $tmpl, $args, $to ) = @_;
    $args ||= +{};

    my $carrier = Email::Address::JP::Mobile->new($to || 'foo@example.com');

    my @lines = split /\n/, $self->{tiffany}->render( $tmpl, {%$args} );
    my @headers;
    while ( @lines > 0 && $lines[0] =~ /^([A-Z][A-Za-z_-]+)\s*:\s*(.+?)$/ ) {
        my ( $key, $val ) = ( $1, $2 );
        push @headers, $key, $carrier->mime_encoding->encode( $val );
        shift @lines;
    }
    if ( @lines > 0 && $lines[0] =~ /^\s*$/ ) {
        shift @lines;
    }
    my $body = $carrier->send_encoding->encode( join( "\n", @lines );

    return Email::MIME->create(
        header     => @headers ? \@headers : [Date => Email::Date::Format::email_date()],
        body       => $body,
        attributes => {
            content_type => 'text/plain',
            charset      => 'ISO-2022-JP',
            encoding     => '7bit',
        },
    );
}

1;
__END__

=encoding utf8

=head1 NAME

Email::MIME::JPMobile::Template - 日本語でメールを送信するときに楽するライブラリ

=head1 SYNOPSIS

    use Email::MIME::JPMobile::Template;
    use Email::Sender::Simple qw/sendmail/;

    my $estj = Email::MIME::JPMobile::Template->new(
        'Text::Xslate' => {
            syntax => 'TTerse',
            path   => ['./email_tmpl/'],
        },
    );
    my $email = $estj->render('foo.eml', {token => $token});
    sendmail($email);

=head1 DESCRIPTION

日本語でメールを送信できます。

テンプレートファイルには

    Subject: [% name %]様へお特な情報のご案内

    おとくですよ！
    http://example.com[% path_info %]

のようにかくことができます。

最初のヘッダ行はなくてもかまいません。

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
