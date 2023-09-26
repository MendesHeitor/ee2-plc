public class Plane implements Comparable<Plane> {
    long expectedTime;
    String action;

    public Plane(long expectedTime, String action) {
        this.expectedTime = expectedTime;
        this.action = action;
    }

    @Override
    public int compareTo(Plane o) {
        return Long.compare(this.expectedTime, o.expectedTime);
    }
}