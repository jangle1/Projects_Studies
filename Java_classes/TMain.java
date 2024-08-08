import java.util.*;

public class TMain {
    public static void main(String[] args) {
        // Przykladowy tekst dziennika zdarzeń
        String text = "ABABABACAB";
        int k = 2;

        TMarkov markov = new TMarkov(text, k);

        String kevent = "AB";
        int T = 20;

        System.out.println("Generated sequence: " + markov.gen(kevent, T));
    }
}

class TMarkov {
    private String text;
    private int k;
    private Map<String, Map<String, Integer>> transitionMatrix;

    public TMarkov(String text, int k) {
        this.text = text;
        this.k = k;
        this.transitionMatrix = new HashMap<>();
        buildTransitionMatrix();
    }

    private void buildTransitionMatrix() {
        int length = text.length();
        for (int i = 0; i <= length - k; i++) {
            String kEvent = text.substring(i, i + k);
            String nextEvent = i + k < length ? text.substring(i + k, i + k + 1) : "";

            if (!transitionMatrix.containsKey(kEvent)) {
                transitionMatrix.put(kEvent, new HashMap<>());
            }
            Map<String, Integer> nextEvents = transitionMatrix.get(kEvent);
            nextEvents.put(nextEvent, nextEvents.getOrDefault(nextEvent, 0) + 1);
        }
    }

    public int freq(String kevent) {
        return transitionMatrix.getOrDefault(kevent, Collections.emptyMap()).values().stream().mapToInt(Integer::intValue).sum();
    }

    public int freq(String kevent, String c) {
        return transitionMatrix.getOrDefault(kevent, Collections.emptyMap()).getOrDefault(c, 0);
    }

    public String rand(String kevent) {
        Map<String, Integer> nextEvents = transitionMatrix.getOrDefault(kevent, Collections.emptyMap());
        if (nextEvents.isEmpty()) {
            return "";
        }

        int total = nextEvents.values().stream().mapToInt(Integer::intValue).sum();
        int randIndex = new Random().nextInt(total);

        for (Map.Entry<String, Integer> entry : nextEvents.entrySet()) {
            randIndex -= entry.getValue();
            if (randIndex < 0) {
                return entry.getKey();
            }
        }
        return "";
    }

    public String gen(String kevent, int T) {
        StringBuilder result = new StringBuilder(kevent);
        String currentEvent = kevent;

        for (int i = 0; i < T - k; i++) {
            String nextEvent = rand(currentEvent);
            result.append(nextEvent);
            currentEvent = result.substring(result.length() - k);
        }
        return result.toString();
    }
}
