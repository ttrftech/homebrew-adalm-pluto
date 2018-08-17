class Libiio < Formula
  desc "ADI IIO (Industrial IO) interface framework"
  homepage 'https://github.com/analogdevicesinc/libiio'
  url 'https://github.com/analogdevicesinc/libiio/archive/v0.15.tar.gz'
  sha256 'a729f8ff48137ad271a3e2951f322b35c1bf2ec075b488d75c8bd071c693fd19'
  head 'git://github.com/analogdevicesinc/libiio/'

  depends_on 'cmake'
  depends_on 'python@2' => :optional

  patch :DATA

  def install
    mkdir 'build' do
      args = std_cmake_args
      system 'cmake', '..', *args
      inreplace "libiio.pc", prefix, opt_prefix/"lib"
      inreplace "libiio.pc", "/include", "/iio.framework/Headers"
      inreplace "libiio.pc", "${prefix}/lib", "${prefix}"
      system 'make'
      system 'make', 'install'
    end

    if build.with? "python@2"
      mkdir 'build2' do
        # build for python2
        args = std_cmake_args
        args << "-DPythonInterp_FIND_VERSION=1"
        args << "-DPythonInterp_FIND_VERSION_MAJOR=2"
        system 'cmake', '..', *args
        system 'make'
        system 'make', 'install'
      end
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 1e198e2..916dcdc 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -31,9 +31,7 @@ endif()
 set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries")
 
 if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-	option(OSX_PACKAGE "Create a OSX package" ON)
 	set(CMAKE_MACOSX_RPATH ON)
-	set(SKIP_INSTALL_ALL ${OSX_PACKAGE})
 endif()
 
 option(WITH_NETWORK_BACKEND "Enable the network backend" ON)
@@ -316,7 +314,6 @@ add_library(iio ${LIBIIO_CFILES} ${LIBIIO_HEADERS} ${LIBIIO_EXTRA_HEADERS} ${LIB
 set_target_properties(iio PROPERTIES
 	VERSION ${VERSION}
 	SOVERSION ${LIBIIO_VERSION_MAJOR}
-	FRAMEWORK TRUE
 	PUBLIC_HEADER ${LIBIIO_HEADERS}
 	C_STANDARD 99
 	C_STANDARD_REQUIRED ON
@@ -333,7 +330,7 @@ if(NOT SKIP_INSTALL_ALL)
 		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
 		LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
 		RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
-		FRAMEWORK DESTINATION /Library/Frameworks
+		FRAMEWORK DESTINATION ${CMAKE_INSTALL_LIBDIR}
 		PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
 endif()
 
@@ -388,7 +385,7 @@ if(OSX_PACKAGE)
 		COMMAND ${PKGBUILD_EXECUTABLE}
 			--component ${LIBIIO_FRAMEWORK_DIR}
 			--identifier com.adi.iio --version ${VERSION}
-			--install-location /Library/Frameworks ${LIBIIO_TEMP_PKG}
+			--install-location ${CMAKE_INSTALL_LIBDIR} ${LIBIIO_TEMP_PKG}
 		COMMAND ${PRODUCTBUILD_EXECUTABLE}
 			--distribution ${LIBIIO_DISTRIBUTION_XML} ${LIBIIO_PKG}
 		COMMAND ${CMAKE_COMMAND} -E remove ${LIBIIO_TEMP_PKG}
diff --git a/tests/CMakeLists.txt b/tests/CMakeLists.txt
index e734e1d..3f46267 100644
--- a/tests/CMakeLists.txt
+++ b/tests/CMakeLists.txt
@@ -50,7 +50,7 @@ set_target_properties(${IIO_TESTS_TARGETS} PROPERTIES
 
 if(NOT SKIP_INSTALL_ALL)
 	if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-		install(TARGETS ${IIO_TESTS_TARGETS} RUNTIME DESTINATION /Library/Frameworks/iio.framework/Tools)
+		install(TARGETS ${IIO_TESTS_TARGETS} RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}/iio.framework/Tools)
 	else()
 		install(TARGETS ${IIO_TESTS_TARGETS} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
 	endif()
