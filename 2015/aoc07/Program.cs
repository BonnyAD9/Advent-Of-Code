namespace Aoc07;

internal class Program
{
    private static void Main(string[] args)
    {
        var gates = new GateStore();
        foreach (var l in File.ReadLines(args[0])) {
            gates.AddGate(l);
        }

        gates.AddGate("46065 -> b"); // part2

        Console.WriteLine(gates.GetValue("a"));
    }
}
