import java.util.concurrent.Semaphore;

public class Airport {
    private final Semaphore runways;

    public Airport(int numRunways) {
        this.runways = new Semaphore(numRunways);
    }

    public void planeAction(Plane plane, long startTime) throws InterruptedException {
        runways.acquire();
        long currTime = System.currentTimeMillis() - startTime;
        try {
            long delay = currTime - plane.expectedTime;
            System.out.println("Expected time for " + plane.action + " : " + plane.expectedTime + " | Current time: "
                    + currTime + " | Delay: " + delay);
            Thread.sleep(500);
        } finally {
            runways.release();
        }
    }
}
