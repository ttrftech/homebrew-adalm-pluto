require 'formula'

class Libad9361Iio < Formula
  homepage 'https://github.com/analogdevicesinc/libad9361-iio'
  url 'https://github.com/analogdevicesinc/libad9361-iio'
  head 'https://github.com/analogdevicesinc/libad9361-iio'

  depends_on 'cmake'
  depends_on 'libiio'

  patch :DATA
  
  def install
    mkdir 'build' do
      args = std_cmake_args
      args << "-DLIBIIO_INCLUDEDIR=/usr/local/Cellar/libiio/0.14/lib/iio.framework/Headers/"
      system 'cmake', '..', *args
      system 'make'
      system 'make install'
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index a7a8bdd..c9492a7 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -18,9 +18,7 @@ set(LIBAD9361_VERSION_MINOR 1)
 set(VERSION ${LIBAD9361_VERSION_MAJOR}.${LIBAD9361_VERSION_MINOR})
 
 if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-	option(OSX_PACKAGE "Create a OSX package" ON)
 	set(CMAKE_MACOSX_RPATH ON)
-	set(SKIP_INSTALL_ALL ${OSX_PACKAGE})
 endif()
 
 include(FindGit OPTIONAL)
@@ -115,7 +113,7 @@ if(OSX_PACKAGE)
 		COMMAND ${PKGBUILD_EXECUTABLE}
 			--component ${LIBAD9361_FRAMEWORK_DIR}
 			--identifier com.adi.ad9361 --version ${VERSION}
-			--install-location /Library/Frameworks ${LIBAD9361_TEMP_PKG}
+			--install-location ${INSTALL_LIB_DIR} ${LIBAD9361_TEMP_PKG}
 		COMMAND ${PRODUCTBUILD_EXECUTABLE}
 			--distribution ${LIBAD9361_DISTRIBUTION_XML} ${LIBAD9361_PKG}
 		COMMAND ${CMAKE_COMMAND} -E remove ${LIBAD9361_TEMP_PKG}
