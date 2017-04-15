require 'formula'

class Nginx < Formula
  homepage 'https://nginx.org/'
  url 'https://nginx.org/download/nginx-1.10.2.tar.gz'
  sha256 '1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2'
  version '1.10.2-boxen1'

  depends_on 'pcre'

  skip_clean 'logs'

  def options
    [
      ['--with-passenger',   "Compile with support for Phusion Passenger module"],
      ['--with-webdav',      "Compile with support for WebDAV module"],
      ['--with-gzip-static', "Compile with support for Gzip Static module"],
      ['--with-http2',       "Compile with support for the HTTP/2 module"],
    ]
  end

  depends_on "pcre"
  depends_on "openssl" => :recommended

  def passenger_config_args
      @passenger_root = `passenger-config --root`.chomp

      if File.directory?(@passenger_root)
        return "--add-module=#{@passenger_root}/ext/nginx"
      end

      puts "Unable to install nginx with passenger support. The passenger"
      puts "gem must be installed and passenger-config must be in your path"
      puts "in order to continue."
      exit
  end

  def install
    pcre = Formula["pcre"]
    openssl = Formula["openssl"]
    cc_opt = "-I#{pcre.include} -I#{openssl.include}"
    ld_opt = "-L#{pcre.lib} -L#{openssl.lib}"

    args = ["--prefix=#{prefix}",
            "--with-http_ssl_module",
            "--with-pcre",
            "--with-ipv6",
            "--with-cc-opt=#{cc_opt}",
            "--with-ld-opt=#{ld_opt}",
            "--conf-path=/opt/boxen/config/nginx/nginx.conf",
            "--pid-path=/opt/boxen/data/nginx/nginx.pid",
            "--lock-path=/opt/boxen/data/nginx/nginx.lock"]

    args << passenger_config_args if ARGV.include? '--with-passenger'
    args << "--with-http_dav_module" if ARGV.include? '--with-webdav'
    args << "--with-http_gzip_static_module" if ARGV.include? '--with-gzip-static'
    args << "--with-http_v2_module" if ARGV.include? "--with-http2"

    system "./configure", *args
    system "cp -R #{@passenger_root}/ext/* src/core"
    system "make"
    system "make install"
    man8.install "objs/nginx.8"

    # remove unnecessary config files
    system "rm -rf #{etc}/nginx"
  end
end
