import java.util.*;
import java.util.concurrent.*;

public class Hive {
    public static void main(String[] args) throws InterruptedException{

        Scanner scan = new Scanner(System.in);

        int numWorkers = scan.nextInt();
        int numTasks = scan.nextInt();

        scan.nextLine();

        List<Task> tasks = new ArrayList<>();

        for (int i = 0; i < numTasks; i++) {
            String[] input = scan.nextLine().split(" ");

            int id = Integer.parseInt(input[0]);
            int time = Integer.parseInt(input[1]);

            List<Integer> dependencies = new ArrayList<>();
            
            for (int j = 2; j < input.length; j++) {
                dependencies.add(Integer.parseInt(input[j]));
            }
            tasks.add(new Task(id, time, dependencies));
        }

        scan.close();

        ExecutorService executor = Executors.newFixedThreadPool(numWorkers);
        Queue<Task> queue = new LinkedList<>(tasks);

        while (!queue.isEmpty()) {
            Task task = queue.poll();

            if (task.canStart(tasks)) {

                executor.submit(() -> {
                    task.execute();
                    tasks.remove(task);
                });
                
            } else {
                queue.add(task);
            }
        }

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.MILLISECONDS);
    }
}