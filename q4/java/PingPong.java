package java;
import java.util.Scanner;

public class PingPong {
    private static Object lock = new Object();
    private static boolean messageSent = false;

    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);

        System.out.println("Digite valor de N:");
        int N = scan.nextInt();
        scan.close();

        Thread ping = new Thread(() -> {
            synchronized (lock) {
                for (int i = 0; i < N; i++) {
                    while (messageSent) {
                        try {
                            lock.wait();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                    System.out.println("Ping!");
                    messageSent = true;
                    lock.notifyAll();
                }
            }
        });

        Thread pong = new Thread(() -> {
            synchronized (lock) {
                for (int i = 0; i < N; i++) {
                    while (!messageSent) {
                        try {
                            lock.wait();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                    System.out.println(" Pong!");
                    messageSent = false;
                    lock.notifyAll();
                }
            }
        });

        ping.start();
        pong.start();
    }
}
