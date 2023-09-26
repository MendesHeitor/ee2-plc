import java.util.*;

public class Task {
    private int id;
    private int time;
    private List<Integer> dependencies;

    public Task(int id, int time, List<Integer> dependencies) {
        this.id = id;
        this.time = time;
        this.dependencies = dependencies;
    }

    public int getId() {
        return id;
    }

    public boolean canStart(List<Task> tasks) {
        return tasks.stream().noneMatch(t -> dependencies.contains(t.id));
    }

    public void execute() {
        try {
            Thread.sleep(time);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("task " + id + " done");
    }
}
