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

            while (!dq.isEmpty() && prefix[i] - prefix[dq.peekFirst()] >= k)
                ans = Math.min(ans, i - dq.pollFirst());

            while (!dq.isEmpty() && prefix[i] <= prefix[dq.peekLast()])
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

// Experiment-3: Fenwick Tree

import java.util.*;

class NumArray {
    int[] bit;
    int n;

    NumArray(int[] nums) {
        n = nums.length;
        bit = new int[n + 1];

        for (int i = 0; i < n; i++)
            update(i, nums[i]);
    }

    void update(int index, int val) {
        index++;

        while (index <= n) {
            bit[index] += val;
            index += index & -index;
        }
    }

    int sum(int index) {
        int res = 0;
        index++;

        while (index > 0) {
            res += bit[index];
            index -= index & -index;
        }

        return res;
    }

    int sumRange(int left, int right) {
        return sum(right) - sum(left - 1);
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt();

        int[] nums = new int[n];

        for (int i = 0; i < n; i++)
            nums[i] = sc.nextInt();

        int s1 = sc.nextInt();
        int s2 = sc.nextInt();

        NumArray na = new NumArray(nums);

        System.out.println(na.sumRange(s1, s2));
    }
}

// Experiment-4: Segment Tree

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

        tree[node] = tree[2 * node + 1] + tree[2 * node + 2];
    }

    int query(int node, int start, int end, int left, int right) {

        if (right < start || end < left)
            return 0;

        if (left <= start && end <= right)
            return tree[node];

        int mid = (start + end) / 2;

        return query(2 * node + 1, start, mid, left, right)
                + query(2 * node + 2, mid + 1, end, left, right);
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


// Experiment-5: Treap

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
            root.size = 1 + size(root.left) + size(root.right);
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

        return 1 + size(root.right)
                + countGreater(root.left, value);
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

        System.out.println(new Solution().reversePairs(arr));
    }
}

// Experiment-6: Topological Sort

import java.util.*;

class Graph {
    int V;
    ArrayList<ArrayList<Integer>> adj;

    Graph(int v) {
        V = v;
        adj = new ArrayList<>();

        for (int i = 0; i < v; i++)
            adj.add(new ArrayList<>());
    }

    void addEdge(int u, int v) {
        adj.get(u).add(v);
    }

    void dfs(int node, boolean[] visited, Stack<Integer> stack) {
        visited[node] = true;

        for (int next : adj.get(node))
            if (!visited[next])
                dfs(next, visited, stack);

        stack.push(node);
    }

    void topologicalSort() {
        boolean[] visited = new boolean[V];
        Stack<Integer> stack = new Stack<>();

        for (int i = 0; i < V; i++)
            if (!visited[i])
                dfs(i, visited, stack);

        while (!stack.isEmpty())
            System.out.print(stack.pop() + " ");
    }

    public static void main(String[] args) {
        Graph g = new Graph(6);

        g.addEdge(5, 2);
        g.addEdge(5, 0);
        g.addEdge(4, 0);
        g.addEdge(4, 1);
        g.addEdge(2, 3);
        g.addEdge(3, 1);

        g.topologicalSort();
    }
}


// Experiment-7: Articulation Points

import java.util.*;

class Graph {

    static int time = 0;

    static void addEdge(ArrayList<ArrayList<Integer>> adj, int u, int v) {
        adj.get(u).add(v);
        adj.get(v).add(u);
    }

    static void dfs(ArrayList<ArrayList<Integer>> adj, int u,
                    boolean[] visited, int[] disc,
                    int[] low, int parent,
                    boolean[] ap) {

        visited[u] = true;
        disc[u] = low[u] = ++time;

        int children = 0;

        for (int v : adj.get(u)) {

            if (!visited[v]) {
                children++;

                dfs(adj, v, visited, disc, low, u, ap);

                low[u] = Math.min(low[u], low[v]);

                if (parent != -1 && low[v] >= disc[u])
                    ap[u] = true;
            }

            else if (v != parent)
                low[u] = Math.min(low[u], disc[v]);
        }

        if (parent == -1 && children > 1)
            ap[u] = true;
    }

    static void articulationPoints(ArrayList<ArrayList<Integer>> adj, int V) {

        boolean[] visited = new boolean[V];
        boolean[] ap = new boolean[V];

        int[] disc = new int[V];
        int[] low = new int[V];

        for (int i = 0; i < V; i++)
            if (!visited[i])
                dfs(adj, i, visited, disc, low, -1, ap);

        for (int i = 0; i < V; i++)
            if (ap[i])
                System.out.print(i + " ");
    }

