using System.Text.RegularExpressions;
using System.Text.Json;

namespace Aoc12;

internal class Program
{
    private static void Main(string[] args)
    {
        // var res = SumJsonValues(File.ReadAllText(args[0])); // part1
        var res = SumJsonValuesNoRed(File.ReadAllText(args[0])); // part2

        Console.WriteLine(res);
    }

    static int SumJsonValues(string s)
    {
        var num = new Regex("-?[0-9]+");
        return num.Matches(s).Select(p => int.Parse(p.Value)).Sum();
    }

    static int SumJsonValuesNoRed(string s)
    {
        var doc = JsonDocument.Parse(s);
        return SumJsonValuesNoRed(doc.RootElement);
    }

    static int SumJsonValuesNoRed(JsonElement e)
    {
        int res = 0;
        switch (e.ValueKind)
        {
            case JsonValueKind.Object:
                foreach (var p in e.EnumerateObject())
                {
                    if (p.Value.ValueKind == JsonValueKind.String && p.Value.GetString() == "red")
                    {
                        return 0;
                    }
                    res += SumJsonValuesNoRed(p.Value);
                }
                return res;
            case JsonValueKind.Array:
                foreach (var o in e.EnumerateArray())
                {
                    res += SumJsonValuesNoRed(o);
                }
                return res;
            case JsonValueKind.Number:
                return e.GetInt32();
            default:
                return 0;
        }
    }
}
