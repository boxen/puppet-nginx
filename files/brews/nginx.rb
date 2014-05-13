require 'formula'

class Nginx < Formula
  homepage 'http://nginx.org/'
  url 'http://nginx.org/download/nginx-1.4.4.tar.gz'
  sha1 '304d5991ccde398af2002c0da980ae240cea9356'
  version '1.4.4-boxen1'

  depends_on 'pcre'

  skip_clean 'logs'

  def options
    [
      ['--with-passenger',   "Compile with support for Phusion Passenger module"],
      ['--with-webdav',      "Compile with support for WebDAV module"],
      ['--with-gzip-static', "Compile with support for Gzip Static module"],
      ['--with-uploadprogress', "Compile with support upload-progress"]
    ]
  end

  def passenger_config_args
      passenger_root = `passenger-config --root`.chomp

      if File.directory?(passenger_root)
        return "--add-module=#{passenger_root}/ext/nginx"
      end

      puts "Unable to install nginx with passenger support. The passenger"
      puts "gem must be installed and passenger-config must be in your path"
      puts "in order to continue."
      exit
  end

  def uploadprogress_config_args
      uploadprogress_root = `/opt/boxen/homebrew/Cellar/upload-progress-nginx-module/0.9.0`

      if File.directory?(uploadprogress_root)
        return "--add-module=/opt/boxen/homebrew/Cellar/upload-progress-nginx-module/0.9.0"
      end

      puts "Unable to install nginx with UploadProgress support. The package"
      puts "must be installed, run:"
      puts "brew install homebrew/nginx/upload-progress-nginx-module"
      exit
  end

  def install
    args = ["--prefix=#{prefix}",
            "--with-http_ssl_module",
            "--with-pcre",
            "--with-ipv6",
            "--with-cc-opt='-I#{HOMEBREW_PREFIX}/include'",
            "--with-ld-opt='-L#{HOMEBREW_PREFIX}/lib'",
            "--conf-path=/opt/boxen/config/nginx/nginx.conf",
            "--pid-path=/opt/boxen/data/nginx/nginx.pid",
            "--lock-path=/opt/boxen/data/nginx/nginx.lock"]

    args << passenger_config_args if ARGV.include? '--with-passenger'
    args << "--with-http_dav_module" if ARGV.include? '--with-webdav'
    args << "--with-http_gzip_static_module" if ARGV.include? '--with-gzip-static'

    system "./configure", *args
    system "make"
    system "make install"
    man8.install "objs/nginx.8"

    # remove unnecessary config files
    system "rm -rf #{etc}/nginx"
  end
end
