input = [2, 72, 8949, 0, 981038, 86311, 246, 7636740]

main = do
    (print.length.part1) input
    --(print.length.part2) input

part1 = blinkn 25
part2 = blinkn 75

blinkn n i = iterate blink i !! n

blink [] = []
blink (0:r) = 1 : blink r
blink (n:r)
    | odd dc = (n * 2024) : blink r
    | otherwise = (n `div` p) : (n `mod` p) : blink r
    where
        dc = digCnt n
        p = 10 ^ (dc `div` 2)

digCnt 0 = 1
digCnt x = 1 + (floor . logBase 10 . fromIntegral) x
