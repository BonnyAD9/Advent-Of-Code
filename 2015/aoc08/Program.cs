using System.Globalization;

int part1 = 0;
int part2 = 0;
foreach (var l in File.ReadAllLines(args[0]))
{
    part1 += UnescapeDiff(l);
    part2 += EscapeDiff(l);
}

Console.WriteLine($"part1: {part1}");
Console.WriteLine($"part2: {part2}");

int UnescapeDiff(ReadOnlySpan<char> str)
{
    str = str.Trim();
    return str.Length - Unescape(str[1..^1]).Length;
}

int EscapeDiff(ReadOnlySpan<char> str)
{
    str = str.Trim();
    return Escape(str).Length - str.Length + 2;
}

string Escape(ReadOnlySpan<char> str)
{
    string res = "";
    foreach (var c in str)
    {
        res += c switch
        {
            '"' => "\\\"",
            '\\' => "\\\\",
            var o => o
        };
    }
    return res;
}

string Unescape(ReadOnlySpan<char> str)
{
    string res = "";
    while (!str.IsEmpty)
    {
        switch (str)
        {
            case ['\\', 'x', var a, var b, .. var s]:
                res += (char)int.Parse($"{a}{b}", NumberStyles.HexNumber);
                str = s;
                break;
            case ['\\', var c, .. var s1]:
                res += c;
                str = s1;
                break;
            case [var c, .. var s2]:
                res += c;
                str = s2;
                break;
        }
    }
    return res;
}
