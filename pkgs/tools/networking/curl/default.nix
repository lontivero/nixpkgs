{ stdenv, fetchurl, libnghttp2, pkgconfig, perl
, idnSupport ? false, libidn ? null
, ldapSupport ? false, openldap ? null
, zlibSupport ? false, zlib ? null
, sslSupport ? false, openssl ? null
, scpSupport ? false, libssh2 ? null
, gssSupport ? false, gss ? null
, c-aresSupport ? false, c-ares ? null
}:

assert idnSupport -> libidn != null;
assert ldapSupport -> openldap != null;
assert zlibSupport -> zlib != null;
assert sslSupport -> openssl != null;
assert scpSupport -> libssh2 != null;
assert c-aresSupport -> c-ares != null;

stdenv.mkDerivation rec {
  name = "curl-7.47.0";

  src = fetchurl {
    url = "http://curl.haxx.se/download/${name}.tar.bz2";
    sha256 = "0riz70pjg82gbcfi2ndvsksb2dv55g31ir8piph2p6zvhy9ny29b";
  };

  nativeBuildInputs = [ pkgconfig perl ];

  # Zlib and OpenSSL must be propagated because `libcurl.la' contains
  # "-lz -lssl", which aren't necessary direct build inputs of
  # applications that use Curl.
  propagatedBuildInputs = with stdenv.lib;
    [ libnghttp2 ] ++
    optional idnSupport libidn ++
    optional ldapSupport openldap ++
    optional zlibSupport zlib ++
    optional gssSupport gss ++
    optional c-aresSupport c-ares ++
    optional sslSupport openssl ++
    optional scpSupport libssh2;

  # for the second line see http://curl.haxx.se/mail/tracker-2014-03/0087.html
  preConfigure = ''
    sed -e 's|/usr/bin|/no-such-path|g' -i.bak configure
    rm src/tool_hugehelp.c
  '';

  configureFlags = [
      "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
      "--disable-manual"
      "--with-nghttp2=${libnghttp2}"
      ( if sslSupport then "--with-ssl=${openssl}" else "--without-ssl" )
      ( if scpSupport then "--with-libssh2=${libssh2}" else "--without-libssh2" )
      ( if ldapSupport then "--enable-ldap" else "--disable-ldap" )
      ( if ldapSupport then "--enable-ldaps" else "--disable-ldaps" )
      ( if idnSupport then "--with-libidn=${libidn}" else "--without-libidn" )
    ]
    ++ stdenv.lib.optional c-aresSupport "--enable-ares=${c-ares}"
    ++ stdenv.lib.optional gssSupport "--with-gssapi=${gss}";

  CXX = "g++";
  CXXCPP = "g++ -E";

  crossAttrs = {
    # We should refer to the cross built openssl
    # For the 'urandom', maybe it should be a cross-system option
    configureFlags = [
        ( if sslSupport then "--with-ssl=${openssl.crossDrv}" else "--without-ssl" )
        "--with-random /dev/urandom"
      ];
  };

  passthru = {
    inherit sslSupport openssl;
  };

  meta = with stdenv.lib; {
    description = "A command line tool for transferring files with URL syntax";
    homepage    = http://curl.haxx.se/;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.all;
  };
}
