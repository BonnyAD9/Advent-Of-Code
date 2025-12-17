var part1 = NextPass("hxbxwxba");
var part2 = NextPass(part1);

Console.WriteLine($"part1: {part1}");
Console.WriteLine($"part2: {part2}");

string NextPass(string pass)
{
    pass = IncPass(pass);
    while (!IsValidPassword(pass))
    {
        pass = IncPass(pass);
    }
    return pass;
}

string IncPass(string pass)
{
    var p = pass.ToArray().AsSpan();

    const char min = 'a';
    const char max = 'z';

    for (int i = pass.Length - 1; i >= 0; --i)
    {
        if (++p[i] <= max)
        {
            break;
        }
        p[i] = min;
    }
    return p.ToString();
}

bool IsValidPassword(string pass)
{
    return HasIncSeq(pass) && HasValidLetters(pass) && HasTwoPairs(pass);
}

bool HasIncSeq(string pass)
{
    var p = pass.Select(p => (int)p).ToArray();
    for (int i = 0; i < p.Length - 2; ++i)
    {
        if (p[i] + 2 == p[i + 2] && p[i] + 1 == p[i + 1])
        {
            return true;
        }
    }
    return false;
}

bool HasValidLetters(string pass)
{
    return !pass.Any(a => a is 'i' or 'o' or 'l');
}

bool HasTwoPairs(string pass)
{
    var last = '\0';
    for (int i = 0; i < pass.Length - 1; ++i)
    {
        if (pass[i] == pass[i + 1] && pass[i] != last)
        {
            if (last == '\0')
            {
                last = pass[i];
            }
            else
            {
                return true;
            }
        }
    }
    return false;
}