    public static void main(String[] args) {

        int V = 5;

        ArrayList<ArrayList<Integer>> adj = new ArrayList<>();

        for (int i = 0; i < V; i++)
            adj.add(new ArrayList<>());

        addEdge(adj, 1, 0);
        addEdge(adj, 0, 2);
        addEdge(adj, 2, 1);
        addEdge(adj, 0, 3);
        addEdge(adj, 3, 4);

        articulationPoints(adj, V);
    }
}


// Experiment-8: Permutation Palindrome

import java.util.*;

class PermutationPalindrome {

    public boolean canPermutePalindrome(String s) {

        int[] freq = new int[26];

        for (char c : s.toCharArray())
            freq[c - 'a']++;

        int odd = 0;

        for (int x : freq)
            if (x % 2 != 0)
                odd++;

        return odd <= 1;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.println(
                new PermutationPalindrome().canPermutePalindrome(sc.next())
        );
    }
}


// Experiment-9: Index Pairs of String

import java.util.*;

class Solution {

    public int[][] indexPairs(String text, String[] words) {

        List<int[]> list = new ArrayList<>();

        for (String word : words) {

            int index = text.indexOf(word);

            while (index != -1) {
                list.add(new int[]{index, index + word.length() - 1});
                index = text.indexOf(word, index + 1);
            }
        }

        list.sort((a, b) ->
                a[0] == b[0] ? a[1] - b[1] : a[0] - b[0]);

        int[][] ans = new int[list.size()][2];

        for (int i = 0; i < list.size(); i++)
            ans[i] = list.get(i);

        return ans;
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        String text = sc.nextLine();

        String[] words = sc.nextLine().split(" ");

        int[][] result = new Solution().indexPairs(text, words);

        for (int[] pair : result)
            System.out.println(pair[0] + " " + pair[1]);
    }
}


// Experiment-10: Lowest Common Ancestor

class TreeNode {
    int val;
    TreeNode left, right;

    TreeNode(int val) {
        this.val = val;
    }
}

class Solution {

    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {

        if (root == null || root == p || root == q)
            return root;

        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);

        if (left != null && right != null)
            return root;

        return left != null ? left : right;
    }

    public static void main(String[] args) {

        TreeNode root = new TreeNode(3);

        root.left = new TreeNode(5);
        root.right = new TreeNode(1);

        root.left.left = new TreeNode(6);
        root.left.right = new TreeNode(2);

        Solution s = new Solution();

        TreeNode ans = s.lowestCommonAncestor(root, root.left, root.right);

        System.out.println(ans.val);
    }
}


// Experiment-11: Longest Increasing Path in Matrix

import java.util.*;

class Solution {

    int[][] dirs = {{1,0},{-1,0},{0,1},{0,-1}};

    public int longestIncreasingPath(int[][] matrix) {

        int m = matrix.length;
        int n = matrix[0].length;

        int[][] dp = new int[m][n];

        int ans = 0;

        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++)
                ans = Math.max(ans, dfs(matrix, dp, i, j));

        return ans;
    }

    private int dfs(int[][] matrix, int[][] dp, int i, int j) {

        if (dp[i][j] != 0)
            return dp[i][j];

        int max = 1;

        for (int[] d : dirs) {

            int x = i + d[0];
            int y = j + d[1];

            if (x >= 0 && y >= 0 &&
                x < matrix.length &&
                y < matrix[0].length &&
                matrix[x][y] > matrix[i][j]) {

                max = Math.max(max,
                        1 + dfs(matrix, dp, x, y));
            }
        }

        return dp[i][j] = max;
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        int m = sc.nextInt();
        int n = sc.nextInt();

        int[][] matrix = new int[m][n];

        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++)
                matrix[i][j] = sc.nextInt();

        System.out.println(
                new Solution().longestIncreasingPath(matrix)
        );
    }
}


// Experiment-12: Lexicographically Smallest Equivalent String

import java.util.*;

class Solution {

    int[] parent = new int[26];

    int find(int x) {
        if (parent[x] != x)
            parent[x] = find(parent[x]);

        return parent[x];
    }

    void union(int a, int b) {

        int pa = find(a);
        int pb = find(b);

        if (pa < pb)
            parent[pb] = pa;
        else
            parent[pa] = pb;
    }

    public String smallestEquivalentString(String A, String B, String S) {

        for (int i = 0; i < 26; i++)
            parent[i] = i;

        for (int i = 0; i < A.length(); i++)
            union(A.charAt(i) - 'a', B.charAt(i) - 'a');

        StringBuilder sb = new StringBuilder();

        for (char c : S.toCharArray())
            sb.append((char)(find(c - 'a') + 'a'));

        return sb.toString();
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        String A = sc.next();
        String B = sc.next();
        String S = sc.next();

        System.out.println(
                new Solution().smallestEquivalentString(A, B, S)
        );
    }
}

