package jpcre;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.RuntimeException;
import java.util.Arrays;

public class JPcre {
    static {
        String os = getOs();
        String cpu = getCpu();
        String lib = getLibName("jpcre", os, cpu);
        try {
            ClassLoader classLoader = ClassLoader.getSystemClassLoader();
            InputStream in = classLoader.getResourceAsStream(lib);
            OutputStream out = new FileOutputStream("/tmp/"+lib);
            while (in.available() > 0) {
                byte[] data = new byte[1024];
                int len = in.read(data);
                out.write(data, 0, len);
            }
            out.close();
            in.close();
        } catch (Exception ex) {
            ex.printStackTrace();
            System.exit(-1);
        }
        System.load("/tmp/"+lib);
    }

    protected static String getOs() {
        String os = System.getProperty("os.name");
        if (os.equals("Mac OS X")) {
            os = "osx";
        } else if (os.equals("Linux")) {
            os = "linux";
        }

        return os;
    }

    protected static String getCpu() {
        String cpu = System.getProperty("os.arch");
        return cpu;
    }

    protected static String getLibName(String lib, String os, String cpu) {
        String mappedName = System.mapLibraryName("jpcre");
        String[] name_ext = mappedName.split("\\.");
        String name = name_ext[0];
        String ext = name_ext[1];

        if (os.equals("osx")) {
            ext = "dylib";
        }

        return String.format("%s-%s-%s.%s", name, os, cpu, ext);
    }

    public static String matches(String regex, String value) {
        String options = "";
        if (regex.startsWith("/")) {
            String[] parts = regex.split("/");
            regex = parts[1];
            if (parts.length == 3) {
                options = parts[2];
            }
        }
        String result = RawJPcre.matches(regex, options, value);
        String[] parts = result.split(":", 2);
        if ("error".equals(parts[0])) {
            throw new RuntimeException(parts[1]);
        }
        parts = parts[1].split(",");
        if ("0".equals(parts[0])) {
            return null;
        }
        return parts[1];
    }

}
