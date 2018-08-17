require 'formula'

class IioOscilloscope < Formula
  desc "ADI IIO-Oscilloscope "
  homepage 'https://github.com/analogdevicesinc/iio-oscilloscope/'
  url 'https://github.com/analogdevicesinc/iio-oscilloscope/archive/v0.8-master.tar.gz'
  sha256 '45b451a6086e52275ec761f2b5c3a2e28bf8bd3264bddaca1da2890cd1efb3d7'
  head 'https://github.com/analogdevicesinc/iio-oscilloscope/'

  depends_on 'glib'
  depends_on 'gtk+'
  depends_on 'fftw'
  depends_on 'gtkdatabox'
  depends_on 'libiio'
  depends_on 'libad9361-iio'
  depends_on 'jansson'
  depends_on 'libmatio'
  depends_on 'szip'
  depends_on 'hdf5'
  depends_on 'gcc'
  depends_on 'pkg-config'
 
  patch :DATA
  
  def install
    args = ["CC=gcc-8", "PREFIX=#{prefix}"]
    system 'make', *args
    system 'make', *args, 'install'
  end
end

__END__
diff --git a/Makefile b/Makefile
index 92d5736..d2b188d 100644
--- a/Makefile
+++ b/Makefile
@@ -21,9 +21,7 @@ WITH_MINGW := $(if $(shell echo | $(CC) -dM -E - |grep __MINGW32__),y)
 EXPORT_SYMBOLS := -Wl,--export-all-symbols
 EXPORT_SYMBOLS := $(if $(WITH_MINGW),$(EXPORT_SYMBOLS))
 
-PKG_CONFIG_PATH := $(SYSROOT)/usr/share/pkgconfig:$(SYSROOT)/usr/lib/pkgconfig:$(SYSROOT)$(PREFIX)/lib/pkgconfig:$(SYSROOT)/usr/lib/$(MULTIARCH)/pkgconfig
-PKG_CONFIG := env PKG_CONFIG_SYSROOT_DIR="$(SYSROOT)" \
-	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" pkg-config
+PKG_CONFIG := pkg-config
 
 DEPENDENCIES := glib-2.0 gtk+-2.0 gthread-2.0 gtkdatabox fftw3 libiio libxml-2.0 libcurl jansson matio libad9361
 
@@ -38,10 +36,8 @@ $(foreach dep,$(DEPENDENCIES),$(eval $(call dep_flags,$(dep))))
 
 LDFLAGS := $(DEP_LDFLAGS) \
 	$(if $(WITH_MINGW),-lwinpthread) \
-	-L$(SYSROOT)/usr/lib64 \
 	-L$(SYSROOT)/usr/lib \
-	-L$(SYSROOT)/usr/lib32 \
-	-lmatio -lz -lm -lad9361
+	-lz -lm
 
 ifeq ($(WITH_MINGW),y)
 	LDFLAGS += -Wl,--subsystem,windows
@@ -51,16 +47,17 @@ endif
 
 CFLAGS := $(DEP_CFLAGS) \
 	-I$(SYSROOT)/usr/include $(if $(WITH_MINGW),-mwindows,-fPIC) \
+	-I$(SYSROOT)/usr/include/malloc \
 	-Wall -Wclobbered -Wempty-body -Wignored-qualifiers -Wmissing-field-initializers \
 	-Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
 	-Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter \
 	-Wextra -Wno-unused-parameter \
-	-Werror -g -std=gnu90 -D_GNU_SOURCE -O2 -funwind-tables \
+	-g -std=gnu90 -D_GNU_SOURCE -O2 -funwind-tables \
 	-DPREFIX='"$(PREFIX)"' \
 	-DFRU_FILES=\"$(FRU_FILES)\" -DGIT_VERSION=\"$(GIT_VERSION)\" \
 	-DGIT_COMMIT_TIMESTAMP='"$(GIT_COMMIT_TIMESTAMP)"' \
 	-DOSC_VERSION=\"$(GIT_BRANCH)-g$(GIT_HASH)\" \
-	-D_POSIX_C_SOURCE=200809L
+	-D_POSIX_C_SOURCE=200809L -D_DARWIN_C_SOURCE
 
 DEBUG ?= 0
 ifeq ($(DEBUG),1)
@@ -211,9 +208,9 @@ uninstall-all: uninstall-common-files
 	xdg-desktop-menu uninstall osc.desktop
 	ldconfig
 
-install: $(if $(DEBIAN_INSTALL),install-common-files,install-all)
+install: install-common-files
 
-uninstall: $(if $(DEBIAN_INSTALL),uninstall-common-files,uninstall-all)
+uninstall: uninstall-common-files
 
 clean:
 	$(SUM) "  CLEAN    ."
diff --git a/eeprom.c b/eeprom.c
index 741413d..786dc0c 100644
--- a/eeprom.c
+++ b/eeprom.c
@@ -9,6 +9,7 @@
 #include <ftw.h>
 #include <stddef.h>
 #include <stdlib.h>
+#include <libgen.h>
 #include <string.h>
 
 #include "eeprom.h"
@@ -19,7 +20,7 @@ static const char *eeprom_path = NULL;
 static int is_eeprom(const char *fpath, const struct stat *sb,
 		int typeflag, struct FTW *ftwbuf)
 {
-	if (typeflag == FTW_F && !strcmp(basename(fpath), "eeprom") \
+    if (typeflag == FTW_F && !strcmp(basename((char*)fpath), "eeprom")    \
 			&& sb->st_size == FAB_SIZE_FRU_EEPROM) {
 		eeprom_path = strdup(fpath);
 		return 1;
diff --git a/fru.c b/fru.c
index 3a8c908..6279740 100644
--- a/fru.c
+++ b/fru.c
@@ -232,7 +232,7 @@ int ascii2six(unsigned char **dest, unsigned char *src, size_t size)
 		}
 #ifndef __MINGW32__
 #if __BYTE_ORDER == __BIG_ENDIAN
-		k = __bswap_32(k);
+		//k = __bswap_32(k);
 #endif
 #endif
 		memcpy(p, &k, 3);
@@ -778,7 +778,7 @@ unsigned char * build_FRU_blob (struct FRU_DATA *fru, size_t *length, bool packe
 			/* Store OUI */
 #ifndef __MINGW32__
 # if __BYTE_ORDER == __BIG_ENDIAN
-			oui = __bswap_32(oui);
+			//oui = __bswap_32(oui);
 #endif
 #endif
 			memcpy(&buf[i+5], &oui, 3);
diff --git a/plugins/scpi.c b/plugins/scpi.c
index e0a438c..d56a974 100644
--- a/plugins/scpi.c
+++ b/plugins/scpi.c
@@ -30,12 +30,9 @@
 
 #include <arpa/inet.h>
 #include <dirent.h>
-#include <error.h>
 #include <errno.h>
 #include <fcntl.h>
 #include <inttypes.h>
-#include <linux/errno.h>
-#include <linux/types.h>
 #include <math.h>
 #include <netinet/in.h>
 #include <netinet/tcp.h>
@@ -136,6 +133,20 @@ static char *supported_counters[] = {
 #define print_output_scpi(x) {do { } while (0);}
 #endif
 
+/* Don't have this on W32, here's a naive implementation
+ * Was somehow removed on OS X ...  */
+void *
+memrchr (const void *s, int c, size_t n)
+{
+  size_t i;
+  unsigned char *ucs = (unsigned char *) s;
+
+  for (i = n - 1; i >= 0; i--)
+    if (ucs[i] == c)
+      return (void *) &ucs[i];
+  return NULL;
+}
+
 /*
  * Network communications functions
  */
