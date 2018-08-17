class Libad9361Iio < Formula
  desc "ADI AD9361 interface for IIO"
  homepage 'https://github.com/analogdevicesinc/libad9361-iio'
  url 'https://github.com/analogdevicesinc/libad9361-iio/archive/v0.1.tar.gz'
  sha256 '46eeacb696e3b70873c541761af189a8ecde6ab7b3e7a5273dfc003e3ba0165d'
  head 'https://github.com/analogdevicesinc/libad9361-iio'

  depends_on 'cmake'
  depends_on 'libiio'

  patch :DATA

  def install
    mkdir 'build' do
      args = std_cmake_args
      system 'cmake', '..', *args
      inreplace "libad9361.pc", prefix, opt_prefix
      inreplace "libad9361.pc", "/include", "/lib/ad9361.framework/Headers"
      system 'make'
      system 'make', 'install'
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index a7a8bdd..5693265 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -18,28 +18,7 @@ set(LIBAD9361_VERSION_MINOR 1)
 set(VERSION ${LIBAD9361_VERSION_MAJOR}.${LIBAD9361_VERSION_MINOR})
 
 if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-	option(OSX_PACKAGE "Create a OSX package" ON)
 	set(CMAKE_MACOSX_RPATH ON)
-	set(SKIP_INSTALL_ALL ${OSX_PACKAGE})
-endif()
-
-include(FindGit OPTIONAL)
-if (GIT_FOUND)
-	execute_process(
-		COMMAND ${GIT_EXECUTABLE} rev-parse --show-toplevel
-		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
-		OUTPUT_VARIABLE LIBAD9361_GIT_REPO
-		OUTPUT_STRIP_TRAILING_WHITESPACE
-	)
-
-if (${LIBAD9361_GIT_REPO} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
-		execute_process(
-			COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
-			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
-			OUTPUT_VARIABLE LIBAD9361_VERSION_GIT
-			OUTPUT_STRIP_TRAILING_WHITESPACE
-		)
-	endif()
 endif()
 
 if (NOT LIBAD9361_VERSION_GIT)
@@ -115,7 +94,7 @@ if(OSX_PACKAGE)
 		COMMAND ${PKGBUILD_EXECUTABLE}
 			--component ${LIBAD9361_FRAMEWORK_DIR}
 			--identifier com.adi.ad9361 --version ${VERSION}
-			--install-location /Library/Frameworks ${LIBAD9361_TEMP_PKG}
+			--install-location ${INSTALL_LIB_DIR} ${LIBAD9361_TEMP_PKG}
 		COMMAND ${PRODUCTBUILD_EXECUTABLE}
 			--distribution ${LIBAD9361_DISTRIBUTION_XML} ${LIBAD9361_PKG}
 		COMMAND ${CMAKE_COMMAND} -E remove ${LIBAD9361_TEMP_PKG}
--- a/libad9361.pc.cmakein
+++ b/libad9361.pc.cmakein
@@ -1,7 +1,5 @@
 prefix=@CMAKE_INSTALL_PREFIX@
-exec_prefix=@CMAKE_INSTALL_PREFIX@
 libdir=@CMAKE_INSTALL_PREFIX@/lib
-sharedlibdir=@CMAKE_INSTALL_PREFIX@/lib
 includedir=@CMAKE_INSTALL_PREFIX@/include
 
 Name: libad9361
@@ -9,5 +7,5 @@ Description: Library for interfacing IIO devices
 Version: @LIBAD9361_VERSION@
 
 Requires:
-Libs: -L${libdir} -L${sharedlibdir} -lad9361
+Libs: -F${libdir} -framework ad9361
 Cflags: -I${includedir}
