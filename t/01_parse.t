use strict;
use warnings;
use utf8;
use Test::More;
use Email::MIME::MobileJP;
use Email::MIME;
use Encode;
use MIME::Base64;

subtest 'single part' => sub {
    my $src = Email::MIME->create(
        header => [
            From => 'tomi...@docomo.ne.jp',
            To   => 'to@example.com',
            Subject =>
            Encode::encode( 'MIME-Header-ISO_2022_JP', 'コンニチワ' ),
        ],
        attributes => {
            content_type => 'text/plain',
            charset      => 'iso-2022-jp',
        },
        body => encode( 'iso-2022-jp', '元気でやってるかー?' ),
    );

    my $mail = Email::MIME::MobileJP->new($src->as_string);

    subtest 'subject' => sub {
        is $mail->subject(), 'コンニチワ';
        ok Encode::is_utf8($mail->subject), 'decoded';
    };

    subtest 'carrier' => sub {
        isa_ok $mail->carrier, 'Email::Address::JP::Mobile::DoCoMo';
        is $mail->carrier->name, 'DoCoMo';
    };

    subtest 'get_texts' => sub {
        my @texts = $mail->get_texts();
        is scalar(@texts), 1;
        is $texts[0], '元気でやってるかー?';
        ok Encode::is_utf8($texts[0]);
    };
};

subtest 'multi part' => sub {
    my $src = Email::MIME->create(
        'header' => [
            'From'    => encode( 'MIME-Header-ISO_2022_JP', 'foo.@docomo.ne.jp' ),
            'To'      => encode( 'MIME-Header-ISO_2022_JP', 'foo@example.com' ),
            'Subject' => encode( 'MIME-Header-ISO_2022_JP', "おこんちわ" ),
        ],
        parts => [
            Email::MIME->create(
                'attributes' => {
                    'content_type' => 'text/plain',
                    'charset'      => 'ISO-2022-JP',
                    'encoding'     => '7bit',
                },
                'body' => Encode::encode( 'iso-2022-jp', "やっほ" ),
            ),
            Email::MIME->create(
                'attributes' => {
                    'fimename'     => 'hoge.jpg',
                    'content_type' => 'image/jpeg',
                    'encoding'     => 'base64',
                    'name'         => 'sample.jpg',
                },
                'body' => 'JFIF(ry',
            ),
        ],
    );
    note $src->as_string;

    my $mail = Email::MIME::MobileJP->new($src->as_string);

    subtest 'get_texts' => sub {
        my @texts = $mail->get_texts();
        is scalar(@texts), 1;
        is $texts[0], "やっほ\n";
        ok Encode::is_utf8($texts[0]);
    };

    subtest 'get_parts' => sub {
        my @parts = $mail->get_parts(qr{^image/(gif|png|jpeg)});
        is scalar(@parts), 1;
        is $parts[0]->content_type, 'image/jpeg; name="sample.jpg"';
        isa_ok $parts[0], 'Email::MIME';
        is $parts[0]->body, 'JFIF(ry';
    };
};

subtest 'UTF-8 mail from PC' => sub {
    my $src = Email::MIME->create(
        header => [
            From => 'foo@example.com',
            To   => 'to@example.com',
            Subject => Encode::encode( 'MIME-Header', 'コンニチワ' ),
        ],
        attributes => {
            content_type => 'text/plain',
            charset      => 'utf-8',
        },
        body => encode( 'utf-8', '元気でやってるかー?' ),
    );

    my $mail = Email::MIME::MobileJP->new($src->as_string);

    is $mail->subject(), 'コンニチワ';

    my @texts = $mail->get_texts();
    is scalar(@texts), 1;
    is $texts[0], '元気でやってるかー?';
};

done_testing;

