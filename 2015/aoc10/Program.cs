using System.Runtime.InteropServices;

ReadOnlySpan<int> input = [1, 1, 1, 3, 1, 2, 2, 1, 1, 3];
// int len = 40; // part1
int len = 50;

Console.WriteLine(LookAndSay(input, len).Count);

List<int> LookAndSay(ReadOnlySpan<int> data, int cnt) {
    var list1 = data.ToArray().ToList();
    var list2 = new List<int>();
    while (cnt-- > 0) {
        LookAndSayPass(CollectionsMarshal.AsSpan(list1), list2);
        (list1, list2) = (list2, list1);
    }
    return list1;
}

void LookAndSayPass(ReadOnlySpan<int> cur, List<int> res) {
    res.Clear();
    while (!cur.IsEmpty) {
        var len = cur.Length;
        var digit = cur[0];
        cur = cur.TrimStart(digit);
        res.Add(len - cur.Length);
        res.Add(digit);
    }
}