package Email::MIME::MobileJP::Parser;
use strict;
use warnings;
use utf8;

use Email::MIME;
use Email::Address::JP::Mobile;
use Email::Address::Loose -override;
use Carp ();

sub new {
    my $class = shift;
    my $mail = Email::MIME->new(@_);
    bless { mail => $mail }, $class;
}

sub mail { shift->{mail} }

sub subject {
    my $self = shift;
    my $carrier = $self->carrier;
    return $carrier && $carrier->is_mobile ? $carrier->mime_encoding->decode($self->mail->header_obj->header_raw('Subject')) : $self->mail->header('Subject');
}

sub from {
    my $self = shift;

    my ($from) = $self->mail->header('From');
    return unless $from;
    my ($addr) = Email::Address::Loose->parse($from);
    return $addr;
}

sub to {
    my $self = shift;

    my @addr;
    for my $to ($self->mail->header('To')) {
        push @addr, Email::Address::Loose->parse($to);
    }
    return @addr;
}

sub carrier {
    my ($self, ) = @_;
    my $from = $self->mail->header('From');
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

Email::MIME::MobileJP::Parser - E-Mail parser toolkit for Japanese mobile phones(based on Email::MIME)

=head1 SYNOPSIS

    my $mail = Email::MIME::MobileJP::Parser->new($mail_txt);

=head1 DESCRIPTION

This is a E-Mail parser toolkit for Japanese mobile phones.

=head1 METHODS

=over 4

=item my $mail = Email::MIME::MobileJP::Parser->new($mail_txt);

The constructor です。メールの text をわたしてください。

=item my $mime = $mail->mail();

L<Email::MIME> のインスタンスそのものをえます。こまかい処理がやりたくて Email::MIME::MobileJP::Parser では不十分なときなどによんでください。

=item my $subject = $mail->subject();

Subject をかえします。L<Encode::JP::Mobile> を利用し、可能なら絵文字も decode します。現時点では絵文字は au の場合のみ decode 可能です(キャリア側の制限によります)。

=item my $from = $mail->from();

From ヘッダを解析し、L<Email::Address::Loose> のオブジェクトをかえします。

=item my ($to) = $mail->to();

To ヘッダを解析し、L<Email::Address::Loose> の配列でかえします。

=item my $carrier = $mail->carrier();

From よりもとめた L<Email::Address::JP::Mobile> のインスタンスをかえします。

=item my @texts = $mail->get_texts([$content_type]);

メールにふくまれるテキストを配列でかえします。$content_type は正規表現で指定します。デフォルトは qr{^text/plain} です。
返り値は適切なエンコーディングで decode されます。

=item my @parts = $mail->get_parts($content_type : Regexp)

$content_type にマッチする Content-Type を含むパートの配列をかえします。各要素は L<Email::MIME> のインスタンスです。
たいていの場合は C<<< $parts[0]->content_type >>> と C<<< $parts[0]->body >>> そして C<<< $parts[0]->filename >>> をしっておけばことたりるでしょう。

このメソッドは、メールに添付されている画像を取得したい、などという場合に有用でしょう。

=back

