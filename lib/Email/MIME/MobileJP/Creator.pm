package Email::MIME::MobileJP::Creator;
use strict;
use warnings;
use utf8;
use Email::MIME;
use Email::Address::JP::Mobile;

sub new {
    my ($class, $to) = @_;
    my $mail = Email::MIME->create();
    my $carrier = Email::Address::JP::Mobile->new($to || 'foo@example.com');
    my $self = bless { mail => $mail, carrier => $carrier }, $class;
    if ($to) {
        $self->header('To' => $to);
    }
    $self->mail->charset_set($carrier->send_encoding->mime_name);
    return $self;
}

sub mail { $_[0]->{mail} }
sub carrier { $_[0]->{carrier} }

sub subject {
    my $self = shift;
    $self->header('Subject' => @_);
}

sub to { shift->header( 'To' => @_ ) }
sub content_type { shift->mail->content_type(@_) }

sub body {
    my $self = shift;

    if (@_==0) {
        $self->carrier->send_encoding->decode($self->mail->body_raw());
    } else {
        $self->mail->body_set($self->carrier->send_encoding->encode(@_));
    }
}

sub header {
    my ($self, $k, $v) = @_;
    if (defined $v) {
        $self->mail->header_set($k, $self->carrier->mime_encoding->encode($v));
    } else {
        $self->carrier->mime_encoding->decode($self->mail->header_obj->header_raw($k));
    }
}

sub add_part {
    my ($self, $body, $attributes) = @_;
    my $part = Email::MIME->create(
        body       => $body,
        attributes => $attributes,
    );
    $self->mail->parts_add([$part]);
}

sub add_text_part {
    my ($self, $body, $attributes) = @_;

    my $encoding = $self->carrier->send_encoding();
    my $part = Email::MIME->create(
        body       => $encoding->encode($body),
        attributes => {
            content_type => 'text/plain',
            charset      => $encoding->mime_name(),
            encoding     => '7bit',
            %{ $attributes || +{} }
        },
    );
    $self->mail->parts_add([$part]);
}

sub finalize {
    my ($self) = @_;
    return $self->mail;
}

1;

