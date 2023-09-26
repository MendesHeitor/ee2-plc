package java;
import java.util.concurrent.*;
import java.util.Scanner;

public class PingPing {
    private static BlockingQueue<String> queue = new LinkedBlockingQueue<>();

    public static void main(String[] args) throws InterruptedException {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Digite valor de N:");
        int N = scanner.nextInt();
        scanner.close();

        Thread producer = new Thread(() -> {
            try {
                for (int i = 0; i < N; i++) {
                    queue.put("Ping");
                    System.out.println("Sent: Ping");
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        Thread consumer = new Thread(() -> {
            try {
                for (int i = 0; i < N; i++) {
                    String msg = queue.take();
                    System.out.println("Received: " + msg);
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        consumer.start();
        producer.start();

        consumer.join();
        producer.join();
    }
}
