import java.util.Queue;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.TimeUnit;

public class AirportManagementSystem {
    public static void main(String[] args) throws InterruptedException {
        Scanner scan = new Scanner(System.in);
        Queue<Plane> planeQueue = new PriorityBlockingQueue<>();

        // departures
        int N = scan.nextInt();

        for (int i = 0; i < N; i++) {
            long expectedTime = scan.nextLong();
            planeQueue.add(new Plane(expectedTime, "Take off"));
        }

        // arrivals
        int M = scan.nextInt();

        for (int i = 0; i < M; i++) {
            long expectedTime = scan.nextLong();
            planeQueue.add(new Plane(expectedTime, "Landing"));
        }

        // runways
        int K = scan.nextInt();
        scan.close();

        Airport airport = new Airport(K);
        ExecutorService executorService = Executors.newFixedThreadPool(K);

        // let the operations begin
        long start = System.currentTimeMillis();

        while (!(planeQueue.isEmpty())) {
            Plane plane = planeQueue.peek();
            long currTime = System.currentTimeMillis() - start;

            if (currTime >= plane.expectedTime) {
                executorService.submit(() -> {
                    try {
                        airport.planeAction(plane, start);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                });

                planeQueue.poll();
            }
        }

        executorService.shutdown();
        executorService.awaitTermination(Long.MAX_VALUE, TimeUnit.MILLISECONDS);
    }
}
