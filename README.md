# Competitive Programming Lab Programs

---

## Experiment 1 — Subarrays with K Different Integers

```java
// Experiment-1: Subarrays with K Different Integers

import java.util.*;

class Solution {
    public int subarraysWithKDistinct(int[] nums, int k) {
        return atMost(nums, k) - atMost(nums, k - 1);
    }

    private int atMost(int[] nums, int k) {
        Map<Integer, Integer> map = new HashMap<>();
        int left = 0, ans = 0;

        for (int right = 0; right < nums.length; right++) {
            map.put(nums[right], map.getOrDefault(nums[right], 0) + 1);

            while (map.size() > k) {
                map.put(nums[left], map.get(nums[left]) - 1);

                if (map.get(nums[left]) == 0)
                    map.remove(nums[left]);

                left++;
            }

            ans += right - left + 1;
        }

        return ans;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt();
        int k = sc.nextInt();

        int[] arr = new int[n];

        for (int i = 0; i < n; i++)
            arr[i] = sc.nextInt();

        System.out.println(new Solution().subarraysWithKDistinct(arr, k));
    }
}
```

---

## Experiment 2 — Shortest Subarray with Sum at Least K

```java
// Experiment-2: Shortest Subarray with Sum at Least K

import java.util.*;

class ShortestSubarray {

    public int shortestSubarray(int[] nums, int k) {

        int n = nums.length;

        long[] prefix = new long[n + 1];

        for (int i = 0; i < n; i++)
            prefix[i + 1] = prefix[i] + nums[i];

        int ans = n + 1;

        Deque<Integer> dq = new LinkedList<>();

        for (int i = 0; i <= n; i++) {

            while (!dq.isEmpty() &&
                    prefix[i] - prefix[dq.peekFirst()] >= k)

                ans = Math.min(ans, i - dq.pollFirst());

            while (!dq.isEmpty() &&
                    prefix[i] <= prefix[dq.peekLast()])

                dq.pollLast();

            dq.offerLast(i);
        }

        return ans == n + 1 ? -1 : ans;
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt();
        int k = sc.nextInt();

        int[] arr = new int[n];

        for (int i = 0; i < n; i++)
            arr[i] = sc.nextInt();

        System.out.println(new ShortestSubarray().shortestSubarray(arr, k));
    }
}
```

---

## Experiment 3 — Segment Tree

```java
// Experiment-3: Segment Tree

import java.util.*;

class SegmentTree {

    int[] tree;
    int n;

    SegmentTree(int[] arr) {
        n = arr.length;
        tree = new int[4 * n];
        build(arr, 0, 0, n - 1);
    }

    void build(int[] arr, int node, int start, int end) {

        if (start == end) {
            tree[node] = arr[start];
            return;
        }

        int mid = (start + end) / 2;

        build(arr, 2 * node + 1, start, mid);
        build(arr, 2 * node + 2, mid + 1, end);

        tree[node] =
                tree[2 * node + 1] +
                tree[2 * node + 2];
    }

    int query(int node, int start,
              int end, int left, int right) {

        if (right < start || end < left)
            return 0;

        if (left <= start && end <= right)
            return tree[node];

        int mid = (start + end) / 2;

        return query(
                2 * node + 1,
                start,
                mid,
                left,
                right
        ) + query(
                2 * node + 2,
                mid + 1,
                end,
                left,
                right
        );
    }

    int sumRange(int left, int right) {
        return query(0, 0, n - 1, left, right);
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt();

        int[] arr = new int[n];

        for (int i = 0; i < n; i++)
            arr[i] = sc.nextInt();

        int s1 = sc.nextInt();
        int s2 = sc.nextInt();

        SegmentTree st = new SegmentTree(arr);

        System.out.println(st.sumRange(s1, s2));
    }
}
```

---

## Experiment 4 — Treap

```java
// Experiment-4: Treap

import java.util.*;

class Solution {

    class Node {

        int key;
        int priority;
        int size;

        Node left, right;

        Node(int key) {
            this.key = key;
            this.priority = new Random().nextInt();
            this.size = 1;
        }
    }

    int size(Node root) {
        return root == null ? 0 : root.size;
    }

    void update(Node root) {
        if (root != null)
            root.size =
                    1 +
                    size(root.left) +
                    size(root.right);
    }

    Node rotateRight(Node y) {

        Node x = y.left;

        y.left = x.right;
        x.right = y;

        update(y);
        update(x);

        return x;
    }

    Node rotateLeft(Node x) {

        Node y = x.right;

        x.right = y.left;
        y.left = x;

        update(x);
        update(y);

        return y;
    }

    Node insert(Node root, int key) {

        if (root == null)
            return new Node(key);

        if (key < root.key) {

            root.left = insert(root.left, key);

            if (root.left.priority > root.priority)
                root = rotateRight(root);

        } else {

            root.right = insert(root.right, key);

            if (root.right.priority > root.priority)
                root = rotateLeft(root);
        }

        update(root);

        return root;
    }

    int countGreater(Node root, long value) {

        if (root == null)
            return 0;

        if (root.key <= value)
            return countGreater(root.right, value);

        return 1 +
                size(root.right) +
                countGreater(root.left, value);
    }

    public int reversePairs(int[] nums) {

        Node root = null;

        int count = 0;

        for (int num : nums) {

            count += countGreater(root, 2L * num);

            root = insert(root, num);
        }

        return count;
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt();

        int[] arr = new int[n];

        for (int i = 0; i < n; i++)
            arr[i] = sc.nextInt();

        System.out.println(
                new Solution().reversePairs(arr)
        );
    }
}
```
