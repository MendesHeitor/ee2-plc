import java.util.Scanner;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class PingPong {
    private static final String PING = " Ping!";
    private static final String PONG = "Pong!";
    private static final BlockingQueue<String> pingQueue = new LinkedBlockingQueue<>(1); 
    private static final BlockingQueue<String> pongQueue = new LinkedBlockingQueue<>(1); 

    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        System.out.println("Digite valor de N:");
        int N = scan.nextInt();
        scan.close();

        Thread ping = new Thread(() -> {
            for (int i = 0; i < N; i++) {
                try {
                    pingQueue.put(PING); // coloca ping
                    System.out.println(PING);
                    while (!pongQueue.take().equals(PONG)) { } // trava enquanto pong não é colocado
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        Thread pong = new Thread(() -> {
            for (int i = 0; i < N; i++) {
                try {
                    while (!pingQueue.take().equals(PING)) { } //trava enquanto ping não é colocado
                    System.out.println(PONG);
                    pongQueue.put(PONG); // coloca pong
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        ping.start();
        pong.start();
    }
}
