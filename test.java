import jpcre.JPcre;

public class test {
    public static void main(String argv[]) {
        System.out.println(JPcre.matches(argv[0], argv[1]));
    }
}
