require 'formula'

class GrIio < Formula
  homepage 'https://github.com/analogdevicesinc/gr-iio'
  url 'https://github.com/analogdevicesinc/gr-iio/archive/v0.3.tar.gz'
  sha256 'e3e6e5f2949256737352184578a342fa53c0c1d33db1f34d73cfb88f5513c077'
  head 'git://github.com/analogdevicesinc/gr-iio'
  
  depends_on 'cmake'
  depends_on 'bison'
  depends_on 'libiio'
  depends_on 'libad9361-iio'
  depends_on 'ttrftech/gnuradio/gnuradio'

  patch :DATA
  
  def install
    mkdir 'build' do
      args = std_cmake_args
      args << "-DIIO_INCLUDE_DIRS=/usr/local/Cellar/libiio/0.14/lib/iio.framework/Headers/"
      args << "-DAD9361_INCLUDE_DIRS=/usr/local/Cellar/libad9361-iio/HEAD-b98b1cd/lib/ad9361.framework/Headers/"
      system 'cmake', '..', *args
      system 'make'
      system 'make install'
    end
  end
end

__END__
